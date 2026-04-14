-- =========================================================
-- FUNCTIONS
-- =========================================================

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', ''),
    new.email
  )
  on conflict (id) do update
  set
    email = excluded.email,
    full_name = case
      when coalesce(public.profiles.full_name, '') = '' then excluded.full_name
      else public.profiles.full_name
    end;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and app_role = 'admin'
  );
$$;

create or replace function public.set_user_role(
  p_profile_id uuid,
  p_app_role public.app_role
)
returns public.profiles
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor_id uuid;
  v_target public.profiles%rowtype;
begin
  v_actor_id := auth.uid();

  if v_actor_id is null then
    raise exception 'Usuario nao autenticado.';
  end if;

  if not public.is_admin() then
    raise exception 'Apenas administradores podem alterar papeis.';
  end if;

  if p_profile_id = v_actor_id then
    raise exception 'Nao e permitido alterar o proprio papel.';
  end if;

  update public.profiles
  set
    app_role = p_app_role,
    role = p_app_role::text
  where id = p_profile_id
  returning *
  into v_target;

  if not found then
    raise exception 'Perfil nao encontrado.';
  end if;

  return v_target;
end;
$$;

create or replace function public.create_stock_movement(
  p_product_id uuid,
  p_movement_type public.movement_type,
  p_quantity integer,
  p_reason text default null,
  p_notes text default null
)
returns public.stock_movements
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_profile_id uuid;
  v_product public.products%rowtype;
  v_current_stock integer;
  v_new_movement public.stock_movements%rowtype;
begin
  v_user_id := auth.uid();

  if v_user_id is null then
    raise exception 'Usuario nao autenticado.';
  end if;

  select p.*
  into v_product
  from public.products p
  where p.id = p_product_id;

  if not found then
    raise exception 'Produto nao encontrado.';
  end if;

  if v_product.status <> 'active' then
    raise exception 'Produto inativo nao pode receber movimentacoes.';
  end if;

  if p_quantity is null or p_quantity <= 0 then
    raise exception 'A quantidade deve ser maior que zero.';
  end if;

  if p_movement_type = 'adjustment' and coalesce(trim(p_reason), '') = '' then
    raise exception 'Ajuste exige justificativa.';
  end if;

  select pr.id
  into v_profile_id
  from public.profiles pr
  where pr.id = v_user_id;

  if v_profile_id is null then
    raise exception 'Perfil do usuario nao encontrado.';
  end if;

  select coalesce(sum(
    case
      when sm.movement_type = 'in' then sm.quantity
      when sm.movement_type = 'out' then -sm.quantity
      when sm.movement_type = 'adjustment' then sm.quantity
      else 0
    end
  ), 0)
  into v_current_stock
  from public.stock_movements sm
  where sm.product_id = p_product_id;

  if p_movement_type = 'out' and v_current_stock < p_quantity then
    raise exception 'Saldo insuficiente para saida. Saldo atual: %.', v_current_stock;
  end if;

  insert into public.stock_movements (
    product_id,
    movement_type,
    quantity,
    reason,
    notes,
    created_by
  )
  values (
    p_product_id,
    p_movement_type,
    p_quantity,
    nullif(trim(p_reason), ''),
    nullif(trim(p_notes), ''),
    v_profile_id
  )
  returning *
  into v_new_movement;

  return v_new_movement;
end;
$$;

create or replace function public.delete_category_with_fallback(
  p_category_id uuid
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_fallback_category_id constant uuid := '99999999-9999-9999-9999-999999999999';
begin
  v_user_id := auth.uid();

  if v_user_id is null then
    raise exception 'Usuario nao autenticado.';
  end if;

  if not public.is_admin() then
    raise exception 'Apenas administradores podem excluir categorias.';
  end if;

  if not exists (
    select 1
    from public.categories c
    where c.id = p_category_id
  ) then
    raise exception 'Categoria nao encontrada.';
  end if;

  if p_category_id = v_fallback_category_id then
    raise exception 'A categoria padrao "Sem categoria" nao pode ser excluida.';
  end if;

  update public.products
  set
    category_id = v_fallback_category_id,
    updated_at = now()
  where category_id = p_category_id;

  delete from public.categories
  where id = p_category_id;
end;
$$;

grant execute on function public.is_admin() to authenticated;
grant execute on function public.set_user_role(uuid, public.app_role) to authenticated;
grant execute on function public.create_stock_movement(uuid, public.movement_type, integer, text, text) to authenticated;
grant execute on function public.delete_category_with_fallback(uuid) to authenticated;

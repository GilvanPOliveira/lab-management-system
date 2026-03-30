-- =========================================================
-- CATEGORY FALLBACK ON DELETE
-- =========================================================

-- Categoria padrão para fallback
insert into public.categories (
  id,
  name,
  description,
  status,
  created_by
)
values (
  '99999999-9999-9999-9999-999999999999',
  'Sem categoria',
  'Categoria padrão para produtos remanejados automaticamente.',
  'active',
  null
)
on conflict (id) do update
set
  name = excluded.name,
  description = excluded.description,
  status = excluded.status;

-- Garantir unicidade do nome também em ambientes já populados
do $$
begin
  if exists (
    select 1
    from public.categories
    where name = 'Sem categoria'
      and id <> '99999999-9999-9999-9999-999999999999'
  ) then
    raise exception 'Já existe outra categoria com o nome "Sem categoria". Ajuste os dados antes de aplicar esta migration.';
  end if;
end
$$;

-- Função segura para excluir categoria com remanejamento automático
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
  v_category_name text;
begin
  v_user_id := auth.uid();

  if v_user_id is null then
    raise exception 'Usuário não autenticado.';
  end if;

  if not public.is_admin() then
    raise exception 'Apenas administradores podem excluir categorias.';
  end if;

  select c.name
  into v_category_name
  from public.categories c
  where c.id = p_category_id;

  if not found then
    raise exception 'Categoria não encontrada.';
  end if;

  if p_category_id = v_fallback_category_id then
    raise exception 'A categoria padrão "Sem categoria" não pode ser excluída.';
  end if;

  update public.products
  set category_id = v_fallback_category_id,
      updated_at = now()
  where category_id = p_category_id;

  delete from public.categories
  where id = p_category_id;
end;
$$;

grant execute on function public.delete_category_with_fallback(uuid) to authenticated;

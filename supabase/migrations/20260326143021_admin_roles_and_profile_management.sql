-- =========================================================
-- PROFILE ENHANCEMENTS
-- =========================================================

alter table public.profiles
  add column if not exists email text;

update public.profiles p
set email = u.email
from auth.users u
where u.id = p.id
  and (p.email is null or btrim(p.email) = '');

do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'app_role'
  ) then
    create type public.app_role as enum ('admin', 'operator');
  end if;
end
$$;

alter table public.profiles
  add column if not exists app_role public.app_role not null default 'admin';

-- =========================================================
-- UPDATED HANDLE_NEW_USER
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

-- =========================================================
-- ADMIN CHECK
-- =========================================================

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

grant execute on function public.is_admin() to authenticated;

-- =========================================================
-- SAFE ROLE UPDATE FUNCTION
-- =========================================================

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
    raise exception 'Usuário não autenticado.';
  end if;

  if not public.is_admin() then
    raise exception 'Apenas administradores podem alterar papéis.';
  end if;

  if p_profile_id = v_actor_id then
    raise exception 'Não é permitido alterar o próprio papel.';
  end if;

  update public.profiles
  set app_role = p_app_role
  where id = p_profile_id
  returning *
  into v_target;

  if not found then
    raise exception 'Perfil não encontrado.';
  end if;

  return v_target;
end;
$$;

grant execute on function public.set_user_role(uuid, public.app_role) to authenticated;

-- =========================================================
-- PROFILES RLS
-- =========================================================

alter table public.profiles enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_select_admin_or_own" on public.profiles;
create policy "profiles_select_admin_or_own"
on public.profiles
for select
to authenticated
using (
  auth.uid() = id
  or public.is_admin()
);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (
  auth.uid() = id
  and app_role = (
    select p.app_role
    from public.profiles p
    where p.id = auth.uid()
  )
);

-- =========================================================
-- CATEGORIES POLICIES (ADMIN ONLY WRITE)
-- =========================================================

drop policy if exists "categories_insert_authenticated" on public.categories;
drop policy if exists "categories_update_authenticated" on public.categories;
drop policy if exists "categories_delete_authenticated" on public.categories;

create policy "categories_insert_admin_only"
on public.categories
for insert
to authenticated
with check (public.is_admin());

create policy "categories_update_admin_only"
on public.categories
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "categories_delete_admin_only"
on public.categories
for delete
to authenticated
using (public.is_admin());

-- =========================================================
-- SUPPLIERS POLICIES (ADMIN ONLY WRITE)
-- =========================================================

drop policy if exists "suppliers_insert_authenticated" on public.suppliers;
drop policy if exists "suppliers_update_authenticated" on public.suppliers;
drop policy if exists "suppliers_delete_authenticated" on public.suppliers;

create policy "suppliers_insert_admin_only"
on public.suppliers
for insert
to authenticated
with check (public.is_admin());

create policy "suppliers_update_admin_only"
on public.suppliers
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "suppliers_delete_admin_only"
on public.suppliers
for delete
to authenticated
using (public.is_admin());

-- =========================================================
-- PRODUCTS POLICIES (ADMIN ONLY WRITE)
-- =========================================================

drop policy if exists "products_insert_authenticated" on public.products;
drop policy if exists "products_update_authenticated" on public.products;
drop policy if exists "products_delete_authenticated" on public.products;

create policy "products_insert_admin_only"
on public.products
for insert
to authenticated
with check (public.is_admin());

create policy "products_update_admin_only"
on public.products
for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

create policy "products_delete_admin_only"
on public.products
for delete
to authenticated
using (public.is_admin());

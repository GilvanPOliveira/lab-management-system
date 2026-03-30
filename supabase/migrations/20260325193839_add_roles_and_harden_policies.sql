-- =========================================================
-- roles
-- =========================================================

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
-- profiles policies
-- =========================================================

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
-- categories policies
-- =========================================================

drop policy if exists "categories_update_authenticated" on public.categories;
create policy "categories_update_authenticated"
on public.categories
for update
to authenticated
using (
  public.is_admin()
  or created_by = auth.uid()
)
with check (
  public.is_admin()
  or created_by = auth.uid()
);

drop policy if exists "categories_delete_authenticated" on public.categories;
create policy "categories_delete_authenticated"
on public.categories
for delete
to authenticated
using (
  public.is_admin()
  or created_by = auth.uid()
);

-- =========================================================
-- suppliers policies
-- =========================================================

drop policy if exists "suppliers_update_authenticated" on public.suppliers;
create policy "suppliers_update_authenticated"
on public.suppliers
for update
to authenticated
using (
  public.is_admin()
  or created_by = auth.uid()
)
with check (
  public.is_admin()
  or created_by = auth.uid()
);

drop policy if exists "suppliers_delete_authenticated" on public.suppliers;
create policy "suppliers_delete_authenticated"
on public.suppliers
for delete
to authenticated
using (
  public.is_admin()
  or created_by = auth.uid()
);

-- =========================================================
-- products policies
-- =========================================================

drop policy if exists "products_update_authenticated" on public.products;
create policy "products_update_authenticated"
on public.products
for update
to authenticated
using (
  public.is_admin()
  or created_by = auth.uid()
)
with check (
  public.is_admin()
  or created_by = auth.uid()
);

drop policy if exists "products_delete_authenticated" on public.products;
create policy "products_delete_authenticated"
on public.products
for delete
to authenticated
using (
  public.is_admin()
  or created_by = auth.uid()
);

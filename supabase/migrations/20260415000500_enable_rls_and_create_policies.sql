-- =========================================================
-- RLS AND POLICIES
-- =========================================================

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.stock_movements enable row level security;

create policy "profiles_select_admin_or_own"
on public.profiles
for select
to authenticated
using (
  auth.uid() = id
  or public.is_admin()
);

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

create policy "categories_select_authenticated"
on public.categories
for select
to authenticated
using (true);

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

create policy "suppliers_select_authenticated"
on public.suppliers
for select
to authenticated
using (true);

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

create policy "products_select_authenticated"
on public.products
for select
to authenticated
using (true);

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

create policy "stock_movements_select_authenticated"
on public.stock_movements
for select
to authenticated
using (true);

create policy "stock_movements_insert_blocked"
on public.stock_movements
for insert
to authenticated
with check (false);

create policy "stock_movements_update_blocked"
on public.stock_movements
for update
to authenticated
using (false)
with check (false);

create policy "stock_movements_delete_blocked"
on public.stock_movements
for delete
to authenticated
using (false);

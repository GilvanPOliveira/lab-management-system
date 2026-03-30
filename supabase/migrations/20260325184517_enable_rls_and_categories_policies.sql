-- =========================================================
-- RLS + initial policies
-- =========================================================

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.suppliers enable row level security;
alter table public.products enable row level security;
alter table public.stock_movements enable row level security;

-- =========================================================
-- profiles policies
-- =========================================================

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own"
on public.profiles
for select
to authenticated
using (auth.uid() = id);

drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own"
on public.profiles
for update
to authenticated
using (auth.uid() = id)
with check (auth.uid() = id);

-- =========================================================
-- categories policies
-- =========================================================

drop policy if exists "categories_select_authenticated" on public.categories;
create policy "categories_select_authenticated"
on public.categories
for select
to authenticated
using (true);

drop policy if exists "categories_insert_authenticated" on public.categories;
create policy "categories_insert_authenticated"
on public.categories
for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists "categories_update_authenticated" on public.categories;
create policy "categories_update_authenticated"
on public.categories
for update
to authenticated
using (true)
with check (created_by = auth.uid() or created_by is not null);

drop policy if exists "categories_delete_authenticated" on public.categories;
create policy "categories_delete_authenticated"
on public.categories
for delete
to authenticated
using (true);

-- =========================================================
-- suppliers policies
-- =========================================================

drop policy if exists "suppliers_select_authenticated" on public.suppliers;
create policy "suppliers_select_authenticated"
on public.suppliers
for select
to authenticated
using (true);

drop policy if exists "suppliers_insert_authenticated" on public.suppliers;
create policy "suppliers_insert_authenticated"
on public.suppliers
for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists "suppliers_update_authenticated" on public.suppliers;
create policy "suppliers_update_authenticated"
on public.suppliers
for update
to authenticated
using (true)
with check (created_by = auth.uid() or created_by is not null);

drop policy if exists "suppliers_delete_authenticated" on public.suppliers;
create policy "suppliers_delete_authenticated"
on public.suppliers
for delete
to authenticated
using (true);

-- =========================================================
-- products policies
-- =========================================================

drop policy if exists "products_select_authenticated" on public.products;
create policy "products_select_authenticated"
on public.products
for select
to authenticated
using (true);

drop policy if exists "products_insert_authenticated" on public.products;
create policy "products_insert_authenticated"
on public.products
for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists "products_update_authenticated" on public.products;
create policy "products_update_authenticated"
on public.products
for update
to authenticated
using (true)
with check (created_by = auth.uid() or created_by is not null);

drop policy if exists "products_delete_authenticated" on public.products;
create policy "products_delete_authenticated"
on public.products
for delete
to authenticated
using (true);

-- =========================================================
-- stock_movements policies
-- =========================================================

drop policy if exists "stock_movements_select_authenticated" on public.stock_movements;
create policy "stock_movements_select_authenticated"
on public.stock_movements
for select
to authenticated
using (true);

drop policy if exists "stock_movements_insert_authenticated" on public.stock_movements;
create policy "stock_movements_insert_authenticated"
on public.stock_movements
for insert
to authenticated
with check (created_by = auth.uid());

drop policy if exists "stock_movements_update_blocked" on public.stock_movements;
create policy "stock_movements_update_blocked"
on public.stock_movements
for update
to authenticated
using (false)
with check (false);

drop policy if exists "stock_movements_delete_blocked" on public.stock_movements;
create policy "stock_movements_delete_blocked"
on public.stock_movements
for delete
to authenticated
using (false);

-- =========================================================
-- LAB MANAGEMENT SYSTEM
-- Initial schema
-- =========================================================

-- Extensions
create extension if not exists pgcrypto;

-- =========================================================
-- updated_at helper
-- =========================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =========================================================
-- enums
-- =========================================================
do $$
begin
  if not exists (
    select 1
    from pg_type
    where typname = 'record_status'
  ) then
    create type public.record_status as enum ('active', 'inactive');
  end if;

  if not exists (
    select 1
    from pg_type
    where typname = 'movement_type'
  ) then
    create type public.movement_type as enum ('in', 'out', 'adjustment');
  end if;
end
$$;

-- =========================================================
-- profiles
-- =========================================================
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'admin',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger trg_profiles_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

-- =========================================================
-- categories
-- =========================================================
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  status public.record_status not null default 'active',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint categories_name_unique unique (name)
);

create index if not exists idx_categories_status
  on public.categories(status);

create trigger trg_categories_updated_at
before update on public.categories
for each row
execute function public.set_updated_at();

-- =========================================================
-- suppliers
-- =========================================================
create table if not exists public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  contact_name text,
  email text,
  phone text,
  document text,
  notes text,
  status public.record_status not null default 'active',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint suppliers_name_unique unique (name)
);

create index if not exists idx_suppliers_status
  on public.suppliers(status);

create trigger trg_suppliers_updated_at
before update on public.suppliers
for each row
execute function public.set_updated_at();

-- =========================================================
-- products
-- =========================================================
create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sku text not null,
  description text,
  category_id uuid not null references public.categories(id) on delete restrict,
  supplier_id uuid references public.suppliers(id) on delete set null,
  unit text not null default 'un',
  minimum_stock integer not null default 0,
  status public.record_status not null default 'active',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint products_sku_unique unique (sku),
  constraint products_minimum_stock_non_negative check (minimum_stock >= 0)
);

create index if not exists idx_products_category_id
  on public.products(category_id);

create index if not exists idx_products_supplier_id
  on public.products(supplier_id);

create index if not exists idx_products_status
  on public.products(status);

create trigger trg_products_updated_at
before update on public.products
for each row
execute function public.set_updated_at();

-- =========================================================
-- stock_movements
-- =========================================================
create table if not exists public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  movement_type public.movement_type not null,
  quantity integer not null,
  reason text,
  notes text,
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now(),
  constraint stock_movements_quantity_positive check (quantity > 0)
);

create index if not exists idx_stock_movements_product_id
  on public.stock_movements(product_id);

create index if not exists idx_stock_movements_type
  on public.stock_movements(movement_type);

create index if not exists idx_stock_movements_created_at
  on public.stock_movements(created_at desc);

-- =========================================================
-- current stock view
-- =========================================================
create or replace view public.product_stock_summary as
select
  p.id as product_id,
  p.name,
  p.sku,
  p.status,
  coalesce(sum(
    case
      when sm.movement_type = 'in' then sm.quantity
      when sm.movement_type = 'out' then -sm.quantity
      when sm.movement_type = 'adjustment' then sm.quantity
      else 0
    end
  ), 0) as current_stock,
  p.minimum_stock
from public.products p
left join public.stock_movements sm on sm.product_id = p.id
group by p.id, p.name, p.sku, p.status, p.minimum_stock;

-- =========================================================
-- auto profile creation
-- =========================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'full_name', '')
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;

create trigger on_auth_user_created
after insert on auth.users
for each row
execute function public.handle_new_user();

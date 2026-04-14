-- =========================================================
-- CORE TABLES
-- =========================================================

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  email text,
  role text not null default 'admin',
  app_role public.app_role not null default 'admin',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.categories (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  description text,
  status public.record_status not null default 'active',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.suppliers (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  contact_name text,
  email text,
  phone text,
  document text,
  notes text,
  status public.record_status not null default 'active',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sku text not null unique,
  description text,
  category_id uuid not null references public.categories(id) on delete restrict,
  supplier_id uuid references public.suppliers(id) on delete set null,
  unit text not null default 'un',
  minimum_stock integer not null default 0 check (minimum_stock >= 0),
  status public.record_status not null default 'active',
  created_by uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.stock_movements (
  id uuid primary key default gen_random_uuid(),
  product_id uuid not null references public.products(id) on delete restrict,
  movement_type public.movement_type not null,
  quantity integer not null check (quantity > 0),
  reason text,
  notes text,
  created_by uuid not null references public.profiles(id) on delete restrict,
  created_at timestamptz not null default now()
);

create index idx_categories_status on public.categories(status);
create index idx_suppliers_status on public.suppliers(status);
create index idx_products_category_id on public.products(category_id);
create index idx_products_supplier_id on public.products(supplier_id);
create index idx_products_status on public.products(status);
create index idx_stock_movements_product_id on public.stock_movements(product_id);
create index idx_stock_movements_type on public.stock_movements(movement_type);
create index idx_stock_movements_created_at on public.stock_movements(created_at desc);

create trigger trg_profiles_updated_at
before update on public.profiles
for each row
execute function public.set_updated_at();

create trigger trg_categories_updated_at
before update on public.categories
for each row
execute function public.set_updated_at();

create trigger trg_suppliers_updated_at
before update on public.suppliers
for each row
execute function public.set_updated_at();

create trigger trg_products_updated_at
before update on public.products
for each row
execute function public.set_updated_at();

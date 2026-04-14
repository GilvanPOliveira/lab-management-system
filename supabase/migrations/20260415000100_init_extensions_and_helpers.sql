-- =========================================================
-- EXTENSIONS AND HELPERS
-- =========================================================

create extension if not exists pgcrypto;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'record_status') then
    create type public.record_status as enum ('active', 'inactive');
  end if;

  if not exists (select 1 from pg_type where typname = 'movement_type') then
    create type public.movement_type as enum ('in', 'out', 'adjustment');
  end if;

  if not exists (select 1 from pg_type where typname = 'app_role') then
    create type public.app_role as enum ('admin', 'operator');
  end if;
end
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =========================================================
-- SECURITY ADJUSTMENTS
-- =========================================================

drop policy if exists "categories_update_authenticated" on public.categories;
create policy "categories_update_authenticated"
on public.categories
for update
to authenticated
using (created_by = auth.uid() or created_by is null)
with check (created_by = auth.uid() or created_by is null);

drop policy if exists "categories_delete_authenticated" on public.categories;
create policy "categories_delete_authenticated"
on public.categories
for delete
to authenticated
using (created_by = auth.uid() or created_by is null);

drop policy if exists "suppliers_update_authenticated" on public.suppliers;
create policy "suppliers_update_authenticated"
on public.suppliers
for update
to authenticated
using (created_by = auth.uid() or created_by is null)
with check (created_by = auth.uid() or created_by is null);

drop policy if exists "suppliers_delete_authenticated" on public.suppliers;
create policy "suppliers_delete_authenticated"
on public.suppliers
for delete
to authenticated
using (created_by = auth.uid() or created_by is null);

drop policy if exists "products_update_authenticated" on public.products;
create policy "products_update_authenticated"
on public.products
for update
to authenticated
using (created_by = auth.uid() or created_by is null)
with check (created_by = auth.uid() or created_by is null);

drop policy if exists "products_delete_authenticated" on public.products;
create policy "products_delete_authenticated"
on public.products
for delete
to authenticated
using (created_by = auth.uid() or created_by is null);

drop policy if exists "stock_movements_insert_authenticated" on public.stock_movements;
create policy "stock_movements_insert_blocked"
on public.stock_movements
for insert
to authenticated
with check (false);

-- =========================================================
-- STOCK MOVEMENT FUNCTION
-- =========================================================

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
    raise exception 'Usuário não autenticado.';
  end if;

  select p.*
  into v_product
  from public.products p
  where p.id = p_product_id;

  if not found then
    raise exception 'Produto não encontrado.';
  end if;

  if v_product.status <> 'active' then
    raise exception 'Produto inativo não pode receber movimentações.';
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
    raise exception 'Perfil do usuário não encontrado.';
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
    raise exception 'Saldo insuficiente para saída. Saldo atual: %.', v_current_stock;
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

grant execute on function public.create_stock_movement(uuid, public.movement_type, integer, text, text)
to authenticated;

-- =========================================================
-- SEED DATA
-- =========================================================

insert into public.categories (id, name, description, status, created_by)
values
  ('11111111-1111-1111-1111-111111111111', 'Eletrônicos', 'Componentes, periféricos e itens eletrônicos.', 'active', null),
  ('22222222-2222-2222-2222-222222222222', 'Escritório', 'Materiais de uso administrativo e organizacional.', 'active', null),
  ('33333333-3333-3333-3333-333333333333', 'Ferramentas', 'Ferramentas e utensílios operacionais.', 'active', null),
  ('44444444-4444-4444-4444-444444444444', 'Limpeza', 'Itens de limpeza e manutenção do ambiente.', 'active', null),
  ('55555555-5555-5555-5555-555555555555', 'Segurança', 'EPIs e itens relacionados à segurança.', 'active', null)
on conflict (id) do update
set
  name = excluded.name,
  description = excluded.description,
  status = excluded.status;

insert into public.suppliers (id, name, contact_name, email, phone, document, notes, status, created_by)
values
  ('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'Tech Supply Brasil', 'Marina Costa', 'contato@techsupply.com', '(81) 99999-1001', '12.345.678/0001-10', 'Fornecedor de eletrônicos e periféricos.', 'active', null),
  ('aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'Office Max PE', 'Carlos Lima', 'vendas@officemaxpe.com', '(81) 99999-1002', '23.456.789/0001-20', 'Fornecedor de materiais administrativos.', 'active', null),
  ('aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'Ferramentas Nordeste', 'Paula Mendes', 'comercial@ferramentasnordeste.com', '(81) 99999-1003', '34.567.890/0001-30', 'Fornecedor de ferramentas operacionais.', 'active', null),
  ('aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'Higieniza PE', 'Roberto Silva', 'atendimento@higienizape.com', '(81) 99999-1004', '45.678.901/0001-40', 'Fornecedor de materiais de limpeza.', 'active', null)
on conflict (id) do update
set
  name = excluded.name,
  contact_name = excluded.contact_name,
  email = excluded.email,
  phone = excluded.phone,
  document = excluded.document,
  notes = excluded.notes,
  status = excluded.status;

insert into public.products (
  id,
  name,
  sku,
  description,
  category_id,
  supplier_id,
  unit,
  minimum_stock,
  status,
  created_by
)
values
  (
    'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
    'Mouse USB Office',
    'MOU-USB-001',
    'Mouse óptico USB para estações administrativas.',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'un',
    10,
    'active',
    null
  ),
  (
    'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
    'Teclado ABNT2',
    'TEC-ABNT2-001',
    'Teclado padrão ABNT2 para uso interno.',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'un',
    8,
    'active',
    null
  ),
  (
    'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
    'Resma A4 500 folhas',
    'PAP-A4-500',
    'Papel sulfite A4 para impressão e uso geral.',
    '22222222-2222-2222-2222-222222222222',
    'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    'pct',
    15,
    'active',
    null
  ),
  (
    'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4',
    'Chave de Fenda 1/4',
    'FER-CHV-001',
    'Ferramenta manual para manutenção simples.',
    '33333333-3333-3333-3333-333333333333',
    'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'un',
    4,
    'active',
    null
  ),
  (
    'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5',
    'Detergente Neutro 500ml',
    'LMP-DTG-500',
    'Produto de limpeza para uso geral.',
    '44444444-4444-4444-4444-444444444444',
    'aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
    'un',
    12,
    'active',
    null
  ),
  (
    'bbbbbbb6-bbbb-bbbb-bbbb-bbbbbbbbbbb6',
    'Luva de Proteção',
    'SEG-LUV-001',
    'Item básico de proteção para atividades operacionais.',
    '55555555-5555-5555-5555-555555555555',
    null,
    'par',
    20,
    'active',
    null
  )
on conflict (id) do update
set
  name = excluded.name,
  sku = excluded.sku,
  description = excluded.description,
  category_id = excluded.category_id,
  supplier_id = excluded.supplier_id,
  unit = excluded.unit,
  minimum_stock = excluded.minimum_stock,
  status = excluded.status;

do $$
declare
  v_profile_id uuid;
begin
  select id
  into v_profile_id
  from public.profiles
  limit 1;

  if v_profile_id is not null then
    insert into public.stock_movements (
      id,
      product_id,
      movement_type,
      quantity,
      reason,
      notes,
      created_by
    )
    values
      (
        'ccccccc1-cccc-cccc-cccc-ccccccccccc1',
        'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
        'in',
        25,
        'Estoque inicial',
        'Carga inicial de teste',
        v_profile_id
      ),
      (
        'ccccccc2-cccc-cccc-cccc-ccccccccccc2',
        'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
        'in',
        18,
        'Estoque inicial',
        'Carga inicial de teste',
        v_profile_id
      ),
      (
        'ccccccc3-cccc-cccc-cccc-ccccccccccc3',
        'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
        'in',
        40,
        'Estoque inicial',
        'Carga inicial de teste',
        v_profile_id
      ),
      (
        'ccccccc4-cccc-cccc-cccc-ccccccccccc4',
        'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4',
        'in',
        10,
        'Estoque inicial',
        'Carga inicial de teste',
        v_profile_id
      ),
      (
        'ccccccc5-cccc-cccc-cccc-ccccccccccc5',
        'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5',
        'in',
        30,
        'Estoque inicial',
        'Carga inicial de teste',
        v_profile_id
      ),
      (
        'ccccccc6-cccc-cccc-cccc-ccccccccccc6',
        'bbbbbbb6-bbbb-bbbb-bbbb-bbbbbbbbbbb6',
        'in',
        50,
        'Estoque inicial',
        'Carga inicial de teste',
        v_profile_id
      )
    on conflict (id) do nothing;
  end if;
end $$;

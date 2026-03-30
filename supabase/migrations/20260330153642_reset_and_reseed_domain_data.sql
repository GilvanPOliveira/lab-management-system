-- =========================================================
-- RESET AND RESEED DOMAIN DATA
-- =========================================================

do $$
declare
  v_profile_id uuid;
  v_fallback_category_id constant uuid := '99999999-9999-9999-9999-999999999999';
begin
  -- Garantir que existe pelo menos um perfil para atribuir created_by
  select id
  into v_profile_id
  from public.profiles
  order by created_at asc
  limit 1;

  if v_profile_id is null then
    raise exception 'Nenhum profile encontrado. Crie ao menos um usuário autenticado antes de aplicar esta migration.';
  end if;

  -- =========================================================
  -- LIMPEZA DOS DADOS DE DOMÍNIO
  -- =========================================================

  delete from public.stock_movements;
  delete from public.products;
  delete from public.suppliers;
  delete from public.categories;

  -- =========================================================
  -- CATEGORIAS
  -- =========================================================

  insert into public.categories (
    id,
    name,
    description,
    status,
    created_by
  )
  values
    (
      v_fallback_category_id,
      'Sem categoria',
      'Categoria padrão para produtos remanejados automaticamente.',
      'active',
      null
    ),
    (
      '11111111-1111-1111-1111-111111111111',
      'Eletrônicos',
      'Periféricos, componentes e acessórios eletrônicos.',
      'active',
      v_profile_id
    ),
    (
      '22222222-2222-2222-2222-222222222222',
      'Escritório',
      'Materiais de escritório, organização e papelaria.',
      'active',
      v_profile_id
    ),
    (
      '33333333-3333-3333-3333-333333333333',
      'Ferramentas',
      'Ferramentas e utensílios de manutenção.',
      'active',
      v_profile_id
    ),
    (
      '44444444-4444-4444-4444-444444444444',
      'Limpeza',
      'Produtos e itens de limpeza operacional.',
      'active',
      v_profile_id
    ),
    (
      '55555555-5555-5555-5555-555555555555',
      'Segurança',
      'EPIs e itens de segurança.',
      'active',
      v_profile_id
    ),
    (
      '66666666-6666-6666-6666-666666666666',
      'Arquivo',
      'Itens antigos ou em processo de descontinuação.',
      'inactive',
      v_profile_id
    );

  -- =========================================================
  -- FORNECEDORES
  -- =========================================================

  insert into public.suppliers (
    id,
    name,
    contact_name,
    email,
    phone,
    document,
    notes,
    status,
    created_by
  )
  values
    (
      'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
      'Tech Supply Brasil',
      'Marina Costa',
      'contato@techsupply.com',
      '(81) 99999-1001',
      '12.345.678/0001-10',
      'Fornecedor de eletrônicos e periféricos.',
      'active',
      v_profile_id
    ),
    (
      'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
      'Office Max PE',
      'Carlos Lima',
      'vendas@officemaxpe.com',
      '(81) 99999-1002',
      '23.456.789/0001-20',
      'Fornecedor de materiais administrativos.',
      'active',
      v_profile_id
    ),
    (
      'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
      'Ferramentas Nordeste',
      'Paula Mendes',
      'comercial@ferramentasnordeste.com',
      '(81) 99999-1003',
      '34.567.890/0001-30',
      'Fornecedor de ferramentas operacionais.',
      'active',
      v_profile_id
    ),
    (
      'aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
      'Higieniza PE',
      'Roberto Silva',
      'atendimento@higienizape.com',
      '(81) 99999-1004',
      '45.678.901/0001-40',
      'Fornecedor de materiais de limpeza.',
      'active',
      v_profile_id
    ),
    (
      'aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
      'Safe Equip',
      'Juliana Rocha',
      'comercial@safeequip.com',
      '(81) 99999-1005',
      '56.789.012/0001-50',
      'Fornecedor de EPIs.',
      'active',
      v_profile_id
    ),
    (
      'aaaaaaa6-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
      'Fornecedor Legado',
      'Contato Antigo',
      'legado@fornecedor.com',
      '(81) 99999-1006',
      '67.890.123/0001-60',
      'Fornecedor inativo para testes.',
      'inactive',
      v_profile_id
    );

  -- =========================================================
  -- PRODUTOS
  -- =========================================================

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
      v_profile_id
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
      v_profile_id
    ),
    (
      'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
      'Monitor 24 Polegadas',
      'MON-24-001',
      'Monitor LED para estação de trabalho.',
      '11111111-1111-1111-1111-111111111111',
      'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
      'un',
      4,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4',
      'Resma A4 500 folhas',
      'PAP-A4-500',
      'Papel sulfite A4 para impressão e uso geral.',
      '22222222-2222-2222-2222-222222222222',
      'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
      'pct',
      15,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5',
      'Caneta Azul',
      'CAN-AZ-001',
      'Caneta esferográfica azul.',
      '22222222-2222-2222-2222-222222222222',
      'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
      'cx',
      6,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbb6-bbbb-bbbb-bbbb-bbbbbbbbbbb6',
      'Chave de Fenda 1/4',
      'FER-CHV-001',
      'Ferramenta manual para manutenção simples.',
      '33333333-3333-3333-3333-333333333333',
      'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
      'un',
      4,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbb7-bbbb-bbbb-bbbb-bbbbbbbbbbb7',
      'Furadeira Compacta',
      'FER-FUR-001',
      'Furadeira para manutenção leve.',
      '33333333-3333-3333-3333-333333333333',
      'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
      'un',
      2,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbb8-bbbb-bbbb-bbbb-bbbbbbbbbbb8',
      'Detergente Neutro 500ml',
      'LMP-DTG-500',
      'Produto de limpeza para uso geral.',
      '44444444-4444-4444-4444-444444444444',
      'aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
      'un',
      12,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbb9-bbbb-bbbb-bbbb-bbbbbbbbbbb9',
      'Álcool 70%',
      'LMP-ALC-070',
      'Álcool para higienização.',
      '44444444-4444-4444-4444-444444444444',
      'aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
      'un',
      10,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbb0-bbbb-bbbb-bbbb-bbbbbbbbbbb0',
      'Luva de Proteção',
      'SEG-LUV-001',
      'Item básico de proteção para atividades operacionais.',
      '55555555-5555-5555-5555-555555555555',
      'aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
      'par',
      20,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbc1-bbbb-bbbb-bbbb-bbbbbbbbbbc1',
      'Óculos de Segurança',
      'SEG-OCU-001',
      'Óculos de proteção individual.',
      '55555555-5555-5555-5555-555555555555',
      'aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
      'un',
      8,
      'active',
      v_profile_id
    ),
    (
      'bbbbbbc2-bbbb-bbbb-bbbb-bbbbbbbbbbc2',
      'Scanner Antigo',
      'ARQ-SCN-001',
      'Equipamento antigo mantido apenas para histórico.',
      '66666666-6666-6666-6666-666666666666',
      'aaaaaaa6-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
      'un',
      1,
      'inactive',
      v_profile_id
    ),
    (
      'bbbbbbc3-bbbb-bbbb-bbbb-bbbbbbbbbbc3',
      'Item Recebido sem Classificação',
      'SEM-CAT-001',
      'Produto propositalmente alocado em Sem categoria para testes.',
      v_fallback_category_id,
      null,
      'un',
      3,
      'active',
      v_profile_id
    );

  -- =========================================================
  -- MOVIMENTAÇÕES
  -- =========================================================

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
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'ccccccc2-cccc-cccc-cccc-ccccccccccc2',
      'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1',
      'out',
      5,
      'Consumo interno',
      'Distribuição para equipe administrativa',
      v_profile_id
    ),
    (
      'ccccccc3-cccc-cccc-cccc-ccccccccccc3',
      'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
      'in',
      18,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'ccccccc4-cccc-cccc-cccc-ccccccccccc4',
      'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2',
      'adjustment',
      2,
      'Correção de contagem',
      'Ajuste positivo após inventário',
      v_profile_id
    ),
    (
      'ccccccc5-cccc-cccc-cccc-ccccccccccc5',
      'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
      'in',
      6,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'ccccccc6-cccc-cccc-cccc-ccccccccccc6',
      'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
      'out',
      2,
      'Instalação',
      'Entrega para nova estação',
      v_profile_id
    ),
    (
      'ccccccc7-cccc-cccc-cccc-ccccccccccc7',
      'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4',
      'in',
      40,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'ccccccc8-cccc-cccc-cccc-ccccccccccc8',
      'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4',
      'out',
      28,
      'Uso mensal',
      'Consumo administrativo',
      v_profile_id
    ),
    (
      'ccccccc9-cccc-cccc-cccc-ccccccccccc9',
      'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5',
      'in',
      10,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'cccccc10-cccc-cccc-cccc-cccccccccc10',
      'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5',
      'out',
      4,
      'Uso interno',
      'Distribuição entre setores',
      v_profile_id
    ),
    (
      'cccccc11-cccc-cccc-cccc-cccccccccc11',
      'bbbbbbb6-bbbb-bbbb-bbbb-bbbbbbbbbbb6',
      'in',
      10,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'cccccc12-cccc-cccc-cccc-cccccccccc12',
      'bbbbbbb6-bbbb-bbbb-bbbb-bbbbbbbbbbb6',
      'out',
      7,
      'Manutenção',
      'Uso em atendimento técnico',
      v_profile_id
    ),
    (
      'cccccc13-cccc-cccc-cccc-cccccccccc13',
      'bbbbbbb7-bbbb-bbbb-bbbb-bbbbbbbbbbb7',
      'in',
      3,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'cccccc14-cccc-cccc-cccc-cccccccccc14',
      'bbbbbbb7-bbbb-bbbb-bbbb-bbbbbbbbbbb7',
      'out',
      1,
      'Uso em campo',
      'Equipamento emprestado para manutenção',
      v_profile_id
    ),
    (
      'cccccc15-cccc-cccc-cccc-cccccccccc15',
      'bbbbbbb8-bbbb-bbbb-bbbb-bbbbbbbbbbb8',
      'in',
      30,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'cccccc16-cccc-cccc-cccc-cccccccccc16',
      'bbbbbbb8-bbbb-bbbb-bbbb-bbbbbbbbbbb8',
      'out',
      20,
      'Reposição de limpeza',
      'Distribuição para áreas comuns',
      v_profile_id
    ),
    (
      'cccccc17-cccc-cccc-cccc-cccccccccc17',
      'bbbbbbb9-bbbb-bbbb-bbbb-bbbbbbbbbbb9',
      'in',
      15,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'cccccc18-cccc-cccc-cccc-cccccccccc18',
      'bbbbbbb9-bbbb-bbbb-bbbb-bbbbbbbbbbb9',
      'out',
      6,
      'Uso operacional',
      'Higienização de postos',
      v_profile_id
    ),
    (
      'cccccc19-cccc-cccc-cccc-cccccccccc19',
      'bbbbbbb0-bbbb-bbbb-bbbb-bbbbbbbbbbb0',
      'in',
      50,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'cccccc20-cccc-cccc-cccc-cccccccccc20',
      'bbbbbbb0-bbbb-bbbb-bbbb-bbbbbbbbbbb0',
      'out',
      35,
      'Distribuição',
      'Entrega para equipe operacional',
      v_profile_id
    ),
    (
      'cccccc21-cccc-cccc-cccc-cccccccccc21',
      'bbbbbbc1-bbbb-bbbb-bbbb-bbbbbbbbbbc1',
      'in',
      12,
      'Estoque inicial',
      'Carga inicial do sistema',
      v_profile_id
    ),
    (
      'cccccc22-cccc-cccc-cccc-cccccccccc22',
      'bbbbbbc1-bbbb-bbbb-bbbb-bbbbbbbbbbc1',
      'out',
      5,
      'Distribuição',
      'Entrega para novos colaboradores',
      v_profile_id
    ),
    (
      'cccccc23-cccc-cccc-cccc-cccccccccc23',
      'bbbbbbc3-bbbb-bbbb-bbbb-bbbbbbbbbbc3',
      'in',
      4,
      'Recebimento sem classificação',
      'Produto mantido em categoria padrão',
      v_profile_id
    );

end $$;

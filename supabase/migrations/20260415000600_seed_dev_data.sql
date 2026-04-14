-- =========================================================
-- DOMAIN DEFAULTS
-- =========================================================

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
  'Categoria padrao para produtos remanejados automaticamente.',
  'active',
  null
);

-- =========================================================
-- DEVELOPMENT DATA
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
    '11111111-1111-1111-1111-111111111111',
    'Eletronicos',
    'Perifericos, componentes e acessorios eletronicos.',
    'active',
    null
  ),
  (
    '22222222-2222-2222-2222-222222222222',
    'Escritorio',
    'Materiais de escritorio, organizacao e papelaria.',
    'active',
    null
  ),
  (
    '33333333-3333-3333-3333-333333333333',
    'Ferramentas',
    'Ferramentas e utensilios de manutencao.',
    'active',
    null
  ),
  (
    '44444444-4444-4444-4444-444444444444',
    'Limpeza',
    'Produtos e itens de limpeza operacional.',
    'active',
    null
  ),
  (
    '55555555-5555-5555-5555-555555555555',
    'Seguranca',
    'EPIs e itens de seguranca.',
    'active',
    null
  ),
  (
    '66666666-6666-6666-6666-666666666666',
    'Arquivo',
    'Itens antigos ou em processo de descontinuacao.',
    'inactive',
    null
  );

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
    'Fornecedor de eletronicos e perifericos.',
    'active',
    null
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
    null
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
    null
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
    null
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
    null
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
    null
  );

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
    'Mouse optico USB para estacoes administrativas.',
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
    'Teclado padrao ABNT2 para uso interno.',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'un',
    8,
    'active',
    null
  ),
  (
    'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3',
    'Monitor 24 Polegadas',
    'MON-24-001',
    'Monitor LED para estacao de trabalho.',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1',
    'un',
    4,
    'active',
    null
  ),
  (
    'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4',
    'Resma A4 500 folhas',
    'PAP-A4-500',
    'Papel sulfite A4 para impressao e uso geral.',
    '22222222-2222-2222-2222-222222222222',
    'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    'pct',
    15,
    'active',
    null
  ),
  (
    'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5',
    'Caneta Azul',
    'CAN-AZ-001',
    'Caneta esferografica azul.',
    '22222222-2222-2222-2222-222222222222',
    'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2',
    'cx',
    6,
    'active',
    null
  ),
  (
    'bbbbbbb6-bbbb-bbbb-bbbb-bbbbbbbbbbb6',
    'Chave de Fenda 1/4',
    'FER-CHV-001',
    'Ferramenta manual para manutencao simples.',
    '33333333-3333-3333-3333-333333333333',
    'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'un',
    4,
    'active',
    null
  ),
  (
    'bbbbbbb7-bbbb-bbbb-bbbb-bbbbbbbbbbb7',
    'Furadeira Compacta',
    'FER-FUR-001',
    'Furadeira para manutencao leve.',
    '33333333-3333-3333-3333-333333333333',
    'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3',
    'un',
    2,
    'active',
    null
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
    null
  ),
  (
    'bbbbbbb9-bbbb-bbbb-bbbb-bbbbbbbbbbb9',
    'Alcool 70%',
    'LMP-ALC-070',
    'Alcool para higienizacao.',
    '44444444-4444-4444-4444-444444444444',
    'aaaaaaa4-aaaa-aaaa-aaaa-aaaaaaaaaaa4',
    'un',
    10,
    'active',
    null
  ),
  (
    'bbbbbbb0-bbbb-bbbb-bbbb-bbbbbbbbbbb0',
    'Luva de Protecao',
    'SEG-LUV-001',
    'Item basico de protecao para atividades operacionais.',
    '55555555-5555-5555-5555-555555555555',
    'aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
    'par',
    20,
    'active',
    null
  ),
  (
    'bbbbbbc1-bbbb-bbbb-bbbb-bbbbbbbbbbc1',
    'Oculos de Seguranca',
    'SEG-OCU-001',
    'Oculos de protecao individual.',
    '55555555-5555-5555-5555-555555555555',
    'aaaaaaa5-aaaa-aaaa-aaaa-aaaaaaaaaaa5',
    'un',
    8,
    'active',
    null
  ),
  (
    'bbbbbbc2-bbbb-bbbb-bbbb-bbbbbbbbbbc2',
    'Scanner Antigo',
    'ARQ-SCN-001',
    'Equipamento antigo mantido apenas para historico.',
    '66666666-6666-6666-6666-666666666666',
    'aaaaaaa6-aaaa-aaaa-aaaa-aaaaaaaaaaa6',
    'un',
    1,
    'inactive',
    null
  ),
  (
    'bbbbbbc3-bbbb-bbbb-bbbb-bbbbbbbbbbc3',
    'Item Recebido sem Classificacao',
    'SEM-CAT-001',
    'Produto propositalmente alocado em Sem categoria para testes.',
    '99999999-9999-9999-9999-999999999999',
    null,
    'un',
    3,
    'active',
    null
  );

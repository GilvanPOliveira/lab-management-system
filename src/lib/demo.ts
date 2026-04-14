import type { Category, CreateCategoryPayload, UpdateCategoryPayload } from '../types/category'
import type { AppRole, ProfileRow, StockMovementRow } from '../types/database'
import type { AppSession, AppUser } from '../types/auth'
import type { CreateMovementPayload, MovementWithProduct } from '../types/movement'
import type { CreateProductPayload, Product, ProductStockSummary, UpdateProductPayload } from '../types/product'
import type { CreateSupplierPayload, Supplier, UpdateSupplierPayload } from '../types/supplier'

const DB_KEY = 'lab-management-demo-db-v1'
const SESSION_KEY = 'lab-management-demo-session-v1'
export const DEMO_FALLBACK_CATEGORY_ID = '99999999-9999-9999-9999-999999999999'

interface DemoCredential {
  email: string
  password: string
  profile_id: string
}

interface DemoDatabase {
  profiles: ProfileRow[]
  categories: Category[]
  suppliers: Supplier[]
  products: Product[]
  stock_movements: StockMovementRow[]
  credentials: DemoCredential[]
}

function cloneValue<T>(value: T): T {
  return JSON.parse(JSON.stringify(value)) as T
}

function canUseStorage() {
  return typeof window !== 'undefined' && typeof window.localStorage !== 'undefined'
}

function nowIso() {
  return new Date().toISOString()
}

function sortByCreatedAtDesc<T extends { created_at: string }>(items: T[]) {
  return [...items].sort((a, b) => b.created_at.localeCompare(a.created_at))
}

function sortByNameAsc<T extends { name: string }>(items: T[]) {
  return [...items].sort((a, b) => a.name.localeCompare(b.name))
}

function normalizeText(value: string | null | undefined) {
  return value?.trim() ?? ''
}

function buildDemoDatabase(): DemoDatabase {
  const adminId = '00000000-0000-0000-0000-000000000001'
  const operatorId = '00000000-0000-0000-0000-000000000002'

  return {
    profiles: [
      { id: adminId, full_name: 'Admin Demo', email: 'admin.demo@lab.local', role: 'admin', app_role: 'admin', created_at: '2026-04-01T09:00:00.000Z', updated_at: '2026-04-01T09:00:00.000Z' },
      { id: operatorId, full_name: 'Operador Demo', email: 'operador.demo@lab.local', role: 'operator', app_role: 'operator', created_at: '2026-04-01T09:10:00.000Z', updated_at: '2026-04-01T09:10:00.000Z' },
    ],
    credentials: [
      { email: 'admin.demo@lab.local', password: 'demo123', profile_id: adminId },
      { email: 'operador.demo@lab.local', password: 'demo123', profile_id: operatorId },
    ],
    categories: [
      { id: DEMO_FALLBACK_CATEGORY_ID, name: 'Sem categoria', description: 'Categoria padrao para remanejamento automatico.', status: 'active', created_by: null, created_at: '2026-04-01T09:20:00.000Z', updated_at: '2026-04-01T09:20:00.000Z' },
      { id: '11111111-1111-1111-1111-111111111111', name: 'Eletronicos', description: 'Perifericos e acessorios eletronicos.', status: 'active', created_by: adminId, created_at: '2026-04-01T09:21:00.000Z', updated_at: '2026-04-01T09:21:00.000Z' },
      { id: '22222222-2222-2222-2222-222222222222', name: 'Escritorio', description: 'Itens administrativos e papelaria.', status: 'active', created_by: adminId, created_at: '2026-04-01T09:22:00.000Z', updated_at: '2026-04-01T09:22:00.000Z' },
      { id: '33333333-3333-3333-3333-333333333333', name: 'Limpeza', description: 'Produtos de limpeza e manutencao.', status: 'active', created_by: adminId, created_at: '2026-04-01T09:23:00.000Z', updated_at: '2026-04-01T09:23:00.000Z' },
    ],
    suppliers: [
      { id: 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', name: 'Tech Supply Brasil', contact_name: 'Marina Costa', email: 'contato@techsupply.com', phone: '(81) 99999-1001', document: '12.345.678/0001-10', notes: 'Fornecedor demo de eletronicos.', status: 'active', created_by: adminId, created_at: '2026-04-01T09:30:00.000Z', updated_at: '2026-04-01T09:30:00.000Z' },
      { id: 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', name: 'Office Max PE', contact_name: 'Carlos Lima', email: 'vendas@officemaxpe.com', phone: '(81) 99999-1002', document: '23.456.789/0001-20', notes: 'Fornecedor demo de escritorio.', status: 'active', created_by: adminId, created_at: '2026-04-01T09:31:00.000Z', updated_at: '2026-04-01T09:31:00.000Z' },
      { id: 'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3', name: 'Higieniza PE', contact_name: 'Roberto Silva', email: 'atendimento@higienizape.com', phone: '(81) 99999-1003', document: '45.678.901/0001-40', notes: 'Fornecedor demo de limpeza.', status: 'active', created_by: adminId, created_at: '2026-04-01T09:32:00.000Z', updated_at: '2026-04-01T09:32:00.000Z' },
    ],
    products: [
      { id: 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1', name: 'Mouse USB Office', sku: 'MOU-USB-001', description: 'Mouse optico USB para estacoes administrativas.', category_id: '11111111-1111-1111-1111-111111111111', supplier_id: 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', unit: 'un', minimum_stock: 10, status: 'active', created_by: adminId, created_at: '2026-04-01T09:40:00.000Z', updated_at: '2026-04-01T09:40:00.000Z' },
      { id: 'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2', name: 'Teclado ABNT2', sku: 'TEC-ABNT2-001', description: 'Teclado padrao para uso interno.', category_id: '11111111-1111-1111-1111-111111111111', supplier_id: 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', unit: 'un', minimum_stock: 8, status: 'active', created_by: adminId, created_at: '2026-04-01T09:41:00.000Z', updated_at: '2026-04-01T09:41:00.000Z' },
      { id: 'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3', name: 'Resma A4 500 folhas', sku: 'PAP-A4-500', description: 'Papel sulfite A4 para impressao.', category_id: '22222222-2222-2222-2222-222222222222', supplier_id: 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', unit: 'pct', minimum_stock: 15, status: 'active', created_by: adminId, created_at: '2026-04-01T09:42:00.000Z', updated_at: '2026-04-01T09:42:00.000Z' },
      { id: 'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4', name: 'Detergente Neutro 500ml', sku: 'LMP-DTG-500', description: 'Produto de limpeza para uso geral.', category_id: '33333333-3333-3333-3333-333333333333', supplier_id: 'aaaaaaa3-aaaa-aaaa-aaaa-aaaaaaaaaaa3', unit: 'un', minimum_stock: 12, status: 'active', created_by: adminId, created_at: '2026-04-01T09:43:00.000Z', updated_at: '2026-04-01T09:43:00.000Z' },
      { id: 'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5', name: 'Item sem classificacao', sku: 'SEM-CAT-001', description: 'Produto mantido na categoria padrao para testes.', category_id: DEMO_FALLBACK_CATEGORY_ID, supplier_id: null, unit: 'un', minimum_stock: 3, status: 'active', created_by: adminId, created_at: '2026-04-01T09:44:00.000Z', updated_at: '2026-04-01T09:44:00.000Z' },
      { id: 'bbbbbbb6-bbbb-bbbb-bbbb-bbbbbbbbbbb6', name: 'Scanner antigo', sku: 'ARQ-SCN-001', description: 'Equipamento mantido apenas para historico.', category_id: DEMO_FALLBACK_CATEGORY_ID, supplier_id: null, unit: 'un', minimum_stock: 1, status: 'inactive', created_by: adminId, created_at: '2026-04-01T09:45:00.000Z', updated_at: '2026-04-01T09:45:00.000Z' },
    ],
    stock_movements: [
      { id: 'ccccccc1-cccc-cccc-cccc-ccccccccccc1', product_id: 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1', movement_type: 'in', quantity: 25, reason: 'Estoque inicial', notes: 'Carga inicial demo', created_by: adminId, created_at: '2026-04-01T10:00:00.000Z' },
      { id: 'ccccccc2-cccc-cccc-cccc-ccccccccccc2', product_id: 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1', movement_type: 'out', quantity: 5, reason: 'Consumo interno', notes: 'Distribuicao para equipe', created_by: adminId, created_at: '2026-04-02T10:00:00.000Z' },
      { id: 'ccccccc3-cccc-cccc-cccc-ccccccccccc3', product_id: 'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2', movement_type: 'in', quantity: 18, reason: 'Estoque inicial', notes: 'Carga inicial demo', created_by: adminId, created_at: '2026-04-01T10:10:00.000Z' },
      { id: 'ccccccc4-cccc-cccc-cccc-ccccccccccc4', product_id: 'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2', movement_type: 'adjustment', quantity: 2, reason: 'Correcao de contagem', notes: 'Ajuste positivo', created_by: adminId, created_at: '2026-04-03T10:10:00.000Z' },
      { id: 'ccccccc5-cccc-cccc-cccc-ccccccccccc5', product_id: 'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3', movement_type: 'in', quantity: 40, reason: 'Estoque inicial', notes: 'Carga inicial demo', created_by: adminId, created_at: '2026-04-01T10:20:00.000Z' },
      { id: 'ccccccc6-cccc-cccc-cccc-ccccccccccc6', product_id: 'bbbbbbb3-bbbb-bbbb-bbbb-bbbbbbbbbbb3', movement_type: 'out', quantity: 28, reason: 'Uso mensal', notes: 'Consumo administrativo', created_by: adminId, created_at: '2026-04-05T10:20:00.000Z' },
      { id: 'ccccccc7-cccc-cccc-cccc-ccccccccccc7', product_id: 'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4', movement_type: 'in', quantity: 30, reason: 'Estoque inicial', notes: 'Carga inicial demo', created_by: adminId, created_at: '2026-04-01T10:30:00.000Z' },
      { id: 'ccccccc8-cccc-cccc-cccc-ccccccccccc8', product_id: 'bbbbbbb4-bbbb-bbbb-bbbb-bbbbbbbbbbb4', movement_type: 'out', quantity: 20, reason: 'Reposicao de limpeza', notes: 'Distribuicao para areas comuns', created_by: operatorId, created_at: '2026-04-06T10:30:00.000Z' },
      { id: 'ccccccc9-cccc-cccc-cccc-ccccccccccc9', product_id: 'bbbbbbb5-bbbb-bbbb-bbbb-bbbbbbbbbbb5', movement_type: 'in', quantity: 4, reason: 'Recebimento sem classificacao', notes: 'Mantido em categoria padrao', created_by: adminId, created_at: '2026-04-07T10:40:00.000Z' },
    ],
  }
}

function readDemoDatabase(): DemoDatabase {
  if (!canUseStorage()) return buildDemoDatabase()
  const raw = window.localStorage.getItem(DB_KEY)
  if (!raw) {
    const seeded = buildDemoDatabase()
    window.localStorage.setItem(DB_KEY, JSON.stringify(seeded))
    return seeded
  }
  try {
    return JSON.parse(raw) as DemoDatabase
  } catch {
    const seeded = buildDemoDatabase()
    window.localStorage.setItem(DB_KEY, JSON.stringify(seeded))
    return seeded
  }
}

function writeDemoDatabase(database: DemoDatabase) {
  if (canUseStorage()) window.localStorage.setItem(DB_KEY, JSON.stringify(database))
}

function getSessionProfileId() {
  if (!canUseStorage()) return null
  return window.localStorage.getItem(SESSION_KEY)
}

function setSessionProfileId(profileId: string | null) {
  if (!canUseStorage()) return
  if (profileId) window.localStorage.setItem(SESSION_KEY, profileId)
  else window.localStorage.removeItem(SESSION_KEY)
}

function mapProfileToUser(profile: ProfileRow): AppUser {
  return { id: profile.id, email: profile.email, user_metadata: { full_name: profile.full_name ?? undefined } }
}

function getCurrentProfile(database: DemoDatabase) {
  const profileId = getSessionProfileId()
  if (!profileId) return null
  return database.profiles.find((item) => item.id === profileId) ?? null
}

function requireSession(database: DemoDatabase) {
  const profile = getCurrentProfile(database)
  if (!profile) throw new Error('Usuario nao autenticado.')
  return profile
}

function requireAdmin(database: DemoDatabase) {
  const profile = requireSession(database)
  if (profile.app_role !== 'admin') throw new Error('Apenas administradores podem executar esta acao.')
  return profile
}

function ensureUniqueName<T extends { id: string; name: string }>(items: T[], name: string, currentId?: string) {
  const normalized = name.trim().toLowerCase()
  if (items.some((item) => item.name.trim().toLowerCase() === normalized && item.id !== currentId)) {
    throw new Error('Ja existe um registro com este nome.')
  }
}

function ensureUniqueSku(products: Product[], sku: string, currentId?: string) {
  const normalized = sku.trim().toLowerCase()
  if (products.some((item) => item.sku.trim().toLowerCase() === normalized && item.id !== currentId)) {
    throw new Error('Ja existe um produto com este SKU.')
  }
}

function currentStock(movements: StockMovementRow[], productId: string) {
  return movements.reduce((total, movement) => {
    if (movement.product_id !== productId) return total
    if (movement.movement_type === 'out') return total - movement.quantity
    return total + movement.quantity
  }, 0)
}

function buildStockSummary(database: DemoDatabase): ProductStockSummary[] {
  return sortByNameAsc(
    database.products.map((product) => ({
      product_id: product.id,
      name: product.name,
      sku: product.sku,
      status: product.status,
      current_stock: currentStock(database.stock_movements, product.id),
      minimum_stock: product.minimum_stock,
    })),
  )
}

export function getDemoSession(): AppSession | null {
  const database = readDemoDatabase()
  const profile = getCurrentProfile(database)
  return profile ? { user: mapProfileToUser(profile) } : null
}

export function signInDemo(email: string, password: string): AppSession {
  const database = readDemoDatabase()
  const credential = database.credentials.find(
    (item) => item.email.toLowerCase() === email.trim().toLowerCase() && item.password === password,
  )
  if (!credential) throw new Error('Credenciais demo invalidas.')
  const profile = database.profiles.find((item) => item.id === credential.profile_id)
  if (!profile) throw new Error('Perfil demo nao encontrado.')
  setSessionProfileId(profile.id)
  return { user: mapProfileToUser(profile) }
}

export function signOutDemo() {
  setSessionProfileId(null)
}

export function getDemoMyProfile(): ProfileRow | null {
  const database = readDemoDatabase()
  const profile = getCurrentProfile(database)
  return profile ? cloneValue(profile) : null
}

export function listDemoProfiles(): ProfileRow[] {
  const database = readDemoDatabase()
  requireAdmin(database)
  return [...database.profiles]
    .sort((a, b) => a.created_at.localeCompare(b.created_at))
    .map((item) => cloneValue(item))
}

export function setDemoUserRole(profileId: string, appRole: AppRole): ProfileRow {
  const database = readDemoDatabase()
  const actor = requireAdmin(database)
  if (actor.id === profileId) throw new Error('Nao e permitido alterar o proprio papel.')
  const target = database.profiles.find((item) => item.id === profileId)
  if (!target) throw new Error('Perfil nao encontrado.')
  target.app_role = appRole
  target.role = appRole
  target.updated_at = nowIso()
  writeDemoDatabase(database)
  return cloneValue(target)
}

export function listDemoCategories(): Category[] {
  return sortByCreatedAtDesc(readDemoDatabase().categories).map((item) => cloneValue(item))
}

export function createDemoCategory(payload: CreateCategoryPayload): Category {
  const database = readDemoDatabase()
  const actor = requireAdmin(database)
  ensureUniqueName(database.categories, payload.name)
  const category: Category = {
    id: crypto.randomUUID(),
    name: payload.name.trim(),
    description: normalizeText(payload.description) || null,
    status: payload.status,
    created_by: payload.created_by || actor.id,
    created_at: nowIso(),
    updated_at: nowIso(),
  }
  database.categories.push(category)
  writeDemoDatabase(database)
  return cloneValue(category)
}

export function updateDemoCategory(categoryId: string, payload: UpdateCategoryPayload): Category {
  const database = readDemoDatabase()
  requireAdmin(database)
  if (categoryId === DEMO_FALLBACK_CATEGORY_ID) {
    throw new Error('A categoria padrao "Sem categoria" nao pode ser editada.')
  }
  const category = database.categories.find((item) => item.id === categoryId)
  if (!category) throw new Error('Categoria nao encontrada.')
  ensureUniqueName(database.categories, payload.name, categoryId)
  category.name = payload.name.trim()
  category.description = normalizeText(payload.description) || null
  category.status = payload.status
  category.updated_at = nowIso()
  writeDemoDatabase(database)
  return cloneValue(category)
}

export function countDemoProductsByCategory(categoryId: string) {
  return readDemoDatabase().products.filter((item) => item.category_id === categoryId).length
}

export function deleteDemoCategory(categoryId: string) {
  const database = readDemoDatabase()
  requireAdmin(database)
  if (categoryId === DEMO_FALLBACK_CATEGORY_ID) {
    throw new Error('A categoria padrao "Sem categoria" nao pode ser excluida.')
  }
  const categoryIndex = database.categories.findIndex((item) => item.id === categoryId)
  if (categoryIndex === -1) throw new Error('Categoria nao encontrada.')
  database.products.forEach((product) => {
    if (product.category_id === categoryId) {
      product.category_id = DEMO_FALLBACK_CATEGORY_ID
      product.updated_at = nowIso()
    }
  })
  database.categories.splice(categoryIndex, 1)
  writeDemoDatabase(database)
}

export function countDemoCategories() {
  return readDemoDatabase().categories.length
}

export function listDemoSuppliers(): Supplier[] {
  return sortByCreatedAtDesc(readDemoDatabase().suppliers).map((item) => cloneValue(item))
}

export function createDemoSupplier(payload: CreateSupplierPayload): Supplier {
  const database = readDemoDatabase()
  const actor = requireAdmin(database)
  ensureUniqueName(database.suppliers, payload.name)
  const supplier: Supplier = {
    id: crypto.randomUUID(),
    name: payload.name.trim(),
    contact_name: normalizeText(payload.contact_name) || null,
    email: normalizeText(payload.email) || null,
    phone: normalizeText(payload.phone) || null,
    document: normalizeText(payload.document) || null,
    notes: normalizeText(payload.notes) || null,
    status: payload.status,
    created_by: payload.created_by || actor.id,
    created_at: nowIso(),
    updated_at: nowIso(),
  }
  database.suppliers.push(supplier)
  writeDemoDatabase(database)
  return cloneValue(supplier)
}

export function updateDemoSupplier(supplierId: string, payload: UpdateSupplierPayload): Supplier {
  const database = readDemoDatabase()
  requireAdmin(database)
  const supplier = database.suppliers.find((item) => item.id === supplierId)
  if (!supplier) throw new Error('Fornecedor nao encontrado.')
  ensureUniqueName(database.suppliers, payload.name, supplierId)
  supplier.name = payload.name.trim()
  supplier.contact_name = normalizeText(payload.contact_name) || null
  supplier.email = normalizeText(payload.email) || null
  supplier.phone = normalizeText(payload.phone) || null
  supplier.document = normalizeText(payload.document) || null
  supplier.notes = normalizeText(payload.notes) || null
  supplier.status = payload.status
  supplier.updated_at = nowIso()
  writeDemoDatabase(database)
  return cloneValue(supplier)
}

export function deleteDemoSupplier(supplierId: string) {
  const database = readDemoDatabase()
  requireAdmin(database)
  const supplierIndex = database.suppliers.findIndex((item) => item.id === supplierId)
  if (supplierIndex === -1) throw new Error('Fornecedor nao encontrado.')
  database.products.forEach((product) => {
    if (product.supplier_id === supplierId) {
      product.supplier_id = null
      product.updated_at = nowIso()
    }
  })
  database.suppliers.splice(supplierIndex, 1)
  writeDemoDatabase(database)
}

export function countDemoSuppliers() {
  return readDemoDatabase().suppliers.length
}

function validateProductPayload(database: DemoDatabase, payload: UpdateProductPayload | CreateProductPayload, productId?: string) {
  if (!payload.name.trim()) throw new Error('O nome do produto e obrigatorio.')
  if (!payload.sku.trim()) throw new Error('O SKU do produto e obrigatorio.')
  if (payload.minimum_stock < 0) throw new Error('O estoque minimo deve ser igual ou maior que zero.')
  if (!database.categories.some((item) => item.id === payload.category_id)) throw new Error('Categoria nao encontrada.')
  if (payload.supplier_id && !database.suppliers.some((item) => item.id === payload.supplier_id)) {
    throw new Error('Fornecedor nao encontrado.')
  }
  ensureUniqueSku(database.products, payload.sku, productId)
}

export function listDemoProducts(): Product[] {
  return sortByCreatedAtDesc(readDemoDatabase().products).map((item) => cloneValue(item))
}

export function createDemoProduct(payload: CreateProductPayload): Product {
  const database = readDemoDatabase()
  const actor = requireAdmin(database)
  validateProductPayload(database, payload)
  const product: Product = {
    id: crypto.randomUUID(),
    name: payload.name.trim(),
    sku: payload.sku.trim(),
    description: normalizeText(payload.description) || null,
    category_id: payload.category_id,
    supplier_id: payload.supplier_id,
    unit: payload.unit.trim() || 'un',
    minimum_stock: payload.minimum_stock,
    status: payload.status,
    created_by: payload.created_by || actor.id,
    created_at: nowIso(),
    updated_at: nowIso(),
  }
  database.products.push(product)
  writeDemoDatabase(database)
  return cloneValue(product)
}

export function updateDemoProduct(productId: string, payload: UpdateProductPayload): Product {
  const database = readDemoDatabase()
  requireAdmin(database)
  const product = database.products.find((item) => item.id === productId)
  if (!product) throw new Error('Produto nao encontrado.')
  validateProductPayload(database, payload, productId)
  product.name = payload.name.trim()
  product.sku = payload.sku.trim()
  product.description = normalizeText(payload.description) || null
  product.category_id = payload.category_id
  product.supplier_id = payload.supplier_id
  product.unit = payload.unit.trim() || 'un'
  product.minimum_stock = payload.minimum_stock
  product.status = payload.status
  product.updated_at = nowIso()
  writeDemoDatabase(database)
  return cloneValue(product)
}

export function deleteDemoProduct(productId: string) {
  const database = readDemoDatabase()
  requireAdmin(database)
  if (database.stock_movements.some((item) => item.product_id === productId)) {
    throw new Error('Nao e possivel excluir um produto com movimentacoes registradas.')
  }
  const productIndex = database.products.findIndex((item) => item.id === productId)
  if (productIndex === -1) throw new Error('Produto nao encontrado.')
  database.products.splice(productIndex, 1)
  writeDemoDatabase(database)
}

export function countDemoProducts() {
  return readDemoDatabase().products.length
}

export function listDemoProductStockSummary(): ProductStockSummary[] {
  return buildStockSummary(readDemoDatabase()).map((item) => cloneValue(item))
}

export function createDemoMovement(payload: CreateMovementPayload): StockMovementRow {
  const database = readDemoDatabase()
  const actor = requireSession(database)
  const product = database.products.find((item) => item.id === payload.product_id)
  if (!product) throw new Error('Produto nao encontrado.')
  if (product.status !== 'active') throw new Error('Produto inativo nao pode receber movimentacoes.')
  if (!Number.isFinite(payload.quantity) || payload.quantity <= 0) throw new Error('A quantidade deve ser maior que zero.')
  if (payload.movement_type === 'adjustment' && !payload.reason.trim()) throw new Error('Ajuste exige justificativa.')
  const stockBefore = currentStock(database.stock_movements, payload.product_id)
  if (payload.movement_type === 'out' && stockBefore < payload.quantity) {
    throw new Error(`Saldo insuficiente para saida. Saldo atual: ${stockBefore}.`)
  }
  const movement: StockMovementRow = {
    id: crypto.randomUUID(),
    product_id: payload.product_id,
    movement_type: payload.movement_type,
    quantity: payload.quantity,
    reason: normalizeText(payload.reason) || null,
    notes: normalizeText(payload.notes) || null,
    created_by: actor.id,
    created_at: nowIso(),
  }
  database.stock_movements.push(movement)
  writeDemoDatabase(database)
  return cloneValue(movement)
}

export function listDemoMovements(): MovementWithProduct[] {
  const database = readDemoDatabase()
  return sortByCreatedAtDesc(database.stock_movements).map((movement) => {
    const product = database.products.find((item) => item.id === movement.product_id)
    return cloneValue({
      ...movement,
      products: product ? { name: product.name, sku: product.sku } : null,
    })
  })
}

export function countDemoMovements() {
  return readDemoDatabase().stock_movements.length
}

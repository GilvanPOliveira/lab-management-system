export type RecordStatus = 'active' | 'inactive'
export type MovementType = 'in' | 'out' | 'adjustment'
export type AppRole = 'admin' | 'operator'

export interface ProfileRow {
  id: string
  full_name: string | null
  email: string | null
  role: string
  app_role: AppRole
  created_at: string
  updated_at: string
}

export interface CategoryRow {
  id: string
  name: string
  description: string | null
  status: RecordStatus
  created_by: string | null
  created_at: string
  updated_at: string
}

export interface SupplierRow {
  id: string
  name: string
  contact_name: string | null
  email: string | null
  phone: string | null
  document: string | null
  notes: string | null
  status: RecordStatus
  created_by: string | null
  created_at: string
  updated_at: string
}

export interface ProductRow {
  id: string
  name: string
  sku: string
  description: string | null
  category_id: string
  supplier_id: string | null
  unit: string
  minimum_stock: number
  status: RecordStatus
  created_by: string | null
  created_at: string
  updated_at: string
}

export interface ProductStockSummaryRow {
  product_id: string
  name: string
  sku: string
  status: RecordStatus
  current_stock: number
  minimum_stock: number
}

export interface StockMovementRow {
  id: string
  product_id: string
  movement_type: MovementType
  quantity: number
  reason: string | null
  notes: string | null
  created_by: string
  created_at: string
}

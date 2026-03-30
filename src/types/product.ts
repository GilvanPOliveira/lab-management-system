import type { ProductRow, ProductStockSummaryRow, RecordStatus } from './database'

export interface CreateProductPayload {
  name: string
  sku: string
  description: string
  category_id: string
  supplier_id: string | null
  unit: string
  minimum_stock: number
  status: RecordStatus
  created_by: string
}

export interface UpdateProductPayload {
  name: string
  sku: string
  description: string
  category_id: string
  supplier_id: string | null
  unit: string
  minimum_stock: number
  status: RecordStatus
}

export type Product = ProductRow
export type ProductStockSummary = ProductStockSummaryRow

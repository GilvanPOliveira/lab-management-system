import type { MovementType, StockMovementRow } from './database'

export interface CreateMovementPayload {
  product_id: string
  movement_type: MovementType
  quantity: number
  reason: string
  notes: string
}

export interface MovementWithProduct extends StockMovementRow {
  products?: {
    name: string
    sku: string
  } | null
}

export type StockMovement = StockMovementRow

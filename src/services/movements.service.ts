import { supabase } from '../lib/supabase'
import type { CreateMovementPayload, MovementWithProduct } from '../types/movement'

export async function createMovement(payload: CreateMovementPayload) {
  const { data, error } = await supabase.rpc('create_stock_movement', {
    p_product_id: payload.product_id,
    p_movement_type: payload.movement_type,
    p_quantity: payload.quantity,
    p_reason: payload.reason,
    p_notes: payload.notes,
  })

  if (error) {
    throw new Error(error.message)
  }

  return data
}

export async function listMovements(): Promise<MovementWithProduct[]> {
  const { data, error } = await supabase
    .from('stock_movements')
    .select(`
      *,
      products (
        name,
        sku
      )
    `)
    .order('created_at', { ascending: false })

  if (error) {
    throw new Error(error.message)
  }

  return (data ?? []) as MovementWithProduct[]
}

export async function countMovements(): Promise<number> {
  const { count, error } = await supabase
    .from('stock_movements')
    .select('*', { count: 'exact', head: true })

  if (error) {
    throw new Error(error.message)
  }

  return count ?? 0
}

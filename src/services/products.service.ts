import { supabase } from '../lib/supabase'
import type { CreateProductPayload, Product, ProductStockSummary, UpdateProductPayload } from '../types/product'

const TABLE_NAME = 'products'

export async function listProducts(): Promise<Product[]> {
  const { data, error } = await supabase
    .from(TABLE_NAME)
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    throw new Error(error.message)
  }

  return data ?? []
}

export async function createProduct(payload: CreateProductPayload): Promise<Product> {
  const { data, error } = await supabase
    .from(TABLE_NAME)
    .insert(payload)
    .select('*')
    .single()

  if (error) {
    throw new Error(error.message)
  }

  return data
}

export async function updateProduct(
  productId: string,
  payload: UpdateProductPayload,
): Promise<Product> {
  const { data, error } = await supabase
    .from(TABLE_NAME)
    .update(payload)
    .eq('id', productId)
    .select('*')
    .single()

  if (error) {
    throw new Error(error.message)
  }

  return data
}

export async function deleteProduct(productId: string): Promise<void> {
  const { error } = await supabase
    .from(TABLE_NAME)
    .delete()
    .eq('id', productId)

  if (error) {
    throw new Error(error.message)
  }
}

export async function countProducts(): Promise<number> {
  const { count, error } = await supabase
    .from(TABLE_NAME)
    .select('*', { count: 'exact', head: true })

  if (error) {
    throw new Error(error.message)
  }

  return count ?? 0
}

export async function listProductStockSummary(): Promise<ProductStockSummary[]> {
  const { data, error } = await supabase
    .from('product_stock_summary')
    .select('*')
    .order('name', { ascending: true })

  if (error) {
    throw new Error(error.message)
  }

  return data ?? []
}

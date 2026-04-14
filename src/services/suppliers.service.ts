import { getBackendMode } from '../lib/backend'
import {
  countDemoSuppliers,
  createDemoSupplier,
  deleteDemoSupplier,
  listDemoSuppliers,
  updateDemoSupplier,
} from '../lib/demo'
import { getSupabaseClient } from '../lib/supabase'
import type { CreateSupplierPayload, Supplier, UpdateSupplierPayload } from '../types/supplier'

const TABLE_NAME = 'suppliers'

export async function listSuppliers(): Promise<Supplier[]> {
  if (getBackendMode() === 'demo') {
    return listDemoSuppliers()
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase
    .from(TABLE_NAME)
    .select('*')
    .order('created_at', { ascending: false })

  if (error) {
    throw new Error(error.message)
  }

  return data ?? []
}

export async function createSupplier(payload: CreateSupplierPayload): Promise<Supplier> {
  if (getBackendMode() === 'demo') {
    return createDemoSupplier(payload)
  }

  const supabase = getSupabaseClient()
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

export async function updateSupplier(
  supplierId: string,
  payload: UpdateSupplierPayload,
): Promise<Supplier> {
  if (getBackendMode() === 'demo') {
    return updateDemoSupplier(supplierId, payload)
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase
    .from(TABLE_NAME)
    .update(payload)
    .eq('id', supplierId)
    .select('*')
    .single()

  if (error) {
    throw new Error(error.message)
  }

  return data
}

export async function deleteSupplier(supplierId: string): Promise<void> {
  if (getBackendMode() === 'demo') {
    deleteDemoSupplier(supplierId)
    return
  }

  const supabase = getSupabaseClient()
  const { error } = await supabase
    .from(TABLE_NAME)
    .delete()
    .eq('id', supplierId)

  if (error) {
    throw new Error(error.message)
  }
}

export async function countSuppliers(): Promise<number> {
  if (getBackendMode() === 'demo') {
    return countDemoSuppliers()
  }

  const supabase = getSupabaseClient()
  const { count, error } = await supabase
    .from(TABLE_NAME)
    .select('*', { count: 'exact', head: true })

  if (error) {
    throw new Error(error.message)
  }

  return count ?? 0
}

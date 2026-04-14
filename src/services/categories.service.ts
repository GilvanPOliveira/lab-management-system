import { getBackendMode } from '../lib/backend'
import {
  countDemoCategories,
  countDemoProductsByCategory,
  createDemoCategory,
  deleteDemoCategory,
  DEMO_FALLBACK_CATEGORY_ID,
  listDemoCategories,
  updateDemoCategory,
} from '../lib/demo'
import { getSupabaseClient } from '../lib/supabase'
import type { Category, CreateCategoryPayload, UpdateCategoryPayload } from '../types/category'

const TABLE_NAME = 'categories'
const FALLBACK_CATEGORY_ID = DEMO_FALLBACK_CATEGORY_ID

export async function listCategories(): Promise<Category[]> {
  if (getBackendMode() === 'demo') {
    return listDemoCategories()
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

export async function createCategory(payload: CreateCategoryPayload): Promise<Category> {
  if (getBackendMode() === 'demo') {
    return createDemoCategory(payload)
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

export async function updateCategory(
  categoryId: string,
  payload: UpdateCategoryPayload,
): Promise<Category> {
  if (categoryId === FALLBACK_CATEGORY_ID) {
    throw new Error('A categoria padrao "Sem categoria" nao pode ser editada.')
  }

  if (getBackendMode() === 'demo') {
    return updateDemoCategory(categoryId, payload)
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase
    .from(TABLE_NAME)
    .update(payload)
    .eq('id', categoryId)
    .select('*')
    .single()

  if (error) {
    throw new Error(error.message)
  }

  return data
}

export async function countProductsByCategory(categoryId: string): Promise<number> {
  if (getBackendMode() === 'demo') {
    return countDemoProductsByCategory(categoryId)
  }

  const supabase = getSupabaseClient()
  const { count, error } = await supabase
    .from('products')
    .select('*', { count: 'exact', head: true })
    .eq('category_id', categoryId)

  if (error) {
    throw new Error(error.message)
  }

  return count ?? 0
}

export async function deleteCategory(categoryId: string): Promise<void> {
  if (categoryId === FALLBACK_CATEGORY_ID) {
    throw new Error('A categoria padrao "Sem categoria" nao pode ser excluida.')
  }

  if (getBackendMode() === 'demo') {
    deleteDemoCategory(categoryId)
    return
  }

  const supabase = getSupabaseClient()
  const { error } = await supabase.rpc('delete_category_with_fallback', {
    p_category_id: categoryId,
  })

  if (error) {
    throw new Error(error.message)
  }
}

export async function countCategories(): Promise<number> {
  if (getBackendMode() === 'demo') {
    return countDemoCategories()
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

export function isFallbackCategory(categoryId: string): boolean {
  return categoryId === FALLBACK_CATEGORY_ID
}

export function getFallbackCategoryId(): string {
  return FALLBACK_CATEGORY_ID
}

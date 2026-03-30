import type { CategoryRow, RecordStatus } from './database'

export interface CreateCategoryPayload {
  name: string
  description: string
  status: RecordStatus
  created_by: string
}

export interface UpdateCategoryPayload {
  name: string
  description: string
  status: RecordStatus
}

export type Category = CategoryRow

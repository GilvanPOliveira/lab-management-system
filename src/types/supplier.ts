import type { RecordStatus, SupplierRow } from './database'

export interface CreateSupplierPayload {
  name: string
  contact_name: string
  email: string
  phone: string
  document: string
  notes: string
  status: RecordStatus
  created_by: string
}

export interface UpdateSupplierPayload {
  name: string
  contact_name: string
  email: string
  phone: string
  document: string
  notes: string
  status: RecordStatus
}

export type Supplier = SupplierRow

import type { MovementType, RecordStatus } from '../types/database'
import { isLowStock } from './stock'

export function getStatusBadgeClass(status: RecordStatus) {
  return status === 'active'
    ? 'bg-emerald-500/10 text-emerald-300 ring-1 ring-emerald-500/20'
    : 'bg-zinc-700/40 text-zinc-300 ring-1 ring-zinc-600'
}

export function getMovementBadgeClass(type: MovementType) {
  if (type === 'in') {
    return 'bg-emerald-500/10 text-emerald-300 ring-1 ring-emerald-500/20'
  }

  if (type === 'out') {
    return 'bg-amber-500/10 text-amber-300 ring-1 ring-amber-500/20'
  }

  return 'bg-sky-500/10 text-sky-300 ring-1 ring-sky-500/20'
}

export function getStockTextClass(currentStock: number, minimumStock: number) {
  return isLowStock(currentStock, minimumStock) ? 'text-amber-300' : 'text-zinc-100'
}

export function getProductCardBorderClass(currentStock: number, minimumStock: number) {
  return isLowStock(currentStock, minimumStock)
    ? 'border-amber-500/30'
    : 'border-zinc-800'
}

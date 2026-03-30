import type { MovementType, RecordStatus } from '../types/database'

export function isLowStock(currentStock: number, minimumStock: number) {
  return currentStock <= minimumStock
}

export function getStatusLabel(status: RecordStatus) {
  return status === 'active' ? 'Ativo' : 'Inativo'
}

export function getCategoryStatusLabel(status: RecordStatus) {
  return status === 'active' ? 'Ativa' : 'Inativa'
}

export function getMovementLabel(type: MovementType) {
  if (type === 'in') return 'Entrada'
  if (type === 'out') return 'Saída'
  return 'Ajuste'
}

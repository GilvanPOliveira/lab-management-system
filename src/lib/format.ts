export function formatDateTime(value: string) {
  return new Date(value).toLocaleString('pt-BR')
}

export function formatDate(value: string) {
  return new Date(value).toLocaleDateString('pt-BR')
}

export function formatInteger(value: number) {
  return new Intl.NumberFormat('pt-BR', {
    maximumFractionDigits: 0,
  }).format(value)
}

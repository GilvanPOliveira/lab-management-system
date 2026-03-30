export function matchesSearchTerm(values: Array<string | null | undefined>, term: string) {
  const normalized = term.trim().toLowerCase()

  if (!normalized) {
    return true
  }

  return values.some((value) => (value ?? '').toLowerCase().includes(normalized))
}

export function matchesDateRange(value: string, startDate?: string, endDate?: string) {
  const target = new Date(value)

  const matchesStart =
    !startDate || target >= new Date(`${startDate}T00:00:00`)

  const matchesEnd =
    !endDate || target <= new Date(`${endDate}T23:59:59`)

  return matchesStart && matchesEnd
}

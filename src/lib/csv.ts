export function downloadCsv(filename: string, rows: Array<Record<string, unknown>>) {
  if (!rows.length) {
    return
  }

  const headers = Object.keys(rows[0])

  const escapeValue = (value: unknown) => {
    const stringValue = value == null ? '' : String(value)
    return `"${stringValue.replace(/"/g, '""')}"`
  }

  const bom = '\uFEFF'
  const csvContent = [
    headers.map(escapeValue).join(';'),
    ...rows.map((row) => headers.map((header) => escapeValue(row[header])).join(';')),
  ].join('\n')

  const blob = new Blob([bom + csvContent], {
    type: 'text/csv;charset=utf-8;',
  })

  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')

  link.href = url
  link.setAttribute('download', filename)
  document.body.appendChild(link)
  link.click()
  document.body.removeChild(link)

  URL.revokeObjectURL(url)
}

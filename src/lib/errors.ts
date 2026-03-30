export function getErrorMessage(
  error: unknown,
  fallback = 'Ocorreu um erro inesperado.',
) {
  if (error instanceof Error && error.message.trim()) {
    return error.message
  }

  if (typeof error === 'string' && error.trim()) {
    return error
  }

  return fallback
}

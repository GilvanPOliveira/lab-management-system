import { ref } from 'vue'

export type ToastVariant = 'success' | 'error' | 'info'

export interface ToastItem {
  id: number
  title: string
  message?: string
  variant: ToastVariant
}

const toasts = ref<ToastItem[]>([])
let toastId = 0

function removeToast(id: number) {
  toasts.value = toasts.value.filter((toast) => toast.id !== id)
}

function showToast(
  variant: ToastVariant,
  title: string,
  message?: string,
  duration = 3000,
) {
  const id = ++toastId

  toasts.value.push({
    id,
    title,
    message,
    variant,
  })

  window.setTimeout(() => {
    removeToast(id)
  }, duration)
}

export function useToast() {
  return {
    toasts,
    removeToast,
    success: (title: string, message?: string) =>
      showToast('success', title, message),
    error: (title: string, message?: string) =>
      showToast('error', title, message, 4500),
    info: (title: string, message?: string) =>
      showToast('info', title, message),
  }
}

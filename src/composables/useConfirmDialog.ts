import { computed, ref } from 'vue'

const open = ref(false)
const title = ref('')
const description = ref('')
const confirmText = ref('Confirmar')
const cancelText = ref('Cancelar')
const loading = ref(false)
const onConfirmAction = ref<null | (() => Promise<void>)>(null)

export function useConfirmDialog() {
  const isOpen = computed(() => open.value)

  function ask(options: {
    title: string
    description: string
    confirmText?: string
    cancelText?: string
    onConfirm: () => Promise<void>
  }) {
    title.value = options.title
    description.value = options.description
    confirmText.value = options.confirmText ?? 'Confirmar'
    cancelText.value = options.cancelText ?? 'Cancelar'
    onConfirmAction.value = options.onConfirm
    open.value = true
  }

  function close() {
    if (loading.value) {
      return
    }

    open.value = false
    title.value = ''
    description.value = ''
    confirmText.value = 'Confirmar'
    cancelText.value = 'Cancelar'
    onConfirmAction.value = null
  }

  async function confirm() {
    if (!onConfirmAction.value) {
      return
    }

    loading.value = true

    try {
      await onConfirmAction.value()
      close()
    } finally {
      loading.value = false
    }
  }

  return {
    isOpen,
    title,
    description,
    confirmText,
    cancelText,
    loading,
    ask,
    close,
    confirm,
  }
}

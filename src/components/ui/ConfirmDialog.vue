<script setup lang="ts">
import BaseButton from './BaseButton.vue'

defineProps<{
  open: boolean
  title: string
  description: string
  confirmText?: string
  cancelText?: string
  loading?: boolean
}>()

const emit = defineEmits<{
  confirm: []
  cancel: []
}>()
</script>

<template>
  <teleport to="body">
    <div
      v-if="open"
      class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 px-4"
    >
      <div class="w-full max-w-md rounded-3xl border border-zinc-800 bg-zinc-900 p-6 shadow-2xl">
        <h2 class="text-lg font-semibold text-zinc-100">
          {{ title }}
        </h2>

        <p class="mt-2 text-sm text-zinc-400">
          {{ description }}
        </p>

        <div class="mt-6 flex justify-end gap-3">
          <BaseButton
            variant="secondary"
            :disabled="loading"
            @click="emit('cancel')"
          >
            {{ cancelText ?? 'Cancelar' }}
          </BaseButton>

          <BaseButton
            variant="danger"
            :disabled="loading"
            @click="emit('confirm')"
          >
            {{ loading ? 'Processando...' : confirmText ?? 'Confirmar' }}
          </BaseButton>
        </div>
      </div>
    </div>
  </teleport>
</template>

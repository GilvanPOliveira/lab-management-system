<script setup lang="ts">
import { useToast } from '../../composables/useToast'

const { toasts, removeToast } = useToast()
</script>

<template>
  <div class="pointer-events-none fixed right-4 top-4 z-50 flex w-full max-w-sm flex-col gap-3">
    <transition-group name="toast">
      <article
        v-for="toast in toasts"
        :key="toast.id"
        :class="[
          'pointer-events-auto rounded-2xl border p-4 shadow-2xl backdrop-blur',
          toast.variant === 'success' && 'border-emerald-500/30 bg-emerald-500/10 text-emerald-100',
          toast.variant === 'error' && 'border-red-500/30 bg-red-500/10 text-red-100',
          toast.variant === 'info' && 'border-zinc-700 bg-zinc-900/95 text-zinc-100',
        ]"
      >
        <div class="flex items-start justify-between gap-4">
          <div>
            <h3 class="text-sm font-semibold">{{ toast.title }}</h3>
            <p v-if="toast.message" class="mt-1 text-sm opacity-90">
              {{ toast.message }}
            </p>
          </div>

          <button
            type="button"
            class="text-xs opacity-70 transition hover:opacity-100"
            @click="removeToast(toast.id)"
          >
            Fechar
          </button>
        </div>
      </article>
    </transition-group>
  </div>
</template>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.2s ease;
}

.toast-enter-from,
.toast-leave-to {
  opacity: 0;
  transform: translateY(-8px);
}
</style>

<script setup lang="ts">
interface Props {
  type?: 'button' | 'submit' | 'reset'
  disabled?: boolean
  variant?: 'primary' | 'secondary' | 'danger'
}

withDefaults(defineProps<Props>(), {
  type: 'button',
  disabled: false,
  variant: 'primary',
})
</script>

<template>
  <button
    :type="type"
    :disabled="disabled"
    :class="[
      'inline-flex items-center justify-center rounded-xl px-4 py-2.5 text-sm font-medium transition disabled:cursor-not-allowed disabled:opacity-50',
      variant === 'primary' && 'bg-white text-zinc-950 hover:bg-zinc-200',
      variant === 'secondary' && 'border border-zinc-700 bg-zinc-900 text-zinc-100 hover:bg-zinc-800',
      variant === 'danger' && 'bg-red-500 text-white hover:bg-red-400',
    ]"
  >
    <slot />
  </button>
</template>

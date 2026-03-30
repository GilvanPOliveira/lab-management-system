<script setup lang="ts">
defineProps<{
  label: string
  value: string | number
}>()
</script>

<template>
  <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-5">
    <p class="text-sm text-zinc-400">{{ label }}</p>
    <strong class="mt-3 block text-3xl font-semibold text-zinc-100">{{ value }}</strong>
  </div>
</template>

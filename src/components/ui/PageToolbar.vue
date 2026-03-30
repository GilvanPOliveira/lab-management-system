<script setup lang="ts">
defineProps<{
  title: string
  description?: string
}>()
</script>

<template>
  <div class="flex flex-col gap-4 rounded-2xl border border-zinc-800 bg-zinc-900 p-5 md:flex-row md:items-center md:justify-between">
    <div>
      <h2 class="text-lg font-semibold text-zinc-100">
        {{ title }}
      </h2>

      <p v-if="description" class="mt-1 text-sm text-zinc-400">
        {{ description }}
      </p>
    </div>

    <div class="flex flex-wrap gap-3">
      <slot />
    </div>
  </div>
</template>

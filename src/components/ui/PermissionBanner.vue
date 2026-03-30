<script setup lang="ts">
defineProps<{
  title: string
  description: string
}>()
</script>

<template>
  <div class="rounded-2xl border border-amber-500/20 bg-amber-500/5 p-4">
    <h3 class="text-sm font-semibold text-amber-300">
      {{ title }}
    </h3>

    <p class="mt-1 text-sm text-zinc-300">
      {{ description }}
    </p>
  </div>
</template>

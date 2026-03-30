<script setup lang="ts">
defineProps<{
  title: string
  description: string
}>()
</script>

<template>
  <header class="space-y-2">
    <h1 class="text-3xl font-semibold tracking-tight">{{ title }}</h1>
    <p class="text-sm text-zinc-400">
      {{ description }}
    </p>
  </header>
</template>

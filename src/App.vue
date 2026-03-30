<script setup lang="ts">
import { computed, onMounted, watch } from 'vue'
import { useRoute } from 'vue-router'
import AppSidebar from './components/layout/AppSidebar.vue'
import AppToastContainer from './components/ui/AppToastContainer.vue'
import { useAccess } from './composables/useAccess'
import { useAuth } from './composables/useAuth'

const route = useRoute()
const { initAuth, initialized: authInitialized, user } = useAuth()
const { loadProfile, resetProfile, initialized: accessInitialized } = useAccess()

const appReady = computed(() => {
  if (!authInitialized.value) {
    return false
  }

  if (!user.value) {
    return accessInitialized.value
  }

  return accessInitialized.value
})

onMounted(async () => {
  await initAuth()

  if (user.value) {
    await loadProfile()
  } else {
    resetProfile()
  }
})

watch(
  user,
  async (nextUser) => {
    if (nextUser) {
      await loadProfile()
      return
    }

    resetProfile()
  },
)
function isAuthScreen(path: string) {
  return path === '/login'
}
</script>

<template>
  <div class="min-h-screen bg-zinc-950 text-zinc-100">
    <AppToastContainer />

    <template v-if="!appReady">
      <main class="flex min-h-screen items-center justify-center px-6">
        <div class="rounded-2xl border border-zinc-800 bg-zinc-900 px-6 py-4 text-sm text-zinc-400">
          Inicializando aplicação...
        </div>
      </main>
    </template>

    <template v-else-if="isAuthScreen(route.path)">
      <RouterView />
    </template>

    <template v-else>
      <div class="mx-auto flex min-h-screen max-w-7xl">
        <AppSidebar />
        <main class="flex-1 p-6 lg:p-10">
          <RouterView />
        </main>
      </div>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import { getBackendLabel } from '../../lib/backend'
import { useAccess } from '../../composables/useAccess'
import { useAuth } from '../../composables/useAuth'

const route = useRoute()
const { user, signOut, loading, backendMode } = useAuth()
const { isAdmin, profile } = useAccess()

const links = computed(() => {
  if (isAdmin.value) {
    return [
      { label: 'Dashboard', to: '/' },
      { label: 'Categorias', to: '/categories' },
      { label: 'Produtos', to: '/products' },
      { label: 'Fornecedores', to: '/suppliers' },
      { label: 'Movimentacoes', to: '/movements' },
      { label: 'Relatorios', to: '/reports' },
      { label: 'Rel. Movimentacoes', to: '/reports/movements' },
      { label: 'Alertas', to: '/alerts' },
      { label: 'Usuarios', to: '/admin/users' },
    ]
  }

  return [
    { label: 'Dashboard', to: '/' },
    { label: 'Movimentacoes', to: '/movements' },
    { label: 'Relatorios', to: '/reports' },
    { label: 'Rel. Movimentacoes', to: '/reports/movements' },
    { label: 'Alertas', to: '/alerts' },
  ]
})

const userName = computed(() => {
  const metadataName = user.value?.user_metadata?.full_name

  if (typeof metadataName === 'string' && metadataName.trim()) {
    return metadataName
  }

  if (profile.value?.full_name?.trim()) {
    return profile.value.full_name
  }

  return user.value?.email ?? 'Usuario'
})

const roleLabel = computed(() => {
  return profile.value?.app_role === 'admin' ? 'Administrador' : 'Operador'
})

const backendLabel = computed(() => getBackendLabel(backendMode.value))
</script>

<template>
  <aside class="hidden w-72 border-r border-zinc-800 bg-zinc-900/70 p-6 lg:flex lg:flex-col">
    <div>
      <h1 class="text-xl font-semibold tracking-tight text-zinc-100">Lab Management System</h1>
      <p class="mt-2 text-sm text-zinc-400">
        Estoque operacional · laboratorio tecnico
      </p>
    </div>

    <nav class="mt-8 space-y-2">
      <RouterLink
        v-for="link in links"
        :key="link.to"
        :to="link.to"
        :class="[
          'block rounded-xl px-4 py-3 text-sm font-medium transition',
          route.path === link.to
            ? 'bg-white text-zinc-950'
            : 'text-zinc-300 hover:bg-zinc-800 hover:text-white',
        ]"
      >
        {{ link.label }}
      </RouterLink>
    </nav>

    <div class="mt-auto rounded-2xl border border-zinc-800 bg-zinc-950/60 p-4">
      <p class="text-xs uppercase tracking-[0.2em] text-zinc-500">Sessao</p>

      <p class="mt-2 text-sm font-medium text-zinc-100">
        {{ userName }}
      </p>

      <p class="mt-1 break-all text-xs text-zinc-500">
        {{ user?.email }}
      </p>

      <div class="mt-3 flex flex-wrap gap-2">
        <span class="inline-flex rounded-full border border-zinc-700 px-2.5 py-1 text-xs font-medium text-zinc-300">
          {{ roleLabel }}
        </span>
        <span class="inline-flex rounded-full border border-zinc-700 px-2.5 py-1 text-xs font-medium text-zinc-300">
          {{ backendLabel }}
        </span>
      </div>

      <button
        type="button"
        class="mt-4 w-full rounded-xl border border-zinc-700 px-4 py-2.5 text-sm font-medium text-zinc-100 transition hover:bg-zinc-800 disabled:cursor-not-allowed disabled:opacity-50"
        :disabled="loading"
        @click="signOut"
      >
        Sair
      </button>
    </div>
  </aside>
</template>

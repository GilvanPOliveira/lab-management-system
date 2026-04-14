<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRouter } from 'vue-router'
import BaseButton from '../components/ui/BaseButton.vue'
import BaseInput from '../components/ui/BaseInput.vue'
import { useAuth } from '../composables/useAuth'
import type { AppBackendMode } from '../types/auth'

const router = useRouter()
const { signIn, loading, backendMode, availableBackends, switchBackendMode } = useAuth()

const email = ref('')
const password = ref('')
const errorMessage = ref('')
const selectedBackend = ref<AppBackendMode>(backendMode.value)

const isDemoMode = computed(() => selectedBackend.value === 'demo')

watch(
  backendMode,
  (value) => {
    selectedBackend.value = value
  },
  { immediate: true },
)

function selectBackend(mode: AppBackendMode) {
  selectedBackend.value = mode
  errorMessage.value = ''

  if (mode === 'demo' && !email.value) {
    fillDemoCredentials('admin')
  }
}

function fillDemoCredentials(role: 'admin' | 'operator') {
  if (role === 'admin') {
    email.value = 'admin.demo@lab.local'
    password.value = 'demo123'
    return
  }

  email.value = 'operador.demo@lab.local'
  password.value = 'demo123'
}

async function handleSubmit() {
  errorMessage.value = ''

  try {
    await switchBackendMode(selectedBackend.value)
    await signIn(email.value, password.value)
    await router.push('/')
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Nao foi possivel entrar no sistema.'
  }
}
</script>

<template>
  <main class="flex min-h-screen items-center justify-center bg-zinc-950 px-6 text-zinc-100">
    <div class="w-full max-w-2xl rounded-3xl border border-zinc-800 bg-zinc-900 p-8 shadow-2xl shadow-black/20">
      <div class="mb-8">
        <h1 class="text-2xl font-semibold tracking-tight">Entrar</h1>
        <p class="mt-2 text-sm text-zinc-400">
          Escolha o backend e acesse o Lab Management System.
        </p>
      </div>

      <div class="mb-6 grid gap-3 md:grid-cols-2">
        <button
          v-for="option in availableBackends"
          :key="option.mode"
          type="button"
          :disabled="!option.available || loading"
          :class="[
            'rounded-2xl border p-4 text-left transition',
            selectedBackend === option.mode
              ? 'border-white bg-white text-zinc-950'
              : 'border-zinc-800 bg-zinc-950 text-zinc-100 hover:border-zinc-600',
            !option.available && 'cursor-not-allowed opacity-50',
          ]"
          @click="selectBackend(option.mode)"
        >
          <p class="text-sm font-semibold">{{ option.label }}</p>
          <p
            :class="[
              'mt-2 text-xs',
              selectedBackend === option.mode ? 'text-zinc-700' : 'text-zinc-400',
            ]"
          >
            {{ option.description }}
          </p>
        </button>
      </div>

      <div
        v-if="isDemoMode"
        class="mb-6 rounded-2xl border border-sky-500/20 bg-sky-500/10 p-4 text-sm text-sky-200"
      >
        <p class="font-medium">Acessos demo</p>
        <div class="mt-3 flex flex-wrap gap-3">
          <BaseButton variant="secondary" :disabled="loading" @click="fillDemoCredentials('admin')">
            Usar admin demo
          </BaseButton>
          <BaseButton variant="secondary" :disabled="loading" @click="fillDemoCredentials('operator')">
            Usar operador demo
          </BaseButton>
        </div>
      </div>

      <form class="space-y-4" @submit.prevent="handleSubmit">
        <BaseInput
          id="email"
          v-model="email"
          label="E-mail"
          type="email"
          placeholder="voce@exemplo.com"
          :disabled="loading"
        />

        <BaseInput
          id="password"
          v-model="password"
          label="Senha"
          type="password"
          placeholder="********"
          :disabled="loading"
        />

        <p v-if="errorMessage" class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300">
          {{ errorMessage }}
        </p>

        <BaseButton type="submit" class="w-full" :disabled="loading">
          {{ loading ? 'Entrando...' : 'Entrar' }}
        </BaseButton>
      </form>
    </div>
  </main>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import BaseButton from '../components/ui/BaseButton.vue'
import BaseInput from '../components/ui/BaseInput.vue'
import { useAuth } from '../composables/useAuth'

const router = useRouter()
const { signIn, loading } = useAuth()

const email = ref('')
const password = ref('')
const errorMessage = ref('')

async function handleSubmit() {
  errorMessage.value = ''

  try {
    await signIn(email.value, password.value)
    await router.push('/')
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Não foi possível entrar no sistema.'
  }
}
</script>

<template>
  <main class="flex min-h-screen items-center justify-center bg-zinc-950 px-6 text-zinc-100">
    <div class="w-full max-w-md rounded-3xl border border-zinc-800 bg-zinc-900 p-8 shadow-2xl shadow-black/20">
      <div class="mb-8">
        <h1 class="text-2xl font-semibold tracking-tight">Entrar</h1>
        <p class="mt-2 text-sm text-zinc-400">
          Acesse o Lab Management System com seu usuário do Supabase.
        </p>
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
          placeholder="••••••••"
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

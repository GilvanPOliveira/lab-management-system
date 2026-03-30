<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import BaseButton from '../components/ui/BaseButton.vue'
import BaseInput from '../components/ui/BaseInput.vue'
import EmptyState from '../components/ui/EmptyState.vue'
import PageHeader from '../components/ui/PageHeader.vue'
import PageToolbar from '../components/ui/PageToolbar.vue'
import { useToast } from '../composables/useToast'
import { listProfiles, setUserRole } from '../services/profile.service'
import type { AppRole, ProfileRow } from '../types/database'

const toast = useToast()

const profiles = ref<ProfileRow[]>([])
const isLoading = ref(false)
const updatingId = ref<string | null>(null)
const search = ref('')

const filteredProfiles = computed(() => {
  const term = search.value.trim().toLowerCase()

  return profiles.value.filter((profile) => {
    if (!term) {
      return true
    }

    return (
      (profile.full_name ?? '').toLowerCase().includes(term) ||
      (profile.email ?? '').toLowerCase().includes(term) ||
      profile.app_role.toLowerCase().includes(term)
    )
  })
})

async function loadProfiles() {
  isLoading.value = true

  try {
    profiles.value = await listProfiles()
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Não foi possível carregar os usuários.'

    toast.error('Erro ao carregar usuários', message)
  } finally {
    isLoading.value = false
  }
}

async function handleRoleChange(profileId: string, role: AppRole) {
  updatingId.value = profileId

  try {
    await setUserRole(profileId, role)
    toast.success('Papel atualizado', 'O papel do usuário foi alterado com sucesso.')
    await loadProfiles()
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Não foi possível atualizar o papel.'

    toast.error('Erro ao atualizar papel', message)
  } finally {
    updatingId.value = null
  }
}

function getRoleLabel(role: AppRole) {
  return role === 'admin' ? 'Administrador' : 'Operador'
}

onMounted(loadProfiles)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Usuários"
      description="Administração de perfis e níveis de acesso do sistema."
    />

    <PageToolbar
      title="Gestão de perfis"
      description="Controle quem possui acesso administrativo e operacional."
    >
      <BaseButton variant="secondary" :disabled="isLoading" @click="loadProfiles">
        Recarregar
      </BaseButton>
    </PageToolbar>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
      <div class="grid gap-4 md:grid-cols-[minmax(0,1fr)_auto] md:items-end">
        <BaseInput
          id="users-search"
          v-model="search"
          label="Buscar usuário"
          placeholder="Nome, e-mail ou papel"
        />

        <BaseButton variant="secondary" @click="loadProfiles">
          Atualizar lista
        </BaseButton>
      </div>
    </div>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
      <div class="mb-6 flex items-center justify-between gap-4">
        <div>
          <h2 class="text-lg font-semibold text-zinc-100">Lista de perfis</h2>
          <p class="mt-1 text-sm text-zinc-400">
            Controle quem administra o cadastro estrutural do sistema.
          </p>
        </div>

        <span class="rounded-full border border-zinc-700 px-3 py-1 text-xs font-medium text-zinc-300">
          {{ filteredProfiles.length }} registro(s)
        </span>
      </div>

      <div
        v-if="isLoading"
        class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-6 text-sm text-zinc-400"
      >
        Carregando usuários...
      </div>

      <EmptyState
        v-else-if="filteredProfiles.length === 0"
        title="Nenhum usuário encontrado"
        description="Tente outro termo de busca ou recarregue a listagem."
      />

      <div v-else class="space-y-4">
        <article
          v-for="item in filteredProfiles"
          :key="item.id"
          class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-5"
        >
          <div class="flex flex-col gap-4 xl:flex-row xl:items-center xl:justify-between">
            <div class="min-w-0">
              <div class="flex flex-wrap items-center gap-3">
                <h3 class="text-base font-semibold text-zinc-100">
                  {{ item.full_name || 'Usuário sem nome' }}
                </h3>

                <span
                  :class="[
                    'rounded-full px-2.5 py-1 text-xs font-medium',
                    item.app_role === 'admin'
                      ? 'bg-emerald-500/10 text-emerald-300 ring-1 ring-emerald-500/20'
                      : 'bg-sky-500/10 text-sky-300 ring-1 ring-sky-500/20',
                  ]"
                >
                  {{ getRoleLabel(item.app_role) }}
                </span>
              </div>

              <p class="mt-2 text-sm text-zinc-400">
                {{ item.email || 'Sem e-mail disponível' }}
              </p>

              <p class="mt-2 text-xs text-zinc-500">
                ID: {{ item.id }}
              </p>
            </div>

            <div class="flex flex-wrap gap-3">
              <BaseButton
                variant="secondary"
                :disabled="updatingId === item.id || item.app_role === 'operator'"
                @click="handleRoleChange(item.id, 'operator')"
              >
                {{ updatingId === item.id ? 'Atualizando...' : 'Definir como operador' }}
              </BaseButton>

              <BaseButton
                :disabled="updatingId === item.id || item.app_role === 'admin'"
                @click="handleRoleChange(item.id, 'admin')"
              >
                {{ updatingId === item.id ? 'Atualizando...' : 'Definir como admin' }}
              </BaseButton>
            </div>
          </div>
        </article>
      </div>
    </div>
  </section>
</template>

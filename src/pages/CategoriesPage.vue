<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import BaseButton from '../components/ui/BaseButton.vue'
import BaseInput from '../components/ui/BaseInput.vue'
import BaseTextarea from '../components/ui/BaseTextarea.vue'
import ConfirmDialog from '../components/ui/ConfirmDialog.vue'
import EmptyState from '../components/ui/EmptyState.vue'
import PageHeader from '../components/ui/PageHeader.vue'
import PageToolbar from '../components/ui/PageToolbar.vue'
import { useAuth } from '../composables/useAuth'
import { useToast } from '../composables/useToast'
import { getErrorMessage } from '../lib/errors'
import { formatDateTime } from '../lib/format'
import { getCategoryStatusLabel } from '../lib/stock'
import { getStatusBadgeClass } from '../lib/ui'
import {
  createCategory,
  deleteCategory,
  isFallbackCategory,
  listCategories,
  updateCategory,
} from '../services/categories.service'
import type { Category } from '../types/category'
import type { RecordStatus } from '../types/database'

interface CategoryForm {
  name: string
  description: string
  status: RecordStatus
}

const { user } = useAuth()
const toast = useToast()

const categories = ref<Category[]>([])
const isLoading = ref(false)
const isSaving = ref(false)
const isDeleting = ref(false)
const errorMessage = ref('')
const editingId = ref<string | null>(null)
const pendingDeleteCategory = ref<Category | null>(null)

const form = reactive<CategoryForm>({
  name: '',
  description: '',
  status: 'active',
})

const isEditing = computed(() => !!editingId.value)
const isDeleteDialogOpen = computed(() => !!pendingDeleteCategory.value)
const isEditingFallbackCategory = computed(() =>
  editingId.value ? isFallbackCategory(editingId.value) : false,
)

function resetForm() {
  form.name = ''
  form.description = ''
  form.status = 'active'
  editingId.value = null
}

async function loadCategories() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    categories.value = await listCategories()
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Não foi possível carregar as categorias.')
  } finally {
    isLoading.value = false
  }
}

function fillForm(category: Category) {
  editingId.value = category.id
  form.name = category.name
  form.description = category.description ?? ''
  form.status = category.status
  errorMessage.value = ''
}

function openDeleteDialog(category: Category) {
  pendingDeleteCategory.value = category
}

function closeDeleteDialog() {
  pendingDeleteCategory.value = null
}

async function handleSubmit() {
  errorMessage.value = ''

  if (!form.name.trim()) {
    errorMessage.value = 'O nome da categoria é obrigatório.'
    return
  }

  if (!user.value?.id) {
    errorMessage.value = 'Usuário autenticado não encontrado.'
    return
  }

  isSaving.value = true

  try {
    if (editingId.value) {
      await updateCategory(editingId.value, {
        name: form.name.trim(),
        description: form.description.trim(),
        status: form.status,
      })

      toast.success('Categoria atualizada', 'As alterações foram salvas com sucesso.')
    } else {
      await createCategory({
        name: form.name.trim(),
        description: form.description.trim(),
        status: form.status,
        created_by: user.value.id,
      })

      toast.success('Categoria criada', 'A nova categoria foi cadastrada com sucesso.')
    }

    resetForm()
    await loadCategories()
  } catch (error) {
    const message = getErrorMessage(error, 'Não foi possível salvar a categoria.')

    errorMessage.value = message
    toast.error('Erro ao salvar categoria', message)
  } finally {
    isSaving.value = false
  }
}

async function confirmDelete() {
  if (!pendingDeleteCategory.value) {
    return
  }

  isDeleting.value = true

  try {
    await deleteCategory(pendingDeleteCategory.value.id)

    if (editingId.value === pendingDeleteCategory.value.id) {
      resetForm()
    }

    toast.success(
      'Categoria excluída',
      'Os produtos vinculados foram remanejados automaticamente para "Sem categoria".',
    )

    closeDeleteDialog()
    await loadCategories()
  } catch (error) {
    const message = getErrorMessage(error, 'Não foi possível excluir a categoria.')

    toast.error('Erro ao excluir categoria', message)
  } finally {
    isDeleting.value = false
  }
}

onMounted(loadCategories)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Categorias"
      description="Organização estrutural dos produtos do estoque."
    />

    <PageToolbar
      title="Gestão de categorias"
      description='Cadastre e mantenha categorias. Ao excluir uma categoria em uso, os produtos são movidos para "Sem categoria".'
    >
      <BaseButton variant="secondary" :disabled="isLoading" @click="loadCategories">
        Recarregar
      </BaseButton>

      <BaseButton v-if="isEditing" @click="resetForm">
        Nova categoria
      </BaseButton>
    </PageToolbar>

    <div class="grid gap-6 xl:grid-cols-[420px_minmax(0,1fr)]">
      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-6">
          <h2 class="text-lg font-semibold text-zinc-100">
            {{ isEditing ? 'Editar categoria' : 'Nova categoria' }}
          </h2>
          <p class="mt-1 text-sm text-zinc-400">
            Preencha os campos para salvar a categoria.
          </p>
        </div>

        <div
          v-if="isEditingFallbackCategory"
          class="mb-4 rounded-xl border border-amber-500/30 bg-amber-500/10 px-4 py-3 text-sm text-amber-300"
        >
          A categoria padrão "Sem categoria" é protegida e não pode ser editada nem excluída.
        </div>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <BaseInput
            id="category-name"
            v-model="form.name"
            label="Nome"
            placeholder="Ex.: Componentes eletrônicos"
            :disabled="isSaving || isEditingFallbackCategory"
          />

          <BaseTextarea
            id="category-description"
            v-model="form.description"
            label="Descrição"
            placeholder="Descreva o propósito da categoria"
            :disabled="isSaving || isEditingFallbackCategory"
          />

          <label for="category-status" class="block space-y-2">
            <span class="text-sm font-medium text-zinc-200">Status</span>

            <select
              id="category-status"
              v-model="form.status"
              :disabled="isSaving || isEditingFallbackCategory"
              class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
            >
              <option value="active">Ativa</option>
              <option value="inactive">Inativa</option>
            </select>
          </label>

          <div
            v-if="errorMessage"
            class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300"
          >
            {{ errorMessage }}
          </div>

          <BaseButton
            type="submit"
            :disabled="isSaving || isEditingFallbackCategory"
          >
            {{ isSaving ? 'Salvando...' : isEditing ? 'Atualizar categoria' : 'Criar categoria' }}
          </BaseButton>
        </form>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-6 flex items-center justify-between gap-4">
          <div>
            <h2 class="text-lg font-semibold text-zinc-100">Lista de categorias</h2>
            <p class="mt-1 text-sm text-zinc-400">
              Categorias cadastradas no sistema.
            </p>
          </div>

          <span class="rounded-full border border-zinc-700 px-3 py-1 text-xs font-medium text-zinc-300">
            {{ categories.length }} registro(s)
          </span>
        </div>

        <div
          v-if="isLoading"
          class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-6 text-sm text-zinc-400"
        >
          Carregando categorias...
        </div>

        <EmptyState
          v-else-if="categories.length === 0"
          title="Nenhuma categoria cadastrada"
          description="Crie a primeira categoria para iniciar a estrutura do estoque."
        />

        <div v-else class="space-y-4">
          <article
            v-for="category in categories"
            :key="category.id"
            class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-5"
          >
            <div class="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
              <div class="min-w-0">
                <div class="flex flex-wrap items-center gap-3">
                  <h3 class="text-base font-semibold text-zinc-100">
                    {{ category.name }}
                  </h3>

                  <span
                    :class="[
                      'rounded-full px-2.5 py-1 text-xs font-medium',
                      getStatusBadgeClass(category.status),
                    ]"
                  >
                    {{ getCategoryStatusLabel(category.status) }}
                  </span>

                  <span
                    v-if="isFallbackCategory(category.id)"
                    class="rounded-full bg-sky-500/10 px-2.5 py-1 text-xs font-medium text-sky-300 ring-1 ring-sky-500/20"
                  >
                    Categoria padrão
                  </span>
                </div>

                <p class="mt-3 text-sm text-zinc-400">
                  {{ category.description || 'Sem descrição informada.' }}
                </p>

                <p class="mt-4 text-xs text-zinc-500">
                  Criada em {{ formatDateTime(category.created_at) }}
                </p>
              </div>

              <div class="flex shrink-0 gap-3">
                <BaseButton variant="secondary" @click="fillForm(category)">
                  Editar
                </BaseButton>

                <BaseButton
                  variant="danger"
                  :disabled="isFallbackCategory(category.id)"
                  @click="openDeleteDialog(category)"
                >
                  Excluir
                </BaseButton>
              </div>
            </div>
          </article>
        </div>
      </div>
    </div>

    <ConfirmDialog
      :open="isDeleteDialogOpen"
      title="Excluir categoria"
      :description='`Os produtos vinculados à categoria "${pendingDeleteCategory?.name ?? ""}" serão movidos automaticamente para "Sem categoria". Deseja continuar?`'
      confirm-text="Excluir e remanejar"
      :loading="isDeleting"
      @cancel="closeDeleteDialog"
      @confirm="confirmDelete"
    />
  </section>
</template>

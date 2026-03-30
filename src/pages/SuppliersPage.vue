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
import {
  createSupplier,
  deleteSupplier,
  listSuppliers,
  updateSupplier,
} from '../services/suppliers.service'
import type { Supplier } from '../types/supplier'
import type { RecordStatus } from '../types/database'

interface SupplierForm {
  name: string
  contact_name: string
  email: string
  phone: string
  document: string
  notes: string
  status: RecordStatus
}

const { user } = useAuth()
const toast = useToast()

const suppliers = ref<Supplier[]>([])
const isLoading = ref(false)
const isSaving = ref(false)
const isDeleting = ref(false)
const errorMessage = ref('')
const editingId = ref<string | null>(null)
const pendingDeleteId = ref<string | null>(null)

const form = reactive<SupplierForm>({
  name: '',
  contact_name: '',
  email: '',
  phone: '',
  document: '',
  notes: '',
  status: 'active',
})

const isEditing = computed(() => !!editingId.value)
const isDeleteDialogOpen = computed(() => !!pendingDeleteId.value)

function resetForm() {
  form.name = ''
  form.contact_name = ''
  form.email = ''
  form.phone = ''
  form.document = ''
  form.notes = ''
  form.status = 'active'
  editingId.value = null
}

async function loadSuppliers() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    suppliers.value = await listSuppliers()
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Não foi possível carregar os fornecedores.'
  } finally {
    isLoading.value = false
  }
}

function fillForm(supplier: Supplier) {
  editingId.value = supplier.id
  form.name = supplier.name
  form.contact_name = supplier.contact_name ?? ''
  form.email = supplier.email ?? ''
  form.phone = supplier.phone ?? ''
  form.document = supplier.document ?? ''
  form.notes = supplier.notes ?? ''
  form.status = supplier.status
  errorMessage.value = ''
}

function openDeleteDialog(supplierId: string) {
  pendingDeleteId.value = supplierId
}

function closeDeleteDialog() {
  pendingDeleteId.value = null
}

async function handleSubmit() {
  errorMessage.value = ''

  if (!form.name.trim()) {
    errorMessage.value = 'O nome do fornecedor é obrigatório.'
    return
  }

  if (!user.value?.id) {
    errorMessage.value = 'Usuário autenticado não encontrado.'
    return
  }

  isSaving.value = true

  try {
    if (editingId.value) {
      await updateSupplier(editingId.value, {
        name: form.name.trim(),
        contact_name: form.contact_name.trim(),
        email: form.email.trim(),
        phone: form.phone.trim(),
        document: form.document.trim(),
        notes: form.notes.trim(),
        status: form.status,
      })

      toast.success('Fornecedor atualizado', 'As alterações foram salvas com sucesso.')
    } else {
      await createSupplier({
        name: form.name.trim(),
        contact_name: form.contact_name.trim(),
        email: form.email.trim(),
        phone: form.phone.trim(),
        document: form.document.trim(),
        notes: form.notes.trim(),
        status: form.status,
        created_by: user.value.id,
      })

      toast.success('Fornecedor criado', 'O novo fornecedor foi cadastrado com sucesso.')
    }

    resetForm()
    await loadSuppliers()
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Não foi possível salvar o fornecedor.'

    errorMessage.value = message
    toast.error('Erro ao salvar fornecedor', message)
  } finally {
    isSaving.value = false
  }
}

async function confirmDelete() {
  if (!pendingDeleteId.value) {
    return
  }

  isDeleting.value = true

  try {
    await deleteSupplier(pendingDeleteId.value)

    if (editingId.value === pendingDeleteId.value) {
      resetForm()
    }

    toast.success('Fornecedor excluído', 'O registro foi removido com sucesso.')
    closeDeleteDialog()
    await loadSuppliers()
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Não foi possível excluir o fornecedor.'

    toast.error('Erro ao excluir fornecedor', message)
  } finally {
    isDeleting.value = false
  }
}

onMounted(loadSuppliers)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Fornecedores"
      description="Gestão dos fornecedores vinculados ao estoque."
    />

    <PageToolbar
      title="Gestão de fornecedores"
      description="Cadastre e mantenha fornecedores relacionados aos produtos do sistema."
    >
      <BaseButton variant="secondary" :disabled="isLoading" @click="loadSuppliers">
        Recarregar
      </BaseButton>

      <BaseButton v-if="isEditing" @click="resetForm">
        Novo fornecedor
      </BaseButton>
    </PageToolbar>

    <div class="grid gap-6 xl:grid-cols-[420px_minmax(0,1fr)]">
      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-6">
          <h2 class="text-lg font-semibold text-zinc-100">
            {{ isEditing ? 'Editar fornecedor' : 'Novo fornecedor' }}
          </h2>
          <p class="mt-1 text-sm text-zinc-400">
            Preencha os campos para salvar o fornecedor.
          </p>
        </div>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <BaseInput
            id="supplier-name"
            v-model="form.name"
            label="Nome"
            placeholder="Ex.: Tech Supply Brasil"
            :disabled="isSaving"
          />

          <BaseInput
            id="supplier-contact-name"
            v-model="form.contact_name"
            label="Responsável"
            placeholder="Ex.: Marina Costa"
            :disabled="isSaving"
          />

          <BaseInput
            id="supplier-email"
            v-model="form.email"
            label="E-mail"
            type="email"
            placeholder="contato@empresa.com"
            :disabled="isSaving"
          />

          <BaseInput
            id="supplier-phone"
            v-model="form.phone"
            label="Telefone"
            placeholder="(81) 99999-9999"
            :disabled="isSaving"
          />

          <BaseInput
            id="supplier-document"
            v-model="form.document"
            label="Documento"
            placeholder="CNPJ ou outro identificador"
            :disabled="isSaving"
          />

          <BaseTextarea
            id="supplier-notes"
            v-model="form.notes"
            label="Observações"
            placeholder="Notas complementares sobre o fornecedor"
            :disabled="isSaving"
          />

          <label for="supplier-status" class="block space-y-2">
            <span class="text-sm font-medium text-zinc-200">Status</span>

            <select
              id="supplier-status"
              v-model="form.status"
              :disabled="isSaving"
              class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
            >
              <option value="active">Ativo</option>
              <option value="inactive">Inativo</option>
            </select>
          </label>

          <div v-if="errorMessage" class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300">
            {{ errorMessage }}
          </div>

          <BaseButton type="submit" :disabled="isSaving">
            {{ isSaving ? 'Salvando...' : isEditing ? 'Atualizar fornecedor' : 'Criar fornecedor' }}
          </BaseButton>
        </form>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-6 flex items-center justify-between gap-4">
          <div>
            <h2 class="text-lg font-semibold text-zinc-100">Lista de fornecedores</h2>
            <p class="mt-1 text-sm text-zinc-400">
              Fornecedores cadastrados no sistema.
            </p>
          </div>

          <span class="rounded-full border border-zinc-700 px-3 py-1 text-xs font-medium text-zinc-300">
            {{ suppliers.length }} registro(s)
          </span>
        </div>

        <div v-if="isLoading" class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-6 text-sm text-zinc-400">
          Carregando fornecedores...
        </div>

        <EmptyState
          v-else-if="suppliers.length === 0"
          title="Nenhum fornecedor cadastrado"
          description="Cadastre fornecedores para vincular aos produtos."
        />

        <div v-else class="space-y-4">
          <article
            v-for="supplier in suppliers"
            :key="supplier.id"
            class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-5"
          >
            <div class="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
              <div class="min-w-0">
                <div class="flex flex-wrap items-center gap-3">
                  <h3 class="text-base font-semibold text-zinc-100">
                    {{ supplier.name }}
                  </h3>

                  <span
                    :class="[
                      'rounded-full px-2.5 py-1 text-xs font-medium',
                      supplier.status === 'active'
                        ? 'bg-emerald-500/10 text-emerald-300 ring-1 ring-emerald-500/20'
                        : 'bg-zinc-700/40 text-zinc-300 ring-1 ring-zinc-600',
                    ]"
                  >
                    {{ supplier.status === 'active' ? 'Ativo' : 'Inativo' }}
                  </span>
                </div>

                <div class="mt-3 space-y-1 text-sm text-zinc-400">
                  <p><strong class="text-zinc-300">Responsável:</strong> {{ supplier.contact_name || '—' }}</p>
                  <p><strong class="text-zinc-300">E-mail:</strong> {{ supplier.email || '—' }}</p>
                  <p><strong class="text-zinc-300">Telefone:</strong> {{ supplier.phone || '—' }}</p>
                  <p><strong class="text-zinc-300">Documento:</strong> {{ supplier.document || '—' }}</p>
                </div>

                <p class="mt-3 text-sm text-zinc-400">
                  {{ supplier.notes || 'Sem observações informadas.' }}
                </p>
              </div>

              <div class="flex shrink-0 gap-3">
                <BaseButton variant="secondary" @click="fillForm(supplier)">
                  Editar
                </BaseButton>

                <BaseButton variant="danger" @click="openDeleteDialog(supplier.id)">
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
      title="Excluir fornecedor"
      description="Essa ação removerá o fornecedor selecionado. Deseja continuar?"
      confirm-text="Excluir"
      :loading="isDeleting"
      @cancel="closeDeleteDialog"
      @confirm="confirmDelete"
    />
  </section>
</template>

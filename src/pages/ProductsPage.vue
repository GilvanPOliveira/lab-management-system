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
import { listCategories } from '../services/categories.service'
import {
  createProduct,
  deleteProduct,
  listProductStockSummary,
  listProducts,
  updateProduct,
} from '../services/products.service'
import { listSuppliers } from '../services/suppliers.service'
import type { RecordStatus } from '../types/database'
import type { Product, ProductStockSummary } from '../types/product'
import type { Category } from '../types/category'
import type { Supplier } from '../types/supplier'

interface ProductForm {
  name: string
  sku: string
  description: string
  category_id: string
  supplier_id: string
  unit: string
  minimum_stock: string
  status: RecordStatus
}

const { user } = useAuth()
const toast = useToast()

const products = ref<Product[]>([])
const categories = ref<Category[]>([])
const suppliers = ref<Supplier[]>([])
const stockSummary = ref<ProductStockSummary[]>([])
const isLoading = ref(false)
const isSaving = ref(false)
const isDeleting = ref(false)
const errorMessage = ref('')
const editingId = ref<string | null>(null)
const pendingDeleteId = ref<string | null>(null)

const search = ref('')
const filterStatus = ref<'all' | RecordStatus>('all')
const filterCategoryId = ref('all')
const filterSupplierId = ref('all')
const stockOnlyLow = ref(false)

const form = reactive<ProductForm>({
  name: '',
  sku: '',
  description: '',
  category_id: '',
  supplier_id: '',
  unit: 'un',
  minimum_stock: '0',
  status: 'active',
})

const isEditing = computed(() => !!editingId.value)
const isDeleteDialogOpen = computed(() => !!pendingDeleteId.value)

const filteredProducts = computed(() => {
  const term = search.value.trim().toLowerCase()

  return products.value.filter((product) => {
    const matchesSearch =
      !term ||
      product.name.toLowerCase().includes(term) ||
      product.sku.toLowerCase().includes(term)

    const matchesStatus =
      filterStatus.value === 'all' || product.status === filterStatus.value

    const matchesCategory =
      filterCategoryId.value === 'all' || product.category_id === filterCategoryId.value

    const matchesSupplier =
      filterSupplierId.value === 'all' || (product.supplier_id ?? '') === filterSupplierId.value

    const currentStock = getCurrentStock(product.id)
    const matchesLowStock = !stockOnlyLow.value || currentStock <= product.minimum_stock

    return (
      matchesSearch &&
      matchesStatus &&
      matchesCategory &&
      matchesSupplier &&
      matchesLowStock
    )
  })
})

function resetForm() {
  form.name = ''
  form.sku = ''
  form.description = ''
  form.category_id = categories.value[0]?.id ?? ''
  form.supplier_id = ''
  form.unit = 'un'
  form.minimum_stock = '0'
  form.status = 'active'
  editingId.value = null
}

function resetFilters() {
  search.value = ''
  filterStatus.value = 'all'
  filterCategoryId.value = 'all'
  filterSupplierId.value = 'all'
  stockOnlyLow.value = false
}

function getCategoryName(categoryId: string) {
  return categories.value.find((item) => item.id === categoryId)?.name ?? '—'
}

function getSupplierName(supplierId: string | null) {
  if (!supplierId) return '—'
  return suppliers.value.find((item) => item.id === supplierId)?.name ?? '—'
}

async function loadData() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const [productsData, categoriesData, suppliersData, stockData] = await Promise.all([
      listProducts(),
      listCategories(),
      listSuppliers(),
      listProductStockSummary(),
    ])

    products.value = productsData
    categories.value = categoriesData
    suppliers.value = suppliersData
    stockSummary.value = stockData

    if (!editingId.value && !form.category_id && categoriesData.length > 0) {
      form.category_id = categoriesData[0].id
    }
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Não foi possível carregar os produtos.'
  } finally {
    isLoading.value = false
  }
}

function fillForm(product: Product) {
  editingId.value = product.id
  form.name = product.name
  form.sku = product.sku
  form.description = product.description ?? ''
  form.category_id = product.category_id
  form.supplier_id = product.supplier_id ?? ''
  form.unit = product.unit
  form.minimum_stock = String(product.minimum_stock)
  form.status = product.status
  errorMessage.value = ''
}

function openDeleteDialog(productId: string) {
  pendingDeleteId.value = productId
}

function closeDeleteDialog() {
  pendingDeleteId.value = null
}

async function handleSubmit() {
  errorMessage.value = ''

  if (!form.name.trim()) {
    errorMessage.value = 'O nome do produto é obrigatório.'
    return
  }

  if (!form.sku.trim()) {
    errorMessage.value = 'O SKU do produto é obrigatório.'
    return
  }

  if (!form.category_id) {
    errorMessage.value = 'Selecione uma categoria.'
    return
  }

  const minimumStock = Number(form.minimum_stock)

  if (Number.isNaN(minimumStock) || minimumStock < 0) {
    errorMessage.value = 'O estoque mínimo deve ser um número igual ou maior que zero.'
    return
  }

  if (!user.value?.id) {
    errorMessage.value = 'Usuário autenticado não encontrado.'
    return
  }

  isSaving.value = true

  try {
    const payload = {
      name: form.name.trim(),
      sku: form.sku.trim(),
      description: form.description.trim(),
      category_id: form.category_id,
      supplier_id: form.supplier_id || null,
      unit: form.unit.trim() || 'un',
      minimum_stock: minimumStock,
      status: form.status,
    }

    if (editingId.value) {
      await updateProduct(editingId.value, payload)
      toast.success('Produto atualizado', 'As alterações foram salvas com sucesso.')
    } else {
      await createProduct({
        ...payload,
        created_by: user.value.id,
      })
      toast.success('Produto criado', 'O novo produto foi cadastrado com sucesso.')
    }

    resetForm()
    await loadData()
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Não foi possível salvar o produto.'

    errorMessage.value = message
    toast.error('Erro ao salvar produto', message)
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
    await deleteProduct(pendingDeleteId.value)

    if (editingId.value === pendingDeleteId.value) {
      resetForm()
    }

    toast.success('Produto excluído', 'O registro foi removido com sucesso.')
    closeDeleteDialog()
    await loadData()
  } catch (error) {
    const message =
      error instanceof Error ? error.message : 'Não foi possível excluir o produto.'

    toast.error('Erro ao excluir produto', message)
  } finally {
    isDeleting.value = false
  }
}

function getCurrentStock(productId: string) {
  return stockSummary.value.find((item) => item.product_id === productId)?.current_stock ?? 0
}

onMounted(loadData)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Produtos"
      description="Cadastro e gestão dos itens de estoque."
    />

    <PageToolbar
      title="Gestão de produtos"
      description="Cadastre produtos, mantenha vínculos e acompanhe alertas de estoque."
    >
      <BaseButton variant="secondary" :disabled="isLoading" @click="loadData">
        Recarregar
      </BaseButton>

      <BaseButton variant="secondary" @click="resetFilters">
        Limpar filtros
      </BaseButton>

      <BaseButton v-if="isEditing" @click="resetForm">
        Novo produto
      </BaseButton>
    </PageToolbar>

    <div class="grid gap-6 xl:grid-cols-[460px_minmax(0,1fr)]">
      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-6">
          <h2 class="text-lg font-semibold text-zinc-100">
            {{ isEditing ? 'Editar produto' : 'Novo produto' }}
          </h2>
          <p class="mt-1 text-sm text-zinc-400">
            Preencha os campos para salvar o produto.
          </p>
        </div>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <BaseInput
            id="product-name"
            v-model="form.name"
            label="Nome"
            placeholder="Ex.: Mouse USB Office"
            :disabled="isSaving"
          />

          <BaseInput
            id="product-sku"
            v-model="form.sku"
            label="SKU"
            placeholder="Ex.: MOU-USB-001"
            :disabled="isSaving"
          />

          <BaseTextarea
            id="product-description"
            v-model="form.description"
            label="Descrição"
            placeholder="Descreva o produto"
            :disabled="isSaving"
          />

          <label for="product-category" class="block space-y-2">
            <span class="text-sm font-medium text-zinc-200">Categoria</span>

            <select
              id="product-category"
              v-model="form.category_id"
              :disabled="isSaving"
              class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
            >
              <option disabled value="">Selecione uma categoria</option>
              <option v-for="category in categories" :key="category.id" :value="category.id">
                {{ category.name }}
              </option>
            </select>
          </label>

          <label for="product-supplier" class="block space-y-2">
            <span class="text-sm font-medium text-zinc-200">Fornecedor</span>

            <select
              id="product-supplier"
              v-model="form.supplier_id"
              :disabled="isSaving"
              class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
            >
              <option value="">Sem fornecedor</option>
              <option v-for="supplier in suppliers" :key="supplier.id" :value="supplier.id">
                {{ supplier.name }}
              </option>
            </select>
          </label>

          <div class="grid gap-4 md:grid-cols-2">
            <BaseInput
              id="product-unit"
              v-model="form.unit"
              label="Unidade"
              placeholder="un"
              :disabled="isSaving"
            />

            <BaseInput
              id="product-minimum-stock"
              v-model="form.minimum_stock"
              label="Estoque mínimo"
              type="number"
              placeholder="0"
              :disabled="isSaving"
            />
          </div>

          <label for="product-status" class="block space-y-2">
            <span class="text-sm font-medium text-zinc-200">Status</span>

            <select
              id="product-status"
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
            {{ isSaving ? 'Salvando...' : isEditing ? 'Atualizar produto' : 'Criar produto' }}
          </BaseButton>
        </form>
      </div>

      <div class="space-y-6">
        <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
          <div class="mb-4">
            <h2 class="text-lg font-semibold text-zinc-100">Filtros</h2>
            <p class="mt-1 text-sm text-zinc-400">
              Refine a visualização dos produtos cadastrados.
            </p>
          </div>

          <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
            <BaseInput
              id="products-search"
              v-model="search"
              label="Buscar"
              placeholder="Nome ou SKU"
            />

            <label class="block space-y-2">
              <span class="text-sm font-medium text-zinc-200">Status</span>
              <select
                v-model="filterStatus"
                class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
              >
                <option value="all">Todos</option>
                <option value="active">Ativos</option>
                <option value="inactive">Inativos</option>
              </select>
            </label>

            <label class="block space-y-2">
              <span class="text-sm font-medium text-zinc-200">Categoria</span>
              <select
                v-model="filterCategoryId"
                class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
              >
                <option value="all">Todas</option>
                <option v-for="category in categories" :key="category.id" :value="category.id">
                  {{ category.name }}
                </option>
              </select>
            </label>

            <label class="block space-y-2">
              <span class="text-sm font-medium text-zinc-200">Fornecedor</span>
              <select
                v-model="filterSupplierId"
                class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
              >
                <option value="all">Todos</option>
                <option v-for="supplier in suppliers" :key="supplier.id" :value="supplier.id">
                  {{ supplier.name }}
                </option>
              </select>
            </label>

            <label class="flex items-center gap-3 rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-200">
              <input
                v-model="stockOnlyLow"
                type="checkbox"
                class="h-4 w-4 rounded border-zinc-700 bg-zinc-900"
              />
              Somente estoque baixo
            </label>
          </div>
        </div>

        <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
          <div class="mb-6 flex items-center justify-between gap-4">
            <div>
              <h2 class="text-lg font-semibold text-zinc-100">Lista de produtos</h2>
              <p class="mt-1 text-sm text-zinc-400">
                Produtos cadastrados e prontos para movimentação.
              </p>
            </div>

            <span class="rounded-full border border-zinc-700 px-3 py-1 text-xs font-medium text-zinc-300">
              {{ filteredProducts.length }} registro(s)
            </span>
          </div>

          <div v-if="isLoading" class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-6 text-sm text-zinc-400">
            Carregando produtos...
          </div>

          <EmptyState
            v-else-if="filteredProducts.length === 0"
            title="Nenhum produto encontrado"
            description="Ajuste os filtros ou cadastre novos produtos."
          />

          <div v-else class="space-y-4">
            <article
              v-for="product in filteredProducts"
              :key="product.id"
              :class="[
                'rounded-2xl border bg-zinc-950/60 p-5',
                getCurrentStock(product.id) <= product.minimum_stock
                  ? 'border-amber-500/30'
                  : 'border-zinc-800',
              ]"
            >
              <div class="flex flex-col gap-4 md:flex-row md:items-start md:justify-between">
                <div class="min-w-0">
                  <div class="flex flex-wrap items-center gap-3">
                    <h3 class="text-base font-semibold text-zinc-100">
                      {{ product.name }}
                    </h3>

                    <span class="rounded-full bg-zinc-800 px-2.5 py-1 text-xs font-medium text-zinc-300 ring-1 ring-zinc-700">
                      {{ product.sku }}
                    </span>

                    <span
                      :class="[
                        'rounded-full px-2.5 py-1 text-xs font-medium',
                        product.status === 'active'
                          ? 'bg-emerald-500/10 text-emerald-300 ring-1 ring-emerald-500/20'
                          : 'bg-zinc-700/40 text-zinc-300 ring-1 ring-zinc-600',
                      ]"
                    >
                      {{ product.status === 'active' ? 'Ativo' : 'Inativo' }}
                    </span>

                    <span
                      v-if="getCurrentStock(product.id) <= product.minimum_stock"
                      class="rounded-full bg-amber-500/10 px-2.5 py-1 text-xs font-medium text-amber-300 ring-1 ring-amber-500/20"
                    >
                      Estoque baixo
                    </span>
                  </div>

                  <div class="mt-3 grid gap-2 text-sm text-zinc-400 md:grid-cols-2">
                    <p><strong class="text-zinc-300">Categoria:</strong> {{ getCategoryName(product.category_id) }}</p>
                    <p><strong class="text-zinc-300">Fornecedor:</strong> {{ getSupplierName(product.supplier_id) }}</p>
                    <p><strong class="text-zinc-300">Unidade:</strong> {{ product.unit }}</p>
                    <p><strong class="text-zinc-300">Estoque mínimo:</strong> {{ product.minimum_stock }}</p>
                    <p><strong class="text-zinc-300">Estoque atual:</strong> {{ getCurrentStock(product.id) }}</p>
                  </div>

                  <p class="mt-3 text-sm text-zinc-400">
                    {{ product.description || 'Sem descrição informada.' }}
                  </p>
                </div>

                <div class="flex shrink-0 gap-3">
                  <BaseButton variant="secondary" @click="fillForm(product)">
                    Editar
                  </BaseButton>

                  <BaseButton variant="danger" @click="openDeleteDialog(product.id)">
                    Excluir
                  </BaseButton>
                </div>
              </div>
            </article>
          </div>
        </div>
      </div>
    </div>

    <ConfirmDialog
      :open="isDeleteDialogOpen"
      title="Excluir produto"
      description="Essa ação removerá o produto selecionado. Deseja continuar?"
      confirm-text="Excluir"
      :loading="isDeleting"
      @cancel="closeDeleteDialog"
      @confirm="confirmDelete"
    />
  </section>
</template>

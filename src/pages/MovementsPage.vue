<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import BaseButton from '../components/ui/BaseButton.vue'
import BaseInput from '../components/ui/BaseInput.vue'
import BaseTextarea from '../components/ui/BaseTextarea.vue'
import EmptyState from '../components/ui/EmptyState.vue'
import PageHeader from '../components/ui/PageHeader.vue'
import { formatDateTime } from '../lib/format'
import { createMovement, listMovements } from '../services/movements.service'
import { listProductStockSummary } from '../services/products.service'
import type { MovementType } from '../types/database'
import type { MovementWithProduct } from '../types/movement'
import type { ProductStockSummary } from '../types/product'

interface MovementForm {
  product_id: string
  movement_type: MovementType
  quantity: string
  reason: string
  notes: string
}

const movements = ref<MovementWithProduct[]>([])
const products = ref<ProductStockSummary[]>([])
const isLoading = ref(false)
const isSaving = ref(false)
const errorMessage = ref('')
const successMessage = ref('')

const movementSearch = ref('')
const movementTypeFilter = ref<'all' | MovementType>('all')
const startDateFilter = ref('')
const endDateFilter = ref('')

const form = reactive<MovementForm>({
  product_id: '',
  movement_type: 'in',
  quantity: '1',
  reason: '',
  notes: '',
})

const selectedProduct = computed(() =>
  products.value.find((item) => item.product_id === form.product_id) ?? null,
)

const filteredMovements = computed(() => {
  const term = movementSearch.value.trim().toLowerCase()

  return movements.value.filter((movement) => {
    const productName = movement.products?.name?.toLowerCase() ?? ''
    const productSku = movement.products?.sku?.toLowerCase() ?? ''

    const matchesSearch =
      !term || productName.includes(term) || productSku.includes(term)

    const matchesType =
      movementTypeFilter.value === 'all' ||
      movement.movement_type === movementTypeFilter.value

    const movementDate = new Date(movement.created_at)
    const matchesStart =
      !startDateFilter.value || movementDate >= new Date(`${startDateFilter.value}T00:00:00`)

    const matchesEnd =
      !endDateFilter.value || movementDate <= new Date(`${endDateFilter.value}T23:59:59`)

    return matchesSearch && matchesType && matchesStart && matchesEnd
  })
})

function resetForm() {
  form.product_id = products.value[0]?.product_id ?? ''
  form.movement_type = 'in'
  form.quantity = '1'
  form.reason = ''
  form.notes = ''
}

function resetFilters() {
  movementSearch.value = ''
  movementTypeFilter.value = 'all'
  startDateFilter.value = ''
  endDateFilter.value = ''
}

async function loadData() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const [movementsData, productsData] = await Promise.all([
      listMovements(),
      listProductStockSummary(),
    ])

    movements.value = movementsData
    products.value = productsData

    if (!form.product_id && productsData.length > 0) {
      form.product_id = productsData[0].product_id
    }
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Não foi possível carregar as movimentações.'
  } finally {
    isLoading.value = false
  }
}

async function handleSubmit() {
  errorMessage.value = ''
  successMessage.value = ''

  if (!form.product_id) {
    errorMessage.value = 'Selecione um produto.'
    return
  }

  const quantity = Number(form.quantity)

  if (Number.isNaN(quantity) || quantity <= 0) {
    errorMessage.value = 'A quantidade deve ser maior que zero.'
    return
  }

  if (form.movement_type === 'adjustment' && !form.reason.trim()) {
    errorMessage.value = 'Ajuste exige justificativa.'
    return
  }

  isSaving.value = true

  try {
    await createMovement({
      product_id: form.product_id,
      movement_type: form.movement_type,
      quantity,
      reason: form.reason.trim(),
      notes: form.notes.trim(),
    })

    successMessage.value = 'Movimentação registrada com sucesso.'
    resetForm()
    await loadData()
  } catch (error) {
    errorMessage.value =
      error instanceof Error ? error.message : 'Não foi possível registrar a movimentação.'
  } finally {
    isSaving.value = false
  }
}

function getMovementLabel(type: MovementType) {
  if (type === 'in') return 'Entrada'
  if (type === 'out') return 'Saída'
  return 'Ajuste'
}

onMounted(loadData)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Movimentações"
      description="Entradas, saídas e ajustes de estoque."
    />

    <div class="grid gap-6 xl:grid-cols-[420px_minmax(0,1fr)]">
      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-6">
          <h2 class="text-lg font-semibold text-zinc-100">Nova movimentação</h2>
          <p class="mt-1 text-sm text-zinc-400">
            Registre entradas, saídas ou ajustes no estoque.
          </p>
        </div>

        <form class="space-y-4" @submit.prevent="handleSubmit">
          <label for="movement-product" class="block space-y-2">
            <span class="text-sm font-medium text-zinc-200">Produto</span>

            <select
              id="movement-product"
              v-model="form.product_id"
              :disabled="isSaving"
              class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
            >
              <option disabled value="">Selecione um produto</option>
              <option v-for="product in products" :key="product.product_id" :value="product.product_id">
                {{ product.name }} · {{ product.sku }}
              </option>
            </select>
          </label>

          <div
            v-if="selectedProduct"
            class="rounded-xl border border-zinc-800 bg-zinc-950/70 p-4 text-sm text-zinc-400"
          >
            <p><strong class="text-zinc-200">Estoque atual:</strong> {{ selectedProduct.current_stock }}</p>
            <p class="mt-1"><strong class="text-zinc-200">Estoque mínimo:</strong> {{ selectedProduct.minimum_stock }}</p>
          </div>

          <label for="movement-type" class="block space-y-2">
            <span class="text-sm font-medium text-zinc-200">Tipo</span>

            <select
              id="movement-type"
              v-model="form.movement_type"
              :disabled="isSaving"
              class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
            >
              <option value="in">Entrada</option>
              <option value="out">Saída</option>
              <option value="adjustment">Ajuste</option>
            </select>
          </label>

          <BaseInput
            id="movement-quantity"
            v-model="form.quantity"
            label="Quantidade"
            type="number"
            placeholder="1"
            :disabled="isSaving"
          />

          <BaseInput
            id="movement-reason"
            v-model="form.reason"
            label="Justificativa / motivo"
            placeholder="Ex.: reposição, consumo interno, correção"
            :disabled="isSaving"
          />

          <BaseTextarea
            id="movement-notes"
            v-model="form.notes"
            label="Observações"
            placeholder="Detalhes complementares da movimentação"
            :disabled="isSaving"
          />

          <div v-if="errorMessage" class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300">
            {{ errorMessage }}
          </div>

          <div v-if="successMessage" class="rounded-xl border border-emerald-500/30 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-300">
            {{ successMessage }}
          </div>

          <BaseButton type="submit" :disabled="isSaving">
            {{ isSaving ? 'Registrando...' : 'Registrar movimentação' }}
          </BaseButton>
        </form>
      </div>

      <div class="space-y-6">
        <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
          <div class="mb-4">
            <h2 class="text-lg font-semibold text-zinc-100">Filtros do histórico</h2>
            <p class="mt-1 text-sm text-zinc-400">
              Busque e refine as movimentações registradas.
            </p>
          </div>

          <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            <BaseInput
              id="movement-search"
              v-model="movementSearch"
              label="Buscar"
              placeholder="Produto ou SKU"
            />

            <label class="block space-y-2">
              <span class="text-sm font-medium text-zinc-200">Tipo</span>
              <select
                v-model="movementTypeFilter"
                class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
              >
                <option value="all">Todos</option>
                <option value="in">Entrada</option>
                <option value="out">Saída</option>
                <option value="adjustment">Ajuste</option>
              </select>
            </label>

            <BaseInput
              id="movement-start-date"
              v-model="startDateFilter"
              label="Data inicial"
              type="date"
            />

            <BaseInput
              id="movement-end-date"
              v-model="endDateFilter"
              label="Data final"
              type="date"
            />
          </div>

          <div class="mt-4">
            <BaseButton variant="secondary" @click="resetFilters">
              Limpar filtros
            </BaseButton>
          </div>
        </div>

        <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
          <div class="mb-6 flex items-center justify-between gap-4">
            <div>
              <h2 class="text-lg font-semibold text-zinc-100">Histórico</h2>
              <p class="mt-1 text-sm text-zinc-400">
                Histórico imutável das movimentações registradas.
              </p>
            </div>

            <span class="rounded-full border border-zinc-700 px-3 py-1 text-xs font-medium text-zinc-300">
              {{ filteredMovements.length }} registro(s)
            </span>
          </div>

          <div v-if="isLoading" class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-6 text-sm text-zinc-400">
            Carregando movimentações...
          </div>

          <EmptyState
            v-else-if="filteredMovements.length === 0"
            title="Nenhuma movimentação encontrada"
            description="Ajuste os filtros ou registre uma nova movimentação."
          />

          <div v-else class="space-y-4">
            <article
              v-for="movement in filteredMovements"
              :key="movement.id"
              class="rounded-2xl border border-zinc-800 bg-zinc-950/60 p-5"
            >
              <div class="flex flex-col gap-3 md:flex-row md:items-start md:justify-between">
                <div>
                  <div class="flex flex-wrap items-center gap-3">
                    <h3 class="text-base font-semibold text-zinc-100">
                      {{ movement.products?.name || 'Produto' }}
                    </h3>

                    <span class="rounded-full bg-zinc-800 px-2.5 py-1 text-xs font-medium text-zinc-300 ring-1 ring-zinc-700">
                      {{ movement.products?.sku || '—' }}
                    </span>

                    <span
                      :class="[
                        'rounded-full px-2.5 py-1 text-xs font-medium',
                        movement.movement_type === 'in' && 'bg-emerald-500/10 text-emerald-300 ring-1 ring-emerald-500/20',
                        movement.movement_type === 'out' && 'bg-amber-500/10 text-amber-300 ring-1 ring-amber-500/20',
                        movement.movement_type === 'adjustment' && 'bg-sky-500/10 text-sky-300 ring-1 ring-sky-500/20',
                      ]"
                    >
                      {{ getMovementLabel(movement.movement_type) }}
                    </span>
                  </div>

                  <div class="mt-3 space-y-1 text-sm text-zinc-400">
                    <p><strong class="text-zinc-300">Quantidade:</strong> {{ movement.quantity }}</p>
                    <p><strong class="text-zinc-300">Motivo:</strong> {{ movement.reason || '—' }}</p>
                    <p><strong class="text-zinc-300">Observações:</strong> {{ movement.notes || '—' }}</p>
                  </div>
                </div>

                <p class="text-xs text-zinc-500">
                  {{ formatDateTime(movement.created_at) }}
                </p>
              </div>
            </article>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

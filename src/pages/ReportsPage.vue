<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import PageHeader from '../components/ui/PageHeader.vue'
import BaseButton from '../components/ui/BaseButton.vue'
import BaseInput from '../components/ui/BaseInput.vue'
import PageToolbar from '../components/ui/PageToolbar.vue'
import { downloadCsv } from '../lib/csv'
import { getErrorMessage } from '../lib/errors'
import { matchesSearchTerm } from '../lib/filters'
import { formatInteger } from '../lib/format'
import { isLowStock } from '../lib/stock'
import { getStatusBadgeClass, getStockTextClass } from '../lib/ui'
import { listCategories } from '../services/categories.service'
import { listProductStockSummary, listProducts } from '../services/products.service'
import { listSuppliers } from '../services/suppliers.service'
import { listMovements } from '../services/movements.service'
import type { Product } from '../types/product'
import type { ProductStockSummary } from '../types/product'
import type { Category } from '../types/category'
import type { Supplier } from '../types/supplier'
import type { MovementWithProduct } from '../types/movement'

const products = ref<Product[]>([])
const stockSummary = ref<ProductStockSummary[]>([])
const categories = ref<Category[]>([])
const suppliers = ref<Supplier[]>([])
const movements = ref<MovementWithProduct[]>([])
const isLoading = ref(true)
const errorMessage = ref('')

const search = ref('')
const categoryFilter = ref('all')
const supplierFilter = ref('all')
const onlyLowStock = ref(false)

const reportRows = computed(() => {
  return products.value
    .map((product) => {
      const stock = stockSummary.value.find((item) => item.product_id === product.id)

      return {
        ...product,
        current_stock: stock?.current_stock ?? 0,
      }
    })
    .filter((product) => {
      const matchesSearch = matchesSearchTerm([product.name, product.sku], search.value)

      const matchesCategory =
        categoryFilter.value === 'all' || product.category_id === categoryFilter.value

      const matchesSupplier =
        supplierFilter.value === 'all' || (product.supplier_id ?? '') === supplierFilter.value

      const matchesLowStock =
        !onlyLowStock.value || isLowStock(product.current_stock, product.minimum_stock)

      return matchesSearch && matchesCategory && matchesSupplier && matchesLowStock
    })
})

const lowStockCount = computed(() =>
  reportRows.value.filter((item) => isLowStock(item.current_stock, item.minimum_stock)).length,
)

const inactiveCount = computed(() =>
  reportRows.value.filter((item) => item.status === 'inactive').length,
)

const totalCurrentStock = computed(() =>
  reportRows.value.reduce((acc, item) => acc + item.current_stock, 0),
)

const totalMovements = computed(() => movements.value.length)

function getCategoryName(categoryId: string) {
  return categories.value.find((item) => item.id === categoryId)?.name ?? '—'
}

function getSupplierName(supplierId: string | null) {
  if (!supplierId) return '—'
  return suppliers.value.find((item) => item.id === supplierId)?.name ?? '—'
}

function resetFilters() {
  search.value = ''
  categoryFilter.value = 'all'
  supplierFilter.value = 'all'
  onlyLowStock.value = false
}

function printPage() {
  window.print()
}

function exportStockCsv() {
  const rows = reportRows.value.map((item) => ({
    produto: item.name,
    sku: item.sku,
    categoria: getCategoryName(item.category_id),
    fornecedor: getSupplierName(item.supplier_id),
    estoque_atual: item.current_stock,
    estoque_minimo: item.minimum_stock,
    status: item.status === 'active' ? 'Ativo' : 'Inativo',
    unidade: item.unit,
  }))

  downloadCsv('relatorio-estoque.csv', rows)
}

function exportMovementsCsv() {
  const rows = movements.value.map((item) => ({
    produto: item.products?.name ?? '—',
    sku: item.products?.sku ?? '—',
    tipo: item.movement_type,
    quantidade: item.quantity,
    motivo: item.reason ?? '',
    observacoes: item.notes ?? '',
    criado_em: new Date(item.created_at).toLocaleString('pt-BR'),
  }))

  downloadCsv('relatorio-movimentacoes.csv', rows)
}

async function loadData() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const [productsData, stockData, categoriesData, suppliersData, movementsData] =
      await Promise.all([
        listProducts(),
        listProductStockSummary(),
        listCategories(),
        listSuppliers(),
        listMovements(),
      ])

    products.value = productsData
    stockSummary.value = stockData
    categories.value = categoriesData
    suppliers.value = suppliersData
    movements.value = movementsData
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Não foi possível carregar os relatórios.')
  } finally {
    isLoading.value = false
  }
}

onMounted(loadData)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Relatórios"
      description="Consulta operacional do estoque com filtros e visão consolidada."
    />

    <PageToolbar
      title="Visão gerencial"
      description="Analise o estoque atual, exporte dados e acompanhe indicadores consolidados."
    >
      <BaseButton variant="secondary" :disabled="isLoading" @click="loadData">
        Recarregar
      </BaseButton>

      <BaseButton variant="secondary" @click="exportStockCsv">
        Exportar estoque
      </BaseButton>

      <BaseButton variant="secondary" @click="exportMovementsCsv">
        Exportar movimentações
      </BaseButton>

      <BaseButton @click="printPage">
        Imprimir relatório
      </BaseButton>
    </PageToolbar>

    <div
      v-if="errorMessage"
      class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300"
    >
      {{ errorMessage }}
    </div>

    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-5">
        <p class="text-sm text-zinc-400">Itens filtrados</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(reportRows.length) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-amber-500/20 bg-amber-500/5 p-5">
        <p class="text-sm text-amber-300">Estoque baixo</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(lowStockCount) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-5">
        <p class="text-sm text-zinc-400">Itens inativos</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(inactiveCount) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-5">
        <p class="text-sm text-zinc-400">Movimentações totais</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(totalMovements) }}
        </strong>
      </div>
    </div>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6 print:hidden">
      <div class="mb-4">
        <h2 class="text-lg font-semibold text-zinc-100">Filtros do relatório</h2>
        <p class="mt-1 text-sm text-zinc-400">
          Ajuste os critérios antes de analisar, exportar ou imprimir.
        </p>
      </div>

      <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <BaseInput
          id="report-search"
          v-model="search"
          label="Buscar"
          placeholder="Nome ou SKU"
        />

        <label class="block space-y-2">
          <span class="text-sm font-medium text-zinc-200">Categoria</span>
          <select
            v-model="categoryFilter"
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
            v-model="supplierFilter"
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
            v-model="onlyLowStock"
            type="checkbox"
            class="h-4 w-4 rounded border-zinc-700 bg-zinc-900"
          />
          Somente estoque baixo
        </label>
      </div>

      <div class="mt-4">
        <BaseButton variant="secondary" @click="resetFilters">
          Limpar filtros
        </BaseButton>
      </div>
    </div>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
      <div class="mb-5 flex items-center justify-between gap-4">
        <div>
          <h2 class="text-lg font-semibold text-zinc-100">Relatório operacional</h2>
          <p class="mt-1 text-sm text-zinc-400">
            Base consolidada dos produtos cadastrados.
          </p>
        </div>

        <span class="rounded-full border border-zinc-700 px-3 py-1 text-xs font-medium text-zinc-300">
          {{ reportRows.length }} registro(s)
        </span>
      </div>

      <div v-if="isLoading" class="text-sm text-zinc-400">
        Carregando relatório...
      </div>

      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-zinc-800 text-sm">
          <thead>
            <tr class="text-left text-zinc-400">
              <th class="pb-3 pr-4 font-medium">Produto</th>
              <th class="pb-3 pr-4 font-medium">SKU</th>
              <th class="pb-3 pr-4 font-medium">Categoria</th>
              <th class="pb-3 pr-4 font-medium">Fornecedor</th>
              <th class="pb-3 pr-4 font-medium">Atual</th>
              <th class="pb-3 pr-4 font-medium">Mínimo</th>
              <th class="pb-3 pr-4 font-medium">Status</th>
            </tr>
          </thead>

          <tbody class="divide-y divide-zinc-800">
            <tr v-for="item in reportRows" :key="item.id">
              <td class="py-3 pr-4 text-zinc-100">{{ item.name }}</td>
              <td class="py-3 pr-4 text-zinc-400">{{ item.sku }}</td>
              <td class="py-3 pr-4 text-zinc-400">{{ getCategoryName(item.category_id) }}</td>
              <td class="py-3 pr-4 text-zinc-400">{{ getSupplierName(item.supplier_id) }}</td>
              <td :class="['py-3 pr-4 font-medium', getStockTextClass(item.current_stock, item.minimum_stock)]">
                {{ formatInteger(item.current_stock) }}
              </td>
              <td class="py-3 pr-4 text-zinc-400">{{ formatInteger(item.minimum_stock) }}</td>
              <td class="py-3 pr-4">
                <span :class="['rounded-full px-2.5 py-1 text-xs font-medium', getStatusBadgeClass(item.status)]">
                  {{ item.status === 'active' ? 'Ativo' : 'Inativo' }}
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <div class="mt-6 rounded-2xl border border-zinc-800 bg-zinc-950/40 p-4">
        <p class="text-sm text-zinc-400">
          <strong class="text-zinc-200">Estoque consolidado atual:</strong>
          {{ formatInteger(totalCurrentStock) }}
        </p>
      </div>
    </div>
  </section>
</template>

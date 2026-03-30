<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import PageHeader from '../components/ui/PageHeader.vue'
import PermissionBanner from '../components/ui/PermissionBanner.vue'
import StatCard from '../components/ui/StatCard.vue'
import { useAccess } from '../composables/useAccess'
import { countCategories } from '../services/categories.service'
import { countSuppliers } from '../services/suppliers.service'
import { countProducts, listProductStockSummary } from '../services/products.service'
import { countMovements } from '../services/movements.service'
import type { ProductStockSummary } from '../types/product'
import { getErrorMessage } from '../lib/errors'
import { formatInteger } from '../lib/format'
import { isLowStock } from '../lib/stock'
import { getStatusBadgeClass, getStockTextClass } from '../lib/ui'

const { isOperator } = useAccess()

const categoriesCount = ref(0)
const suppliersCount = ref(0)
const productsCount = ref(0)
const movementsCount = ref(0)
const stockSummary = ref<ProductStockSummary[]>([])
const isLoading = ref(true)
const errorMessage = ref('')

const lowStockProducts = computed(() =>
  stockSummary.value.filter((item) => isLowStock(item.current_stock, item.minimum_stock)),
)

const inactiveProducts = computed(() =>
  stockSummary.value.filter((item) => item.status === 'inactive'),
)

async function loadDashboard() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const [categories, suppliers, products, movements, stock] = await Promise.all([
      countCategories(),
      countSuppliers(),
      countProducts(),
      countMovements(),
      listProductStockSummary(),
    ])

    categoriesCount.value = categories
    suppliersCount.value = suppliers
    productsCount.value = products
    movementsCount.value = movements
    stockSummary.value = stock
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Não foi possível carregar o dashboard.')
  } finally {
    isLoading.value = false
  }
}

onMounted(loadDashboard)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Dashboard"
      description="Visão geral do sistema de gestão de estoque."
    />

    <PermissionBanner
      v-if="isOperator"
      title="Perfil com acesso operacional"
      description="Seu usuário pode registrar movimentações e consultar relatórios, mas não pode alterar a estrutura cadastral do sistema."
    />

    <div
      v-if="errorMessage"
      class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300"
    >
      {{ errorMessage }}
    </div>

    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      <StatCard label="Categorias" :value="isLoading ? '...' : formatInteger(categoriesCount)" />
      <StatCard label="Fornecedores" :value="isLoading ? '...' : formatInteger(suppliersCount)" />
      <StatCard label="Produtos" :value="isLoading ? '...' : formatInteger(productsCount)" />
      <StatCard label="Movimentações" :value="isLoading ? '...' : formatInteger(movementsCount)" />
    </div>

    <div class="grid gap-4 md:grid-cols-2">
      <div class="rounded-2xl border border-amber-500/20 bg-amber-500/5 p-5">
        <p class="text-sm text-amber-300">Itens com estoque baixo</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(lowStockProducts.length) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-5">
        <p class="text-sm text-zinc-400">Itens inativos</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(inactiveProducts.length) }}
        </strong>
      </div>
    </div>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
      <div class="mb-5">
        <h2 class="text-lg font-semibold text-zinc-100">Produtos com alerta</h2>
        <p class="mt-1 text-sm text-zinc-400">
          Produtos com estoque atual igual ou abaixo do mínimo definido.
        </p>
      </div>

      <div v-if="isLoading" class="text-sm text-zinc-400">
        Carregando alertas...
      </div>

      <div
        v-else-if="lowStockProducts.length === 0"
        class="rounded-2xl border border-emerald-500/20 bg-emerald-500/5 p-5 text-sm text-emerald-300"
      >
        Nenhum produto em alerta de estoque no momento.
      </div>

      <div v-else class="space-y-3">
        <article
          v-for="item in lowStockProducts"
          :key="item.product_id"
          class="rounded-2xl border border-amber-500/20 bg-zinc-950/50 p-4"
        >
          <div class="flex flex-col gap-2 md:flex-row md:items-center md:justify-between">
            <div>
              <h3 class="text-sm font-semibold text-zinc-100">{{ item.name }}</h3>
              <p class="mt-1 text-xs text-zinc-400">SKU: {{ item.sku }}</p>
            </div>

            <div class="text-sm">
              <span class="text-zinc-400">Atual:</span>
              <strong :class="['ml-1', getStockTextClass(item.current_stock, item.minimum_stock)]">
                {{ formatInteger(item.current_stock) }}
              </strong>
              <span class="ml-3 text-zinc-400">Mínimo:</span>
              <strong class="ml-1 text-zinc-100">{{ formatInteger(item.minimum_stock) }}</strong>
            </div>
          </div>
        </article>
      </div>
    </div>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
      <div class="mb-5">
        <h2 class="text-lg font-semibold text-zinc-100">Resumo de estoque</h2>
        <p class="mt-1 text-sm text-zinc-400">
          Situação atual dos produtos cadastrados.
        </p>
      </div>

      <div v-if="isLoading" class="text-sm text-zinc-400">
        Carregando resumo de estoque...
      </div>

      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-zinc-800 text-sm">
          <thead>
            <tr class="text-left text-zinc-400">
              <th class="pb-3 pr-4 font-medium">Produto</th>
              <th class="pb-3 pr-4 font-medium">SKU</th>
              <th class="pb-3 pr-4 font-medium">Estoque atual</th>
              <th class="pb-3 pr-4 font-medium">Estoque mínimo</th>
              <th class="pb-3 pr-4 font-medium">Status</th>
            </tr>
          </thead>

          <tbody class="divide-y divide-zinc-800">
            <tr v-for="item in stockSummary" :key="item.product_id">
              <td class="py-3 pr-4 text-zinc-100">{{ item.name }}</td>
              <td class="py-3 pr-4 text-zinc-400">{{ item.sku }}</td>
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
    </div>
  </section>
</template>

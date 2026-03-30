<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import PageHeader from '../components/ui/PageHeader.vue'
import PageToolbar from '../components/ui/PageToolbar.vue'
import BaseButton from '../components/ui/BaseButton.vue'
import EmptyState from '../components/ui/EmptyState.vue'
import { getErrorMessage } from '../lib/errors'
import { formatInteger } from '../lib/format'
import { isLowStock } from '../lib/stock'
import { listCategories } from '../services/categories.service'
import { listProductStockSummary, listProducts } from '../services/products.service'
import { listSuppliers } from '../services/suppliers.service'
import type { Category } from '../types/category'
import type { ProductStockSummary, Product } from '../types/product'
import type { Supplier } from '../types/supplier'

const isLoading = ref(false)
const errorMessage = ref('')
const stockSummary = ref<ProductStockSummary[]>([])
const products = ref<Product[]>([])
const categories = ref<Category[]>([])
const suppliers = ref<Supplier[]>([])

const lowStockItems = computed(() =>
  stockSummary.value.filter((item) => isLowStock(item.current_stock, item.minimum_stock)),
)

const inactiveItems = computed(() =>
  stockSummary.value.filter((item) => item.status === 'inactive'),
)

function getProduct(productId: string) {
  return products.value.find((item) => item.id === productId) ?? null
}

function getCategoryName(productId: string) {
  const product = getProduct(productId)
  if (!product) return '—'

  return categories.value.find((item) => item.id === product.category_id)?.name ?? '—'
}

function getSupplierName(productId: string) {
  const product = getProduct(productId)
  if (!product?.supplier_id) return '—'

  return suppliers.value.find((item) => item.id === product.supplier_id)?.name ?? '—'
}

async function loadData() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    const [stockData, productsData, categoriesData, suppliersData] = await Promise.all([
      listProductStockSummary(),
      listProducts(),
      listCategories(),
      listSuppliers(),
    ])

    stockSummary.value = stockData
    products.value = productsData
    categories.value = categoriesData
    suppliers.value = suppliersData
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Não foi possível carregar os alertas.')
  } finally {
    isLoading.value = false
  }
}

onMounted(loadData)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Alertas operacionais"
      description="Acompanhe rapidamente produtos críticos e itens inativos."
    />

    <PageToolbar
      title="Monitoramento do estoque"
      description="Visão dedicada para acompanhar situações que exigem atenção."
    >
      <BaseButton variant="secondary" :disabled="isLoading" @click="loadData">
        Recarregar
      </BaseButton>
    </PageToolbar>

    <div
      v-if="errorMessage"
      class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300"
    >
      {{ errorMessage }}
    </div>

    <div class="grid gap-4 md:grid-cols-2">
      <div class="rounded-2xl border border-amber-500/20 bg-amber-500/5 p-5">
        <p class="text-sm text-amber-300">Produtos com estoque baixo</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(lowStockItems.length) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-5">
        <p class="text-sm text-zinc-400">Produtos inativos</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(inactiveItems.length) }}
        </strong>
      </div>
    </div>

    <div class="grid gap-6 xl:grid-cols-2">
      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-5">
          <h2 class="text-lg font-semibold text-zinc-100">Estoque crítico</h2>
          <p class="mt-1 text-sm text-zinc-400">
            Produtos com saldo atual igual ou abaixo do estoque mínimo.
          </p>
        </div>

        <div v-if="isLoading" class="text-sm text-zinc-400">
          Carregando alertas...
        </div>

        <EmptyState
          v-else-if="lowStockItems.length === 0"
          title="Nenhum item crítico"
          description="Não há produtos com estoque abaixo do limite definido."
        />

        <div v-else class="space-y-4">
          <article
            v-for="item in lowStockItems"
            :key="item.product_id"
            class="rounded-2xl border border-amber-500/20 bg-zinc-950/50 p-4"
          >
            <div class="flex flex-col gap-3">
              <div class="flex flex-wrap items-center gap-3">
                <h3 class="text-sm font-semibold text-zinc-100">{{ item.name }}</h3>
                <span class="rounded-full bg-zinc-800 px-2.5 py-1 text-xs font-medium text-zinc-300">
                  {{ item.sku }}
                </span>
              </div>

              <div class="grid gap-2 text-sm text-zinc-400 md:grid-cols-2">
                <p><strong class="text-zinc-300">Categoria:</strong> {{ getCategoryName(item.product_id) }}</p>
                <p><strong class="text-zinc-300">Fornecedor:</strong> {{ getSupplierName(item.product_id) }}</p>
                <p><strong class="text-zinc-300">Atual:</strong> {{ formatInteger(item.current_stock) }}</p>
                <p><strong class="text-zinc-300">Mínimo:</strong> {{ formatInteger(item.minimum_stock) }}</p>
              </div>
            </div>
          </article>
        </div>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
        <div class="mb-5">
          <h2 class="text-lg font-semibold text-zinc-100">Produtos inativos</h2>
          <p class="mt-1 text-sm text-zinc-400">
            Itens inativos ainda cadastrados na base.
          </p>
        </div>

        <div v-if="isLoading" class="text-sm text-zinc-400">
          Carregando produtos inativos...
        </div>

        <EmptyState
          v-else-if="inactiveItems.length === 0"
          title="Nenhum item inativo"
          description="Todos os produtos listados estão ativos no momento."
        />

        <div v-else class="space-y-4">
          <article
            v-for="item in inactiveItems"
            :key="item.product_id"
            class="rounded-2xl border border-zinc-800 bg-zinc-950/50 p-4"
          >
            <div class="flex flex-col gap-3">
              <div class="flex flex-wrap items-center gap-3">
                <h3 class="text-sm font-semibold text-zinc-100">{{ item.name }}</h3>
                <span class="rounded-full bg-zinc-800 px-2.5 py-1 text-xs font-medium text-zinc-300">
                  {{ item.sku }}
                </span>
              </div>

              <div class="grid gap-2 text-sm text-zinc-400 md:grid-cols-2">
                <p><strong class="text-zinc-300">Categoria:</strong> {{ getCategoryName(item.product_id) }}</p>
                <p><strong class="text-zinc-300">Fornecedor:</strong> {{ getSupplierName(item.product_id) }}</p>
                <p><strong class="text-zinc-300">Estoque atual:</strong> {{ formatInteger(item.current_stock) }}</p>
                <p><strong class="text-zinc-300">Estoque mínimo:</strong> {{ formatInteger(item.minimum_stock) }}</p>
              </div>
            </div>
          </article>
        </div>
      </div>
    </div>
  </section>
</template>

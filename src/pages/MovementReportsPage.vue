<script setup lang="ts">
import { computed, onMounted, ref } from 'vue'
import PageHeader from '../components/ui/PageHeader.vue'
import PageToolbar from '../components/ui/PageToolbar.vue'
import BaseButton from '../components/ui/BaseButton.vue'
import BaseInput from '../components/ui/BaseInput.vue'
import EmptyState from '../components/ui/EmptyState.vue'
import { downloadCsv } from '../lib/csv'
import { getErrorMessage } from '../lib/errors'
import { matchesDateRange, matchesSearchTerm } from '../lib/filters'
import { formatDateTime, formatInteger } from '../lib/format'
import { getMovementLabel } from '../lib/stock'
import { getMovementBadgeClass } from '../lib/ui'
import { listMovements } from '../services/movements.service'
import type { MovementType } from '../types/database'
import type { MovementWithProduct } from '../types/movement'

const movements = ref<MovementWithProduct[]>([])
const isLoading = ref(false)
const errorMessage = ref('')

const search = ref('')
const typeFilter = ref<'all' | MovementType>('all')
const startDate = ref('')
const endDate = ref('')

const filteredMovements = computed(() => {
  return movements.value.filter((movement) => {
    const matchesSearch = matchesSearchTerm(
      [movement.products?.name, movement.products?.sku],
      search.value,
    )

    const matchesType =
      typeFilter.value === 'all' || movement.movement_type === typeFilter.value

    const matchesPeriod = matchesDateRange(
      movement.created_at,
      startDate.value,
      endDate.value,
    )

    return matchesSearch && matchesType && matchesPeriod
  })
})

const totalEntries = computed(() =>
  filteredMovements.value
    .filter((item) => item.movement_type === 'in')
    .reduce((acc, item) => acc + item.quantity, 0),
)

const totalOutputs = computed(() =>
  filteredMovements.value
    .filter((item) => item.movement_type === 'out')
    .reduce((acc, item) => acc + item.quantity, 0),
)

const totalAdjustments = computed(() =>
  filteredMovements.value
    .filter((item) => item.movement_type === 'adjustment')
    .reduce((acc, item) => acc + item.quantity, 0),
)

function resetFilters() {
  search.value = ''
  typeFilter.value = 'all'
  startDate.value = ''
  endDate.value = ''
}

function exportCsv() {
  const rows = filteredMovements.value.map((item) => ({
    produto: item.products?.name ?? '—',
    sku: item.products?.sku ?? '—',
    tipo: getMovementLabel(item.movement_type),
    quantidade: item.quantity,
    motivo: item.reason ?? '',
    observacoes: item.notes ?? '',
    criado_em: formatDateTime(item.created_at),
  }))

  downloadCsv('historico-movimentacoes.csv', rows)
}

async function loadData() {
  isLoading.value = true
  errorMessage.value = ''

  try {
    movements.value = await listMovements()
  } catch (error) {
    errorMessage.value = getErrorMessage(error, 'Não foi possível carregar o histórico.')
  } finally {
    isLoading.value = false
  }
}

onMounted(loadData)
</script>

<template>
  <section class="space-y-6">
    <PageHeader
      title="Relatório de movimentações"
      description="Consulte o histórico operacional com filtros e indicadores por período."
    />

    <PageToolbar
      title="Histórico operacional"
      description="Analise entradas, saídas e ajustes com visão consolidada."
    >
      <BaseButton variant="secondary" :disabled="isLoading" @click="loadData">
        Recarregar
      </BaseButton>

      <BaseButton variant="secondary" @click="resetFilters">
        Limpar filtros
      </BaseButton>

      <BaseButton @click="exportCsv">
        Exportar CSV
      </BaseButton>
    </PageToolbar>

    <div
      v-if="errorMessage"
      class="rounded-xl border border-red-500/30 bg-red-500/10 px-4 py-3 text-sm text-red-300"
    >
      {{ errorMessage }}
    </div>

    <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
      <div class="rounded-2xl border border-emerald-500/20 bg-emerald-500/5 p-5">
        <p class="text-sm text-emerald-300">Entradas</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(totalEntries) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-amber-500/20 bg-amber-500/5 p-5">
        <p class="text-sm text-amber-300">Saídas</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(totalOutputs) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-sky-500/20 bg-sky-500/5 p-5">
        <p class="text-sm text-sky-300">Ajustes</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(totalAdjustments) }}
        </strong>
      </div>

      <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-5">
        <p class="text-sm text-zinc-400">Movimentações filtradas</p>
        <strong class="mt-3 block text-3xl font-semibold text-zinc-100">
          {{ isLoading ? '...' : formatInteger(filteredMovements.length) }}
        </strong>
      </div>
    </div>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
      <div class="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <BaseInput
          id="movement-report-search"
          v-model="search"
          label="Buscar"
          placeholder="Produto ou SKU"
        />

        <label class="block space-y-2">
          <span class="text-sm font-medium text-zinc-200">Tipo</span>
          <select
            v-model="typeFilter"
            class="w-full rounded-xl border border-zinc-800 bg-zinc-950 px-4 py-3 text-sm text-zinc-100 outline-none transition focus:border-zinc-600"
          >
            <option value="all">Todos</option>
            <option value="in">Entrada</option>
            <option value="out">Saída</option>
            <option value="adjustment">Ajuste</option>
          </select>
        </label>

        <BaseInput
          id="movement-report-start"
          v-model="startDate"
          label="Data inicial"
          type="date"
        />

        <BaseInput
          id="movement-report-end"
          v-model="endDate"
          label="Data final"
          type="date"
        />
      </div>
    </div>

    <div class="rounded-2xl border border-zinc-800 bg-zinc-900 p-6">
      <div class="mb-5">
        <h2 class="text-lg font-semibold text-zinc-100">Histórico filtrado</h2>
        <p class="mt-1 text-sm text-zinc-400">
          Auditoria operacional das movimentações registradas.
        </p>
      </div>

      <div v-if="isLoading" class="text-sm text-zinc-400">
        Carregando histórico...
      </div>

      <EmptyState
        v-else-if="filteredMovements.length === 0"
        title="Nenhuma movimentação encontrada"
        description="Ajuste os filtros para ampliar a consulta."
      />

      <div v-else class="overflow-x-auto">
        <table class="min-w-full divide-y divide-zinc-800 text-sm">
          <thead>
            <tr class="text-left text-zinc-400">
              <th class="pb-3 pr-4 font-medium">Produto</th>
              <th class="pb-3 pr-4 font-medium">SKU</th>
              <th class="pb-3 pr-4 font-medium">Tipo</th>
              <th class="pb-3 pr-4 font-medium">Quantidade</th>
              <th class="pb-3 pr-4 font-medium">Motivo</th>
              <th class="pb-3 pr-4 font-medium">Data</th>
            </tr>
          </thead>

          <tbody class="divide-y divide-zinc-800">
            <tr v-for="item in filteredMovements" :key="item.id">
              <td class="py-3 pr-4 text-zinc-100">{{ item.products?.name ?? '—' }}</td>
              <td class="py-3 pr-4 text-zinc-400">{{ item.products?.sku ?? '—' }}</td>
              <td class="py-3 pr-4">
                <span
                  :class="[
                    'rounded-full px-2.5 py-1 text-xs font-medium',
                    getMovementBadgeClass(item.movement_type),
                  ]"
                >
                  {{ getMovementLabel(item.movement_type) }}
                </span>
              </td>
              <td class="py-3 pr-4 text-zinc-100">{{ formatInteger(item.quantity) }}</td>
              <td class="py-3 pr-4 text-zinc-400">{{ item.reason || '—' }}</td>
              <td class="py-3 pr-4 text-zinc-400">{{ formatDateTime(item.created_at) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>
</template>

import { computed, ref } from 'vue'
import { getMyProfile } from '../services/profile.service'
import type { ProfileRow } from '../types/database'

const profile = ref<ProfileRow | null>(null)
const loading = ref(false)
const initialized = ref(false)

export function useAccess() {
  const isAdmin = computed(() => profile.value?.app_role === 'admin')
  const isOperator = computed(() => profile.value?.app_role === 'operator')

  async function loadProfile() {
    loading.value = true

    try {
      profile.value = await getMyProfile()
    } finally {
      loading.value = false
      initialized.value = true
    }
  }

  function resetProfile() {
    profile.value = null
    initialized.value = true
  }

  return {
    profile,
    loading,
    initialized,
    isAdmin,
    isOperator,
    loadProfile,
    resetProfile,
  }
}

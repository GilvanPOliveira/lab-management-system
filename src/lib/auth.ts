import { computed, ref } from 'vue'
import type { AppBackendMode, AppSession, AppUser } from '../types/auth'
import {
  backendModeState,
  getBackendMode,
  getSupabaseConfigError,
  isSupabaseConfigured,
  listAvailableBackends,
  setBackendMode,
} from './backend'
import { getDemoSession, signInDemo, signOutDemo } from './demo'
import { clearSupabaseSessionStorage, getSupabaseClient } from './supabase'

const session = ref<AppSession | null>(null)
const initialized = ref(false)
const loading = ref(false)

let authListenerInitialized = false

function mapSupabaseSession(rawSession: {
  user: {
    id: string
    email?: string | null
    user_metadata?: Record<string, unknown>
  }
} | null): AppSession | null {
  if (!rawSession) {
    return null
  }

  const fullName =
    typeof rawSession.user.user_metadata?.full_name === 'string'
      ? rawSession.user.user_metadata.full_name
      : undefined

  return {
    user: {
      id: rawSession.user.id,
      email: rawSession.user.email ?? null,
      user_metadata: {
        full_name: fullName,
      },
    },
  }
}

async function initSupabaseAuth() {
  if (!isSupabaseConfigured()) {
    session.value = null
    initialized.value = true
    return
  }

  const supabase = getSupabaseClient()

  if (!authListenerInitialized) {
    supabase.auth.onAuthStateChange((_event, newSession) => {
      session.value = mapSupabaseSession(newSession)
      initialized.value = true
    })

    authListenerInitialized = true
  }

  const { data, error } = await supabase.auth.getSession()

  if (error) {
    throw new Error(error.message)
  }

  session.value = mapSupabaseSession(data.session)
  initialized.value = true
}

export async function initAuth() {
  if (getBackendMode() === 'demo') {
    session.value = getDemoSession()
    initialized.value = true
    return
  }

  await initSupabaseAuth()
}

export function getCurrentSession() {
  return session.value
}

export function isAuthInitialized() {
  return initialized.value
}

export async function signIn(email: string, password: string) {
  loading.value = true

  try {
    if (getBackendMode() === 'demo') {
      session.value = signInDemo(email, password)
      initialized.value = true
      return
    }

    if (!isSupabaseConfigured()) {
      throw new Error(getSupabaseConfigError())
    }

    const supabase = getSupabaseClient()
    const { error } = await supabase.auth.signInWithPassword({ email, password })

    if (error) {
      throw new Error(error.message)
    }
  } finally {
    loading.value = false
  }
}

export async function signOut() {
  loading.value = true

  try {
    if (getBackendMode() === 'demo') {
      signOutDemo()
      session.value = null
      initialized.value = true
      return
    }

    if (!isSupabaseConfigured()) {
      session.value = null
      initialized.value = true
      return
    }

    const supabase = getSupabaseClient()
    const { error } = await supabase.auth.signOut()

    if (error) {
      throw new Error(error.message)
    }
  } finally {
    loading.value = false
  }
}

export async function switchBackendMode(mode: AppBackendMode) {
  if (getBackendMode() === 'supabase' && mode !== 'supabase') {
    await clearSupabaseSessionStorage()
  }

  setBackendMode(mode)
  session.value = null
  initialized.value = false
  await initAuth()
}

export function useAuth() {
  const user = computed<AppUser | null>(() => session.value?.user ?? null)
  const isAuthenticated = computed(() => Boolean(user.value))
  const availableBackends = computed(() => listAvailableBackends())

  return {
    session,
    user,
    initialized,
    loading,
    isAuthenticated,
    backendMode: computed(() => backendModeState.value),
    availableBackends,
    initAuth,
    signIn,
    signOut,
    switchBackendMode,
  }
}

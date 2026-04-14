import { ref } from 'vue'
import type { AppBackendMode } from '../types/auth'

const BACKEND_STORAGE_KEY = 'lab-management-backend-mode'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY
const appMode = import.meta.env.VITE_APP_MODE
const defaultBackend = import.meta.env.VITE_DEFAULT_BACKEND

function getConfiguredAppMode(): 'demo' | 'supabase' | 'both' {
  if (appMode === 'demo' || appMode === 'supabase' || appMode === 'both') {
    return appMode
  }

  return 'both'
}

export function isSupabaseConfigured() {
  return getConfiguredAppMode() !== 'demo' && Boolean(supabaseUrl && supabaseAnonKey)
}

export function getSupabaseConfigError() {
  return 'Supabase nao configurado. Defina VITE_SUPABASE_URL e VITE_SUPABASE_ANON_KEY para usar este modo.'
}

function getDefaultBackendMode(): AppBackendMode {
  if (defaultBackend === 'demo' || defaultBackend === 'supabase') {
    if (defaultBackend === 'supabase' && !isSupabaseConfigured()) {
      return 'demo'
    }

    if (defaultBackend === 'supabase' && getConfiguredAppMode() === 'demo') {
      return 'demo'
    }

    if (defaultBackend === 'demo' && getConfiguredAppMode() === 'supabase') {
      return 'supabase'
    }

    return defaultBackend
  }

  if (getConfiguredAppMode() === 'demo') {
    return 'demo'
  }

  return isSupabaseConfigured() ? 'supabase' : 'demo'
}

function readStoredBackendMode(): AppBackendMode | null {
  if (typeof window === 'undefined') {
    return null
  }

  const rawValue = window.localStorage.getItem(BACKEND_STORAGE_KEY)

  if (rawValue === 'demo' || rawValue === 'supabase') {
    return rawValue
  }

  return null
}

function resolveInitialBackendMode(): AppBackendMode {
  const storedMode = readStoredBackendMode()

  if (storedMode === 'supabase' && !isSupabaseConfigured()) {
    return 'demo'
  }

  return storedMode ?? getDefaultBackendMode()
}

export const backendModeState = ref<AppBackendMode>(resolveInitialBackendMode())

export function getBackendMode(): AppBackendMode {
  return backendModeState.value
}

export function setBackendMode(mode: AppBackendMode) {
  const resolvedMode =
    mode === 'supabase' && !isSupabaseConfigured()
      ? 'demo'
      : mode

  backendModeState.value = resolvedMode

  if (typeof window !== 'undefined') {
    window.localStorage.setItem(BACKEND_STORAGE_KEY, resolvedMode)
  }
}

export function getBackendLabel(mode: AppBackendMode = getBackendMode()) {
  return mode === 'demo' ? 'Demo' : 'Supabase'
}

export function listAvailableBackends() {
  const configuredAppMode = getConfiguredAppMode()

  return [
    {
      mode: 'demo' as const,
      label: 'Demo',
      description: 'Executa com dados locais de demonstracao no navegador.',
      available: configuredAppMode !== 'supabase',
    },
    {
      mode: 'supabase' as const,
      label: 'Supabase',
      description: isSupabaseConfigured()
        ? 'Usa autenticacao e persistencia reais no Supabase.'
        : 'Requer variaveis de ambiente do Supabase para funcionar.',
      available: configuredAppMode !== 'demo' && isSupabaseConfigured(),
    },
  ]
}

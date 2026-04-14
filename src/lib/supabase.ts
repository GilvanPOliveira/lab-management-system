import { createClient, type SupabaseClient } from '@supabase/supabase-js'
import { getSupabaseConfigError, isSupabaseConfigured } from './backend'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

let supabaseClient: SupabaseClient | null = null

export function getSupabaseClient() {
  if (!isSupabaseConfigured()) {
    throw new Error(getSupabaseConfigError())
  }

  if (!supabaseClient) {
    supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      auth: {
        persistSession: true,
        autoRefreshToken: true,
      },
    })
  }

  return supabaseClient
}

export async function clearSupabaseSessionStorage() {
  if (typeof window === 'undefined' || !supabaseUrl) {
    return
  }

  const projectRef = new URL(supabaseUrl).hostname.split('.')[0]
  const storageKey = `sb-${projectRef}-auth-token`

  window.localStorage.removeItem(storageKey)

  if (supabaseClient) {
    try {
      await supabaseClient.auth.signOut()
    } catch {
      // Ignore network errors while clearing a broken remote session.
    }
  }
}

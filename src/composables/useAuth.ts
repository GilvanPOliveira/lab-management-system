import { computed, ref } from 'vue'
import type { Session, User } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

const session = ref<Session | null>(null)
const initialized = ref(false)
const loading = ref(false)

let authListenerInitialized = false

export function useAuth() {
  const user = computed<User | null>(() => session.value?.user ?? null)
  const isAuthenticated = computed(() => !!user.value)

  async function initAuth() {
    if (!authListenerInitialized) {
      const { data } = supabase.auth.onAuthStateChange((_event, newSession) => {
        session.value = newSession
        initialized.value = true
      })

      authListenerInitialized = true
      void data
    }

    const { data, error } = await supabase.auth.getSession()

    if (error) {
      throw new Error(error.message)
    }

    session.value = data.session
    initialized.value = true
  }

  async function signIn(email: string, password: string) {
    loading.value = true

    try {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) {
        throw new Error(error.message)
      }
    } finally {
      loading.value = false
    }
  }

  async function signOut() {
    loading.value = true

    try {
      const { error } = await supabase.auth.signOut()

      if (error) {
        throw new Error(error.message)
      }
    } finally {
      loading.value = false
    }
  }

  return {
    session,
    user,
    initialized,
    loading,
    isAuthenticated,
    initAuth,
    signIn,
    signOut,
  }
}

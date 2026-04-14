export type AppBackendMode = 'demo' | 'supabase'

export interface AppUser {
  id: string
  email: string | null
  user_metadata: {
    full_name?: string
  }
}

export interface AppSession {
  user: AppUser
}

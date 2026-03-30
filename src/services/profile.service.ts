import { supabase } from '../lib/supabase'
import type { AppRole, ProfileRow } from '../types/database'

export async function getMyProfile(): Promise<ProfileRow | null> {
  const {
    data: { user },
    error: authError,
  } = await supabase.auth.getUser()

  if (authError) {
    throw new Error(authError.message)
  }

  if (!user) {
    return null
  }

  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .maybeSingle()

  if (error) {
    throw new Error(error.message)
  }

  return data
}

export async function listProfiles(): Promise<ProfileRow[]> {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .order('created_at', { ascending: true })

  if (error) {
    throw new Error(error.message)
  }

  return data ?? []
}

export async function setUserRole(profileId: string, appRole: AppRole): Promise<ProfileRow> {
  const { data, error } = await supabase.rpc('set_user_role', {
    p_profile_id: profileId,
    p_app_role: appRole,
  })

  if (error) {
    throw new Error(error.message)
  }

  return data as ProfileRow
}

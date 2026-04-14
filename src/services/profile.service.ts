import { getBackendMode } from '../lib/backend'
import { getDemoMyProfile, listDemoProfiles, setDemoUserRole } from '../lib/demo'
import { getSupabaseClient } from '../lib/supabase'
import type { AppRole, ProfileRow } from '../types/database'

export async function getMyProfile(): Promise<ProfileRow | null> {
  if (getBackendMode() === 'demo') {
    return getDemoMyProfile()
  }

  const supabase = getSupabaseClient()
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
  if (getBackendMode() === 'demo') {
    return listDemoProfiles()
  }

  const supabase = getSupabaseClient()
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
  if (getBackendMode() === 'demo') {
    return setDemoUserRole(profileId, appRole)
  }

  const supabase = getSupabaseClient()
  const { data, error } = await supabase.rpc('set_user_role', {
    p_profile_id: profileId,
    p_app_role: appRole,
  })

  if (error) {
    throw new Error(error.message)
  }

  return data as ProfileRow
}

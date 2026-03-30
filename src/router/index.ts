import { createRouter, createWebHistory } from 'vue-router'
import DashboardPage from '../pages/DashboardPage.vue'
import ProductsPage from '../pages/ProductsPage.vue'
import CategoriesPage from '../pages/CategoriesPage.vue'
import SuppliersPage from '../pages/SuppliersPage.vue'
import MovementsPage from '../pages/MovementsPage.vue'
import ReportsPage from '../pages/ReportsPage.vue'
import AlertsPage from '../pages/AlertsPage.vue'
import MovementReportsPage from '../pages/MovementReportsPage.vue'
import AdminUsersPage from '../pages/AdminUsersPage.vue'
import ForbiddenPage from '../pages/ForbiddenPage.vue'
import LoginPage from '../pages/LoginPage.vue'
import { supabase } from '../lib/supabase'
import { getMyProfile } from '../services/profile.service'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: LoginPage,
      meta: {
        guestOnly: true,
      },
    },
    {
      path: '/forbidden',
      name: 'forbidden',
      component: ForbiddenPage,
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/',
      name: 'dashboard',
      component: DashboardPage,
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/categories',
      name: 'categories',
      component: CategoriesPage,
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/products',
      name: 'products',
      component: ProductsPage,
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/suppliers',
      name: 'suppliers',
      component: SuppliersPage,
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
    {
      path: '/movements',
      name: 'movements',
      component: MovementsPage,
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/reports',
      name: 'reports',
      component: ReportsPage,
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/reports/movements',
      name: 'movement-reports',
      component: MovementReportsPage,
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/alerts',
      name: 'alerts',
      component: AlertsPage,
      meta: {
        requiresAuth: true,
      },
    },
    {
      path: '/admin/users',
      name: 'admin-users',
      component: AdminUsersPage,
      meta: {
        requiresAuth: true,
        requiresAdmin: true,
      },
    },
  ],
})

router.beforeEach(async (to) => {
  const {
    data: { session },
  } = await supabase.auth.getSession()

  const isAuthenticated = !!session

  if (to.meta.requiresAuth && !isAuthenticated) {
    return '/login'
  }

  if (to.meta.guestOnly && isAuthenticated) {
    return '/'
  }

  if (to.meta.requiresAdmin) {
    const profile = await getMyProfile()

    if (!profile || profile.app_role !== 'admin') {
      return '/forbidden'
    }
  }

  return true
})

export default router

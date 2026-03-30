<template>
  <section class="space-y-6">
    <div class="rounded-3xl border border-zinc-800 bg-zinc-900 p-8">
      <p class="text-sm font-medium uppercase tracking-[0.2em] text-zinc-500">
        Acesso restrito
      </p>

      <h1 class="mt-3 text-3xl font-semibold tracking-tight text-zinc-100">
        Você não tem permissão para acessar esta área.
      </h1>

      <p class="mt-3 max-w-2xl text-sm text-zinc-400">
        Seu perfil atual não possui acesso a esta funcionalidade. Caso precise desta área,
        entre com uma conta administradora ou ajuste o papel do usuário na administração do sistema.
      </p>

      <RouterLink
        to="/"
        class="mt-6 inline-flex rounded-xl bg-white px-4 py-2.5 text-sm font-medium text-zinc-950 transition hover:bg-zinc-200"
      >
        Voltar ao dashboard
      </RouterLink>
    </div>
  </section>
</template>

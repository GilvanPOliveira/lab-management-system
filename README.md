# Lab Management System

Sistema de gestao de estoque desenvolvido como laboratorio tecnico, com foco em regras de negocio, modelagem de dados e organizacao de codigo.

## Sobre

Aplicacao web para controle operacional de estoque, permitindo cadastro de entidades, movimentacoes e acompanhamento do estado dos produtos.

O projeto foi desenvolvido com foco em consistencia de dados, seguranca e clareza estrutural.

## Objetivo

Consolidar conhecimentos em desenvolvimento full stack, incluindo:

- modelagem de dados
- regras de negocio
- CRUD completo
- controle de acesso
- integracao com banco de dados
- organizacao de projeto

## Funcionalidades

### Cadastros

- categorias
- fornecedores
- produtos

### Operacao de estoque

- entrada de produtos
- saida de produtos
- ajuste de estoque com justificativa
- historico de movimentacoes

### Controle de acesso

- autenticacao por e-mail e senha
- perfil `admin`
- perfil `operator`

### Relatorios

- estoque consolidado
- historico de movimentacoes
- filtros por categoria, fornecedor e periodo
- exportacao CSV

### Alertas

- produtos com estoque baixo
- produtos inativos

## Modos de execucao

O projeto suporta dois backends:

- `demo`: usa dados locais no navegador via `localStorage`
- `supabase`: usa autenticacao e persistencia reais no Supabase

Voce pode controlar isso pelo `.env`:

```env
VITE_APP_MODE=both
VITE_DEFAULT_BACKEND=demo
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
```

### Variaveis

- `VITE_APP_MODE=demo`: habilita apenas o modo demo
- `VITE_APP_MODE=supabase`: habilita apenas o modo Supabase
- `VITE_APP_MODE=both`: permite ao usuario escolher na tela de login
- `VITE_DEFAULT_BACKEND=demo|supabase`: define qual modo abre por padrao

## Regras de negocio

- nao permite estoque negativo
- nao permite movimentar produto inativo
- quantidade deve ser maior que zero
- ajuste exige justificativa
- movimentacoes sao registradas no banco
- historico nao pode ser editado

## Estrutura do repositorio

```text
lab-management-system/
|-- src/
|   |-- components/
|   |-- composables/
|   |-- lib/
|   |-- pages/
|   |-- router/
|   |-- services/
|   `-- types/
`-- supabase/
    `-- migrations/
```

## Como executar

```bash
git clone <url-do-repositorio>
cd lab-management-system
npm install
```

Crie o `.env` a partir do `.env.example`.

### Rodar em demo

```env
VITE_APP_MODE=demo
VITE_DEFAULT_BACKEND=demo
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
```

### Rodar com escolha entre demo e Supabase

```env
VITE_APP_MODE=both
VITE_DEFAULT_BACKEND=demo
VITE_SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co
VITE_SUPABASE_ANON_KEY=SUA_ANON_KEY
```

### Rodar apenas com Supabase

```env
VITE_APP_MODE=supabase
VITE_DEFAULT_BACKEND=supabase
VITE_SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co
VITE_SUPABASE_ANON_KEY=SUA_ANON_KEY
```

Se for usar Supabase, configure tambem o projeto:

```bash
supabase login
supabase link --project-ref SEU_PROJECT_REF
supabase db push
```

Execute:

```bash
npm run dev
```

## Como testar

### Demo

Use uma das credenciais abaixo:

- `admin.demo@lab.local` / `demo123`
- `operador.demo@lab.local` / `demo123`

### Supabase

1. criar conta
2. definir usuario como `admin`
3. cadastrar entidades
4. realizar movimentacoes
5. acessar relatorios

## Stack

[![My Skills](https://skillicons.dev/icons?i=vue,ts,vite,tailwind,postgres\&perline=5)](https://skillicons.dev)

- Vue 3
- TypeScript
- Vite
- Tailwind CSS
- Supabase
- PostgreSQL

## Contato

- Portfolio: https://gilvanpoliveira.github.io
- Email: [gilvanoliveira06@gmail.com](mailto:gilvanoliveira06@gmail.com)

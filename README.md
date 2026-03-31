# Lab Management System

Sistema de gestão de estoque desenvolvido como laboratório técnico, com foco em regras de negócio, modelagem de dados e organização de código.

##

## Sobre

Aplicação web para controle operacional de estoque, permitindo cadastro de entidades, movimentações e acompanhamento do estado dos produtos.

O projeto foi desenvolvido com foco em consistência de dados, segurança e clareza estrutural.

##

## Objetivo

Consolidar conhecimentos em desenvolvimento full stack, incluindo:

* modelagem de dados
* regras de negócio
* CRUD completo
* controle de acesso
* integração com banco de dados
* organização de projeto

##

## Funcionalidades

### Cadastros

* categorias
* fornecedores
* produtos

###

### Operação de estoque

* entrada de produtos
* saída de produtos
* ajuste de estoque com justificativa
* histórico de movimentações

###

### Controle de acesso

* autenticação por e-mail e senha
* perfil `admin`
* perfil `operator`

###

### Relatórios

* estoque consolidado
* histórico de movimentações
* filtros por categoria, fornecedor e período
* exportação CSV

###

### Alertas

* produtos com estoque baixo
* produtos inativos

##

## Regras de negócio

* não permite estoque negativo
* não permite movimentar produto inativo
* quantidade deve ser maior que zero
* ajuste exige justificativa
* movimentações são registradas no banco
* histórico não pode ser editado

##

## Estrutura do Repositório

```text
lab-management-system/
├─ src/
│  ├─ components/
│  ├─ composables/
│  ├─ lib/
│  ├─ pages/
│  ├─ router/
│  ├─ services/
│  └─ types/
└─ supabase/
   └─ migrations/
```

##

## Como executar

```bash
git clone <url-do-repositorio>
cd lab-management-system
npm install
```

Crie o `.env`:

```env
VITE_SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co
VITE_SUPABASE_ANON_KEY=SUA_ANON_KEY
```

Configure o Supabase:

```bash
supabase login
supabase link --project-ref SEU_PROJECT_REF
supabase db push
```

Execute:

```bash
npm run dev
```

##

## Como testar

1. criar conta
2. definir usuário como `admin`
3. cadastrar entidades
4. realizar movimentações
5. acessar relatórios

##

## Stack

[![My Skills](https://skillicons.dev/icons?i=vue,ts,vite,tailwind,postgres\&perline=5)](https://skillicons.dev)

* Vue 3
* TypeScript
* Vite
* Tailwind CSS
* Supabase
* PostgreSQL

##

## Contato

* Portfólio: https://gilvanpoliveira.github.io
* Email: [gilvanoliveira06@gmail.com](mailto:gilvanoliveira06@gmail.com)

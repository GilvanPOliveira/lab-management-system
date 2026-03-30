# Lab Management System

Sistema de gestão de estoque operacional desenvolvido como laboratório técnico, com foco em regras de negócio, segurança e organização de código.

##

## Sobre o projeto

Aplicação web para controle de estoque com:

- cadastro de produtos, categorias e fornecedores
- registro de movimentações (entrada, saída e ajuste)
- controle de acesso por perfil (admin e operator)
- relatórios operacionais com filtros
- alertas de estoque baixo
- exportação de dados em CSV

##

## Stack

- Vue 3 + TypeScript
- Vite
- Tailwind CSS v3
- Supabase (Postgres + Auth + RLS)
- Supabase CLI (migrations)

##

## Funcionalidades

### Estrutura
- CRUD de categorias
- CRUD de fornecedores
- CRUD de produtos

### Operação
- entradas de estoque
- saídas de estoque
- ajustes com justificativa
- histórico imutável de movimentações

### Controle de acesso
- autenticação por e-mail/senha
- perfis:
  - `admin`: acesso total
  - `operator`: acesso operacional

### Relatórios
- estoque consolidado
- histórico de movimentações
- filtros por categoria, fornecedor e período
- exportação CSV

### Alertas
- produtos com estoque baixo
- produtos inativos

##

## Regras de negócio

- não permite estoque negativo  
- não permite movimentar produto inativo  
- quantidade deve ser maior que zero  
- ajuste exige justificativa  
- movimentações são registradas via função segura no banco  
- histórico não pode ser editado  

##

## Como rodar o projeto

### 1. Clone o repositório

```bash
git clone <url-do-repositorio>
cd lab-management-system
```

### 2. Instale as dependências

```bash
npm install
```

### 3. Configure o .env

Crie um arquivo .env na raiz:

```bash 
VITE_SUPABASE_URL=https://SEU_PROJECT_REF.supabase.co
VITE_SUPABASE_ANON_KEY=SUA_ANON_KEY
```

### 4. Configure o Supabase (remoto)

```bash
npx supabase login
npx supabase link --project-ref SEU_PROJECT_REF
npx supabase db push
```

### 5. Rode o projeto

```bash
npm run dev
```

## 

## Como testar

### Fluxo recomendado
1. Crie uma conta
2. Defina manualmente o usuário como `admin` no banco (tabela `profiles`)
3. Cadastre:
    - categorias
    - fornecedores
    - produtos
4. Faça movimentações:
    - entrada
    - saída
    - ajuste
5. Acesse:
    - relatórios
    - alertas

##

## Estrutura do projeto

```bash
src/
  components/
  composables/
  lib/
  pages/
  router/
  services/
  types/

supabase/
  migrations/
```

## 

## Banco de dados

### Principais entidades:
- profiles
- categories
- suppliers
- products
- stock_movements

##

## Diferenciais
- regras críticas implementadas no banco (não só no frontend)
- uso de RLS para segurança real
- migrations versionadas no repositório
- separação clara de responsabilidades (services, lib, composables)
- foco em código limpo e manutenção

##

## Objetivo

### Projeto desenvolvido como laboratório técnico para demonstrar:

- domínio de CRUD real
- modelagem de dados
- regras de negócio
- integração com backend remoto
- organização de código em escala pequena/média

##


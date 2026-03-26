# Cart API

API REST para gerenciamento de carrinho de compras de e-commerce, desenvolvida em Ruby on Rails.

## Funcionalidades

### 1. Registrar um produto no carrinho

Se não existir um carrinho para a sessão, o carrinho é criado automaticamente e seu ID é salvo na sessão. O produto é adicionado e o payload atualizado do carrinho é retornado.

ROTA: `POST /cart`

Payload:
```json
{
  "product_id": 345,
  "quantity": 2
}
```

Response:
```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    },
    {
      "id": 646,
      "name": "Nome do produto 2",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 7.96
}
```

### 2. Listar itens do carrinho atual

ROTA: `GET /cart`

Response:
```json
{
  "id": 789,
  "products": [
    {
      "id": 645,
      "name": "Nome do produto",
      "quantity": 2,
      "unit_price": 1.99,
      "total_price": 3.98
    }
  ],
  "total_price": 3.98
}
```

### 3. Adicionar ou incrementar produto no carrinho

Se o produto já existir no carrinho, a quantidade é incrementada. Caso contrário, o produto é adicionado.

ROTA: `POST /cart/add_item`

Payload:
```json
{
  "product_id": 1230,
  "quantity": 1
}
```

Response:
```json
{
  "id": 1,
  "products": [
    {
      "id": 1230,
      "name": "Nome do produto X",
      "quantity": 2,
      "unit_price": 7.00,
      "total_price": 14.00
    },
    {
      "id": 1020,
      "name": "Nome do produto Y",
      "quantity": 1,
      "unit_price": 9.90,
      "total_price": 9.90
    }
  ],
  "total_price": 23.90
}
```

### 4. Remover um produto do carrinho

Remove um produto específico do carrinho. Retorna erro se o produto não estiver no carrinho. Após a remoção, retorna o payload atualizado.

ROTA: `DELETE /cart/:product_id`

### 5. Carrinhos abandonados

Um carrinho é considerado abandonado quando está sem interação (adição ou remoção de produtos) há mais de 3 horas. O `MarkCartAsAbandonedJob` gerencia esse ciclo de vida automaticamente:

- Carrinhos inativos há mais de **3 horas** são marcados como abandonados.
- Carrinhos abandonados há mais de **7 dias** são removidos.

O job é agendado para rodar a cada hora via Sidekiq.

## Informações técnicas

### Dependências

- ruby 3.3.1
- rails 7.1.3.2
- postgres 16
- redis 7.0.15

## Como executar o projeto

### Sem Docker

Dado que todas as ferramentas estão instaladas e configuradas:

```bash
bundle install
```

```bash
bundle exec sidekiq
```

```bash
bundle exec rails server
```

### Com Docker

Pré-requisitos: Docker e Docker Compose instalados.

Subir os serviços (API, banco de dados e Redis):
```bash
make up
```

Acessar o container e iniciar o servidor:
```bash
make bash
rails server -b 0.0.0.0
```

> O `-b 0.0.0.0` é necessário para que o servidor aceite requisições vindas de fora do container.

Pausar os serviços (mantém dados e imagens):
```bash
make stop
```

Remover tudo do projeto (containers, volumes e imagens):
```bash
make clean
```

#### Rodando os testes com Docker

O docker-compose possui um serviço `test` isolado com `RAILS_ENV=test` e banco dedicado:

```bash
make test
```

Equivalente a:
```bash
docker-compose --profile test run --rm test
```

O serviço sobe, roda a suíte completa do RSpec e encerra automaticamente.

#### Rodando o Sidekiq com Docker

```bash
make sidekiq
```

Equivalente a:
```bash
docker-compose exec web bundle exec sidekiq
```

> O Sidekiq deve estar rodando para que o `MarkCartAsAbandonedJob` seja agendado e executado.

### Comandos disponíveis no Makefile

| Comando | Descrição |
|---|---|
| `make up` | Sobe os containers em background |
| `make stop` | Pausa os containers (dados preservados) |
| `make clean` | Remove tudo do projeto (containers, volumes e imagens) |
| `make bash` | Abre o terminal dentro do container web |
| `make test` | Roda a suíte de testes via container isolado |
| `make sidekiq` | Inicia o Sidekiq dentro do container web |

### Subindo o servidor automaticamente

Por padrão, o container sobe com `sleep infinity` e aguarda o servidor ser iniciado manualmente. Para subir automaticamente com `make up`, edite o `Dockerfile`:

```dockerfile
# CMD ["rails", "server", "-b", "0.0.0.0"]  ← descomentar
CMD ["sleep", "infinity"]                   ← comentar
```

O código do host é sincronizado via volume — alterações nos arquivos são refletidas sem reconstruir a imagem.

## Rotas disponíveis

### Produtos

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/products` | Lista todos os produtos |
| `GET` | `/products/:id` | Exibe um produto |
| `POST` | `/products` | Cria um produto |
| `PATCH/PUT` | `/products/:id` | Atualiza um produto |
| `DELETE` | `/products/:id` | Remove um produto |

**POST /products** e **PATCH/PUT /products/:id**
```json
{
  "product": {
    "name": "Nome do produto",
    "price": 9.99
  }
}
```

### Carrinho

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/cart` | Exibe o carrinho atual |
| `POST` | `/cart` | Cria o carrinho e adiciona um produto |
| `POST` | `/cart/add_item` | Adiciona ou incrementa um produto no carrinho |
| `DELETE` | `/cart/:product_id` | Remove um produto do carrinho |

**POST /cart** e **POST /cart/add_item**
```json
{
  "product_id": 1,
  "quantity": 2
}
```

### Utilitários

| Método | Rota | Descrição |
|---|---|---|
| `GET` | `/up` | Health check da aplicação |
| `GET` | `/sidekiq` | Dashboard do Sidekiq (http://localhost:3000/sidekiq) |

# Healthy Cook API

API REST do Healthy Cook, feita com [Dart Frog](https://dartfrog.vgv.dev) e MySQL.
Substitui o Firebase Auth, o Firestore, o Firebase Storage e o Algolia.

## Como rodar

```bash
# na raiz do repositório: sobe o MySQL 8.4 na porta 3307 e cria as tabelas
docker compose up -d

cd api
cp -n .env.example .env       # só cria se não existir; troque o JWT_SECRET
dart pub get
dart pub global activate dart_frog_cli
dart_frog dev                 # http://localhost:8080
```

O schema fica em [`db/migrations/001_init.sql`](db/migrations/001_init.sql). O MySQL só
o executa na **primeira** inicialização do volume. Para recriar o banco do zero, rode
`docker compose down -v && docker compose up -d`.

No emulador Android, a API fica em `http://10.0.2.2:8080`.

## Autenticação

- `accessToken`: JWT HS256 válido por 15 minutos. Vai no header
  `Authorization: Bearer <token>`.
- `refreshToken`: token opaco válido por 30 dias e **rotacionado** a cada uso. Se um token
  já usado aparecer de novo, todas as sessões do usuário são encerradas.
- Senhas usam bcrypt (custo 12). No banco ficam só os hashes, tanto das senhas quanto
  dos refresh tokens e dos tokens de e-mail.
- Os e-mails (confirmação e redefinição de senha) são **impressos no console** pelo
  `ConsoleMailer`. Para produção, implemente `Mailer` com SMTP.

## Endpoints

Todos os endpoints, exceto os de `/auth` (fora `resend-verification`) e o health check,
exigem autenticação.

| Método | Rota | Corpo / parâmetros |
|---|---|---|
| GET | `/` | health check (consulta o banco) |
| POST | `/auth/register` | `{name, email, password}` → `201 {user, accessToken, refreshToken, ...}` |
| POST | `/auth/login` | `{email, password}` |
| POST | `/auth/refresh` | `{refreshToken}` → novo par de tokens |
| POST | `/auth/logout` | `{refreshToken}` → `204` |
| GET | `/auth/verify-email?token=` | link do e-mail (página HTML) |
| POST | `/auth/resend-verification` | autenticado → `204` |
| POST | `/auth/forgot-password` | `{email}` → sempre `204` |
| POST | `/auth/reset-password` | `{token, password}` → `204` |
| GET / PATCH | `/users/me` | PATCH: `{name}` |
| PUT | `/users/me/photo` | multipart, campo `image` (JPEG/PNG/WebP, até 5 MB) |
| PUT | `/users/me/password` | `{currentPassword, newPassword}` → `204` |
| GET | `/users/me/recipes` | `?limit=&offset=` |
| GET | `/recipes` | `?q=` (busca, ordenada por curtidas) ou `?since=<ISO 8601>`; `?limit=&offset=` |
| POST | `/recipes` | `{title, description, ingredients, howToPrepare, timeToPrepareMin}` |
| GET / PATCH / DELETE | `/recipes/:id` | PATCH aceita só os campos enviados (apenas o autor) |
| PUT | `/recipes/:id/image` | multipart, campo `image` (apenas o autor) |
| PUT / DELETE | `/recipes/:id/like` | → `{likesCount, likedByMe}` |

As imagens enviadas são servidas em `/uploads/...`. A API devolve essas URLs **relativas**,
e o app as completa com o endereço que estiver usando (emulador, aparelho ou produção).

Para o app rodando no navegador, libere as origens em `CORS_ALLOWED_ORIGINS`.

### Formato de erro

```json
{ "error": { "code": "bad_request", "message": "Dados inválidos",
             "details": { "email": "E-mail inválido" } } }
```

Códigos que o app pode tratar: `email_in_use`, `invalid_credentials`,
`invalid_refresh_token`, `unauthorized`, `forbidden`, `not_found`, `too_large`.

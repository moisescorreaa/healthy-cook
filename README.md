# healthy_cook

Aplicativo Flutter de receitas que contribui para hábitos alimentares saudáveis.

O projeto nasceu na faculdade para demonstrar a integração entre o Algolia e o Firebase
Firestore. Na refatoração, o Firebase e o Algolia foram substituídos por uma API própria
com banco de dados relacional (MySQL).

## Estrutura

| Pasta | Conteúdo |
|---|---|
| [`app/`](app/) | App Flutter |
| [`api/`](api/) | API REST em Dart Frog: autenticação JWT, receitas, curtidas, busca e upload de imagens ([documentação](api/README.md)) |
| [`docker-compose.yml`](docker-compose.yml) | MySQL 8.4 (porta 3307) |

```
App Flutter ──HTTP/JSON──▶ API Dart Frog ──▶ MySQL
                              └──▶ imagens em disco (/uploads)
```

## Como rodar

```bash
# 1. Banco de dados
docker compose up -d

# 2. API (veja api/README.md para a configuração do .env)
cd api && cp .env.example .env && dart pub get && dart_frog dev

# 3. App
cd app && flutter pub get && flutter run
```

Por padrão, o app procura a API em `http://10.0.2.2:8080` no emulador Android e em
`http://localhost:8080` nas outras plataformas. Para outro endereço (por exemplo, um
celular físico na mesma rede):

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.0.10:8080
```

Para rodar no navegador (`flutter run -d chrome`), mantenha `CORS_ALLOWED_ORIGINS` no `.env`
da API.

Os e-mails de confirmação e de redefinição de senha são impressos no console da API
durante o desenvolvimento.

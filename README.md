# Keycloak для Kanji Flow

Кастомный образ Keycloak на базе playaru/keycloak-russian с поддержкой русской локализации и интеграцией с Telegram.

## Быстрый старт

### Локальная разработка

```bash
# Создайте .env файл из примера
cp .env.example .env

# Запустите сервисы
docker-compose up -d

# Проверьте логи
docker-compose logs -f keycloak
```

Keycloak будет доступен по адресу: http://localhost:8080

Учетные данные по умолчанию:
- Username: `admin`
- Password: `admin`

### Production deployment

Для production используйте переменные окружения из `.env`:
- Установите `KEYCLOAK_HOSTNAME` на ваш домен
- Измените `KEYCLOAK_ADMIN_PASSWORD` на безопасный пароль
- Настройте reverse proxy (nginx, traefik) для HTTPS

## Структура проекта

```
keycloak-kanji/
├── .env                    # Переменные окружения (не коммитить!)
├── .env.example            # Шаблон переменных
├── docker-compose.yml      # Локальная конфигурация
├── Dockerfile              # Multi-stage build образа
├── realm-export.json       # Автоимпорт realm KanjiFlow
├── providers/              # Кастомные JAR провайдеры
│   └── keycloak-telegram-identity-provider-1.0.3.jar
└── themes/                 # Кастомные темы (опционально)
```

## Realm Configuration

Realm `KanjiFlow` автоматически создается при первом запуске из `realm-export.json`.

### Clients

1. **nuxt-web** (Public OIDC client)
   - Redirect URIs: `http://localhost:3001/*`, `https://kanji-flow.online/*`
   - PKCE включен
   - Используется фронтенд приложением

2. **nest-api** (Confidential client)
   - Service account включен
   - Используется backend API для валидации токенов

### Roles

- `user` - роль по умолчанию для новых пользователей
- `admin` - административная роль

## Кастомизация

### Добавление темы

1. Создайте папку `themes/kanji-flow/`
2. Следуйте структуре из `.kiro/steering/customization.md`
3. Пересоберите образ: `docker-compose build --no-cache`

### Добавление провайдера

1. Поместите JAR файл в `providers/`
2. Пересоберите образ
3. Настройте провайдер через Admin Console

## CI/CD

GitHub Actions автоматически собирает и публикует образ в `ghcr.io` при push в main/develop или при создании тега.

```bash
# Образ будет доступен как:
ghcr.io/<your-org>/kanji-flow-keycloak:latest
ghcr.io/<your-org>/kanji-flow-keycloak:develop
ghcr.io/<your-org>/kanji-flow-keycloak:v1.0.0
```

## Healthcheck

Образ включает healthcheck на эндпоинт `/health/ready`:
- Интервал: 30 секунд
- Таймаут: 3 секунды
- Start period: 60 секунд (время на инициализацию)
- Retries: 3

## Переменные окружения

### Database (обязательные)
- `KC_DB=postgres`
- `KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak`
- `KC_DB_USERNAME=keycloak`
- `KC_DB_PASSWORD` - из .env

### Admin (обязательные)
- `KEYCLOAK_ADMIN` - admin username (из .env)
- `KEYCLOAK_ADMIN_PASSWORD` - admin password (из .env)

### Production настройки
- `KC_HOSTNAME` - доменное имя для production
- `KC_HOSTNAME_URL` - полный HTTPS URL
- `KC_PROXY=edge` - для работы за reverse proxy
- `KC_PROXY_HEADERS=xforwarded` - использование X-Forwarded-* заголовков

### Development настройки
- `KC_HTTP_ENABLED=true` - разрешить HTTP (только для разработки!)
- `KC_HOSTNAME_PORT=8080` - порт для локального доступа

## Troubleshooting

### Keycloak не стартует

```bash
# Проверьте логи
docker-compose logs keycloak

# Проверьте что PostgreSQL запустился
docker-compose ps postgres

# Пересоздайте с чистой БД
docker-compose down -v
docker-compose up -d
```

### Realm не импортируется

Убедитесь что `realm-export.json` корректный JSON и перезапустите:

```bash
docker-compose restart keycloak
```

### Провайдер не загружается

```bash
# Проверьте что JAR скопировался
docker-compose exec keycloak ls -la /opt/keycloak/providers/

# Проверьте логи на ошибки загрузки
docker-compose logs keycloak | grep -i error
```

## Ресурсы

- [Keycloak Documentation](https://www.keycloak.org/documentation)
- [Keycloak in Docker](https://www.keycloak.org/server/containers)
- [Telegram Provider GitHub](https://github.com/wadahiro/keycloak-telegram-identity-provider)

## License

См. LICENSE файл в корне проекта.

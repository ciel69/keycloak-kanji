# План реализации: Кастомная страница авторизации (custom-auth-page)

## Обзор

Реализация переносит аутентификацию экосистемы Kanji Flow в Keycloak на хосте
`auth.kanji-flow.online` с кастомной брендированной темой `kanji-flow`. Работа
ведётся инкрементально: сначала каркас и стили темы, затем FreeMarker-шаблоны и
локализация, далее декларативная конфигурация (`realm-export.json`, `Dockerfile`,
`.env`, hostname/прокси), и в завершение — контракты интеграции для Nuxt
(`nuxt-web`) и NestJS (`nest-api`) с property-based тестами.

Границы репозиториев:

- **Этот репозиторий (keycloak-kanji):** тема (`themes/kanji-flow/`),
  `realm-export.json`, `Dockerfile`, `.env`/`.env.example`, конфигурация
  hostname/прокси, а также тесты JS-логики темы и integration/smoke/snapshot.
- **Отдельные репозитории:** фронтенд Nuxt (`nuxt-web`) и бэкенд NestJS
  (`nest-api`). Соответствующие задачи оформлены как контракты интеграции —
  конкретные шаги реализации в этих репозиториях, включая property-based тесты.

Property-based тесты используют `fast-check` (TypeScript/JavaScript), минимум
100 итераций, каждый помечается комментарием
`Feature: custom-auth-page, Property {N}: {текст свойства}`.

## Tasks

- [ ] 1. Каркас темы `kanji-flow`
  - [ ] 1.1 Создать структуру каталога темы и `theme.properties`
    - Создать `themes/kanji-flow/login/` с подкаталогами `messages/`,
      `resources/css/`, `resources/js/`, `resources/img/`, `resources/img/icons/`
    - Создать `theme.properties`: `parent=keycloak`, `import=common/keycloak`,
      `locales=ru,en`, `styles=css/entry.css css/login.css css/kanji-flow.css`,
      `scripts=js/theme-mode.js js/password-toggle.js js/password-strength.js`,
      `kcHtmlClass` для тёмной темы
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 1.2 Реализовать общий каркас `template.ftl`
    - Переопределить `template.ftl` с брендированной карточкой
      (`max-w-md rounded-card shadow-card`), логотипом `new-circle-logo.svg`,
      упрощёнными header/footer со ссылками на `kanji-flow.online`
    - Подключить блок локали и вывод сообщений (`messagesPerField`) из базовой темы
    - Разместить логотипы (`new-circle-logo.svg`, `new-logo.svg`) и иконки
      (google, telegram) в `resources/img/`
    - _Requirements: 2.2, 2.4, 10.7_

- [ ] 2. Стратегия стилизации Tailwind CSS
  - [ ] 2.1 Подготовить скомпилированный Tailwind CSS темы
    - Настроить минимальный Tailwind-конфиг с палитрой `plum`, `darkMode: 'class'`
      и токенами (`rounded-card`, `shadow-card`), `content` по `.ftl`-шаблонам темы
    - Скомпилировать результат в `resources/css/entry.css`; при необходимости
      перенести специфичные стили страницы входа из `front_tmp/_nuxt/login.*.css`
      в `resources/css/login.css` под стабильными именами
    - _Requirements: 2.7, 2.8_

  - [ ] 2.2 Портировать стили провайдер-кнопок в `kanji-flow.css`
    - Перенести стили `.auth-provider-btn` и связанные из инлайновых `<style>`
      блоков эталона в `resources/css/kanji-flow.css`, удалив Vue-скоуп-атрибуты
      (`[data-v-*]`)
    - _Requirements: 2.7, 2.8_

  - [ ] 2.3 Реализовать `theme-mode.js` (инициализация тёмной темы)
    - Воспроизвести логику эталона: чтение `localStorage` (`vueuse-color-scheme`)
      и `prefers-color-scheme`, установка класса `dark` на `<html>`
    - _Requirements: 2.8, 10.7_

  - [ ] 2.4 Реализовать `password-toggle.js` (показать/скрыть пароль)
    - Переключение `type` поля пароля и состояния иконки-глаза
    - _Requirements: 2.7_

  - [ ] 2.5 Реализовать `password-strength.js` (индикатор сложности)
    - Функция оценки пароля, возвращающая ровно один из ≥3 дискретных уровней;
      пароль, соответствующий политике realm, получает уровень не ниже
      несоответствующего
    - Экспортировать чистую функцию оценки для тестируемости
    - _Requirements: 10.8_

  - [ ]* 2.6 Property-тест функции оценки сложности пароля
    - **Property 11: Дискретные уровни индикатора сложности пароля**
    - **Validates: Requirements 10.8**
    - `fast-check`, ≥100 итераций

- [ ] 3. FreeMarker-шаблоны аутентификации
  - [ ] 3.1 Реализовать `login.ftl` (форма входа)
    - Поле `username` (вход по email/username), поле пароля с кнопкой «показать»,
      кнопка «Войти» (`bg-plum-600`), разделитель «Или», кнопки социальных
      провайдеров (итерация по `social.providers`), условная ссылка
      «Нет аккаунта? Зарегистрироваться» при `realm.registrationAllowed`
    - Извлечь логику видимости ссылки регистрации в тестируемую JS-функцию
    - _Requirements: 2.4, 3.3, 4.1, 10.1, 10.2, 10.7_

  - [ ] 3.2 Реализовать `register.ftl` (форма регистрации)
    - Обязательные поля realm (минимум email, пароль, подтверждение пароля),
      индикатор сложности (`password-strength.js`), ссылка «Уже есть аккаунт? Войти»
      (`${url.loginUrl}`), повторный показ значений непарольных полей при ошибке
      через `messagesPerField`
    - Извлечь логику сохранения значений формы в тестируемую JS-функцию
    - _Requirements: 10.3, 10.4, 10.5, 10.6, 10.7, 10.8_

  - [ ] 3.3 Реализовать шаблоны сброса пароля
    - `login-reset-password.ftl` (запрос сброса) и `login-update-password.ftl`
      (установка нового пароля) в стиле темы
    - _Requirements: 2.4, 3.5, 3.6_

  - [ ] 3.4 Реализовать `login-verify-email.ftl` и `login-otp.ftl`
    - Страницы подтверждения email и ввода OTP в стиле темы
    - _Requirements: 2.4, 10.5_

- [ ] 4. Локализация темы
  - [ ] 4.1 Создать файлы сообщений `messages_ru.properties` и `messages_en.properties`
    - Ключи для форм входа/регистрации, ссылок перехода
      («Нет аккаунта? Зарегистрироваться», «Уже есть аккаунт? Войти»), индикатора
      сложности, сообщений об ошибках
    - _Requirements: 2.3, 2.5, 10.1, 10.4_

- [ ] 5. Декларативная конфигурация `realm-export.json`
  - [ ] 5.1 Настроить realm-уровневые параметры
    - Добавить `loginTheme: "kanji-flow"` и `verifyEmail: true`; подтвердить
      `registrationAllowed`, `resetPasswordAllowed`, `loginWithEmailAllowed`,
      brute force (`failureFactor=5`, `maxFailureWaitSeconds=900`,
      `permanentLockout=false`), `accessTokenLifespan=300`,
      `actionTokenGeneratedByUserLifespan=300`, `defaultLocale=ru`,
      `supportedLocales=[ru,en]`
    - _Requirements: 2.4, 2.6, 3.1, 3.4, 3.5, 3.6, 9.1, 10.5_

  - [ ] 5.2 Настроить клиент `nuxt-web` (PKCE, redirect URI, logout)
    - Подтвердить `publicClient`, Authorization Code Flow,
      `pkce.code.challenge.method=S256`, `frontchannelLogout=true`; добавить
      `https://kanji-flow.online/auth/callback` и dev-эквиваленты в `redirectUris`,
      сузить для production
    - Подтвердить protocol mapper ролей (`realm_access.roles` в токене) и
      конфиденциальность `nest-api` (`publicClient=false`, `serviceAccountsEnabled=true`)
    - _Requirements: 5.1, 5.5, 5.6, 5.7, 6.6, 6.8, 9.1_

  - [ ] 5.3 Добавить Telegram identity provider
    - Секция `identityProviders` с alias Telegram, параметрами (`client_id`/secret
      через переменные окружения), маппингами атрибутов
    - _Requirements: 4.1, 4.5, 9.1_

- [ ] 6. Образ и переменные окружения
  - [ ] 6.1 Обновить `Dockerfile`
    - На этапе `builder` копировать `themes/` и `providers/` в
      `/opt/keycloak/themes/` и `/opt/keycloak/providers/`, `realm-export.json` в
      `/opt/keycloak/data/import/realm.json`, выполнить `kc.sh build --db=postgres`;
      перенести сборку на этап `runtime`
    - _Requirements: 2.1, 4.5, 9.2_

  - [ ] 6.2 Обновить `.env` и `.env.example`
    - Переориентировать `KEYCLOAK_HOSTNAME` на `auth.kanji-flow.online`; добавить
      плейсхолдеры секретов Telegram-бота (`TELEGRAM_BOT_ID`/`TELEGRAM_BOT_TOKEN`
      или client secret IdP) без реальных значений; подтвердить SMTP-плейсхолдеры
    - _Requirements: 9.3_

  - [ ] 6.3 Настроить hostname/прокси для `auth.kanji-flow.online`
    - Production-переменные: `KC_HOSTNAME=https://auth.kanji-flow.online`,
      `KC_HOSTNAME_STRICT=true`, `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=false`,
      `KC_PROXY_HEADERS=xforwarded`, `KC_HTTP_ENABLED=false`, `KC_HOSTNAME_ADMIN`;
      сохранить мягкий режим для локального `docker-compose`
    - Обновить `docker-compose.yml`/env-шаблоны соответствующим образом
    - _Requirements: 1.1, 1.3, 1.4, 1.5, 1.6, 1.7_

- [ ] 7. Checkpoint — сборка образа и импорт realm
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 8. Контракт интеграции NestJS (`nest-api`, отдельный репозиторий)
  - [ ] 8.1 Реализовать guard валидации токенов
    - JWKS-верификация подписи, проверка `iss` (issuer realm `KanjiFlow`) и `exp`
      по внутреннему адресу Keycloak (≤5 c); `401` при недействительном/просроченном
      токене, неверном/отсутствующем заголовке `Authorization`, недоступности JWKS
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 8.2, 8.5, 8.6_

  - [ ] 8.2 Реализовать контроль доступа по ролям
    - Проверка `realm_access.roles`; `403` при отсутствии требуемой роли,
      пропуск при наличии
    - _Requirements: 6.6, 6.7_

  - [ ] 8.3 Удалить локальную логику логина/пароля
    - Убрать приём/проверку пары логин-пароль; удалить/заменить эндпоинты
      локальной аутентификации (возврат «эндпоинт недоступен», 404/410);
      сохранить прочие функции без изменений; авторизация только по валидному токену
    - _Requirements: 8.1, 8.3, 8.4, 8.7_

  - [ ]* 8.4 Property-тест решения guard по токену
    - **Property 2: Корректность решения guard по токену**
    - **Validates: Requirements 6.2, 6.3, 8.2**
    - `fast-check`, ≥100 итераций, мок-JWKS/локальные ключевые пары

  - [ ]* 8.5 Property-тест отклонения некорректного заголовка авторизации
    - **Property 3: Отклонение некорректного заголовка авторизации**
    - **Validates: Requirements 6.4, 8.5**
    - `fast-check`, ≥100 итераций

  - [ ]* 8.6 Property-тест контроля доступа по ролям
    - **Property 4: Контроль доступа по ролям**
    - **Validates: Requirements 6.7**
    - `fast-check`, ≥100 итераций

  - [ ]* 8.7 Property-тест инварианта неизменности состояния при отказе
    - **Property 5: Инвариант неизменности состояния при отказе**
    - **Validates: Requirements 8.5, 8.6**
    - `fast-check`, ≥100 итераций, in-memory состояние

- [ ] 9. Контракт интеграции Nuxt (`nuxt-web`, отдельный репозиторий)
  - [ ] 9.1 Реализовать генерацию PKCE и запуск OIDC-потока
    - Генерация `code_verifier` + `code_challenge` (`BASE64URL(SHA256(...))`,
      метод `S256`), формирование запроса авторизации на `auth.kanji-flow.online`
    - Экспортировать чистые функции генерации/проверки PKCE для тестируемости
    - _Requirements: 5.1, 5.2, 7.1_

  - [ ] 9.2 Реализовать middleware редиректа и обработку callback
    - Редирект неаутентифицированного пользователя на `auth.kanji-flow.online`
      без собственной формы; формирование сессии из выданных токенов и
      восстановление исходного маршрута; при недействительном/просроченном токене —
      повторный редирект без хранения учётных данных
    - _Requirements: 7.2, 7.5, 7.6_

  - [ ] 9.3 Удалить встроенную форму и логику авторизации
    - Убрать встроенную форму входа и клиентскую проверку учётных данных;
      прекратить отправку логина/пароля в NestJS; оставить точкой входа только
      редирект на Keycloak
    - _Requirements: 7.1, 7.3, 7.4_

  - [ ]* 9.4 Property-тест консистентности генерации PKCE
    - **Property 1: Консистентность генерации PKCE (S256)**
    - **Validates: Requirements 5.4**
    - `fast-check`, ≥100 итераций

  - [ ]* 9.5 Property-тест редиректа при отсутствии сессии
    - **Property 6: Редирект Nuxt при отсутствии сессии**
    - **Validates: Requirements 7.2**
    - `fast-check`, ≥100 итераций, мок-сессия

  - [ ]* 9.6 Property-тест восстановления исходного маршрута
    - **Property 7: Восстановление исходного маршрута после аутентификации**
    - **Validates: Requirements 7.5**
    - `fast-check`, ≥100 итераций

  - [ ]* 9.7 Property-тест редиректа при недействительном токене
    - **Property 8: Редирект Nuxt при недействительном токене**
    - **Validates: Requirements 7.6**
    - `fast-check`, ≥100 итераций

- [ ] 10. Тесты JS-логики темы (этот репозиторий)
  - [ ]* 10.1 Property-тест видимости перехода к регистрации
    - **Property 9: Видимость перехода к регистрации соответствует флагу realm**
    - **Validates: Requirements 10.1, 10.2**
    - `fast-check`, ≥100 итераций
  - [ ]* 10.2 Property-тест сохранения значений формы регистрации при ошибке
    - **Property 10: Сохранение значений формы регистрации при ошибке валидации**
    - **Validates: Requirements 10.6**
    - `fast-check`, ≥100 итераций

- [ ] 11. Integration / smoke / snapshot тесты
  - [ ]* 11.1 Integration: обслуживание страницы входа и hostname
    - Отдача страницы входа на `auth.kanji-flow.online`, канонический хост в URL,
      issuer в `/.well-known/openid-configuration`, отклонение недопустимого хоста
      и HTTP в prod, backchannel JWKS по внутреннему адресу
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 1.6, 1.7, 6.1_

  - [ ]* 11.2 Integration: логин/пароль, brute force, сброс, Telegram, PKCE, роли
    - Логин по username/email, срок токена 300c, обобщённая ошибка, brute force,
      сброс пароля; Telegram-поток (существующий/новый аккаунт, ошибка); PKCE и
      redirect URI на стороне Keycloak, logout; `realm_access.roles` в токене
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2, 4.3, 4.4, 5.2, 5.3, 5.5, 5.6, 5.7, 6.6_

  - [ ]* 11.3 Integration: импорт realm и регистрация
    - Импорт realm с чистой БД ≤120c; применение к существующему realm;
      успешная регистрация запускает required actions; прерывание импорта при
      битом `realm-export.json`
    - _Requirements: 9.4, 9.5, 9.6, 10.5_

  - [ ]* 11.4 Unit/example: удаление auth-логики и секреты
    - Отсутствие форм/логики логин-пароль в кодовых базах Nuxt/NestJS; запрос к
      удалённому auth-эндпоинту → 404/410; недоступность JWKS → 401;
      отсутствие секретов в отслеживаемых файлах, наличие плейсхолдеров в `.env.example`
    - _Requirements: 6.5, 7.1, 7.3, 7.4, 8.1, 8.3, 8.7, 9.3_

  - [ ]* 11.5 Smoke/snapshot: наличие темы и соответствие рендера эталону
    - Наличие темы и provider-JAR в образе, значения в `theme.properties` и
      `realm-export.json`, доступность JWKS, конфигурация прокси/hostname;
      snapshot рендера темы (палитра `plum`, тёмная тема, единые брендированные
      элементы входа и регистрации)
    - _Requirements: 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 2.8, 4.1, 4.5, 5.1, 6.8, 9.1, 9.2, 10.7_

- [ ] 12. Финальный checkpoint
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Задачи с постфиксом `*` — тестовые, опциональны для быстрого MVP и не
  реализуются автоматически.
- Каждая задача ссылается на конкретные подпункты требований для трассируемости.
- Property-тесты реализуются на `fast-check` (≥100 итераций) и помечаются
  комментарием `Feature: custom-auth-page, Property {N}: {текст свойства}`.
- Задачи NestJS (эпик 8) и Nuxt (эпик 9) — контракты интеграции в отдельных
  репозиториях; задачи темы/realm/Docker/env (эпики 1–6) — в этом репозитории.
- Инфраструктурные и UI-аспекты покрываются integration/smoke/snapshot-тестами;
  property-based тесты покрывают логику нашего кода (PKCE, guard, middleware,
  логика темы).

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1", "8.1", "9.1"] },
    { "id": 1, "tasks": ["1.2", "2.2", "2.3", "2.4", "2.5", "8.2", "8.3", "9.2", "9.3"] },
    { "id": 2, "tasks": ["3.1", "3.2", "3.3", "3.4", "5.1", "2.6", "8.4", "8.5", "8.6", "8.7", "9.4", "9.5", "9.6", "9.7"] },
    { "id": 3, "tasks": ["4.1", "5.2", "5.3", "6.2", "10.1", "10.2"] },
    { "id": 4, "tasks": ["6.1", "6.3"] },
    { "id": 5, "tasks": ["11.1", "11.2", "11.3", "11.4", "11.5"] }
  ]
}
```

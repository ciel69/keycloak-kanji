# План реализации: Кастомная страница авторизации (custom-auth-page)

## Обзор

Реализация переносит аутентификацию realm `KanjiFlow` в Keycloak на хосте
`auth.kanji-flow.online` с кастомной брендированной темой `kanji-flow`. Работа
ведётся инкрементально и **только на стороне Keycloak**: сначала каркас и стили
темы, затем FreeMarker-шаблоны и локализация, далее декларативная конфигурация
(`realm-export.json`, `Dockerfile`, `.env`, hostname/прокси), и в завершение —
интеграционные, smoke- и snapshot-тесты самого Keycloak.

Границы:

- **В области спеки (этот репозиторий, keycloak-kanji):** тема
  (`themes/kanji-flow/`), `realm-export.json`, `Dockerfile`, `.env`/`.env.example`,
  конфигурация hostname/прокси, тесты JS-логики темы и integration/smoke/snapshot
  самого Keycloak.
- **Вне области спеки:** реализация фронтенда Nuxt (`nuxt-web`) и бэкенда NestJS
  (`nest-api`). Настройка Keycloak лишь делает нужный сценарий возможным (PKCE,
  точный redirect URI, JWKS, роли в токене, logout). Шаги интеграции на стороне
  Nuxt/NestJS будут описаны в отдельном гайдлайне после реализации.

Property-based тесты используют `fast-check` (TypeScript/JavaScript), минимум
100 итераций, каждый помечается комментарием
`Feature: custom-auth-page, Property {N}: {текст свойства}` и покрывают
**только наш собственный код в теме** `kanji-flow`.

## Tasks

- [x] 1. Каркас темы `kanji-flow`
  - [x] 1.1 Создать структуру каталога темы и `theme.properties`
    - Создать `themes/kanji-flow/login/` с подкаталогами `messages/`,
      `resources/css/`, `resources/js/`, `resources/img/`, `resources/img/icons/`
    - Создать `theme.properties`: `parent=keycloak`, `import=common/keycloak`,
      `locales=ru,en`, `styles=css/entry.css css/login.css css/kanji-flow.css`,
      `scripts=js/theme-mode.js js/password-toggle.js js/password-strength.js`,
      `kcHtmlClass` для тёмной темы
    - _Requirements: 2.1, 2.2, 2.3_

  - [x] 1.2 Реализовать общий каркас `template.ftl`
    - Переопределить `template.ftl` с брендированной карточкой
      (`max-w-md rounded-card shadow-card`), логотипом `new-circle-logo.svg`,
      упрощёнными header/footer со ссылками на `kanji-flow.online`
    - Подключить блок выбора локали и вывод сообщений (`messagesPerField`) из
      базовой темы; разместить логотипы (`new-circle-logo.svg`, `new-logo.svg`) и
      иконки (google, telegram) в `resources/img/`
    - _Requirements: 2.2, 2.4, 6.7_

- [x] 2. Стратегия стилизации Tailwind CSS
  - [x] 2.1 Подготовить скомпилированный Tailwind CSS темы
    - Настроить минимальный Tailwind-конфиг с палитрой `plum`, `darkMode: 'class'`
      и токенами (`rounded-card`, `shadow-card`), `content` по `.ftl`-шаблонам темы
    - Скомпилировать результат в `resources/css/entry.css`; перенести специфичные
      стили страницы входа из `front_tmp/_nuxt/login.*.css` в
      `resources/css/login.css` под стабильными именами
    - _Requirements: 2.7, 2.8_

  - [x] 2.2 Портировать стили провайдер-кнопок в `kanji-flow.css`
    - Перенести стили `.auth-provider-btn` и связанные из инлайновых `<style>`
      блоков эталона (`front_tmp/auth/login/index.html`) в
      `resources/css/kanji-flow.css`, удалив Vue-скоуп-атрибуты (`[data-v-*]`)
    - _Requirements: 2.7, 2.8_

  - [x] 2.3 Реализовать `theme-mode.js` (инициализация тёмной темы)
    - Воспроизвести логику эталона: чтение `localStorage` (`vueuse-color-scheme`)
      и `prefers-color-scheme`, установка класса `dark` на `<html>`
    - _Requirements: 2.8_

  - [x] 2.4 Реализовать `password-toggle.js` (показать/скрыть пароль)
    - Переключение атрибута `type` поля пароля и состояния иконки-глаза
    - _Requirements: 6.7_

  - [x] 2.5 Реализовать `password-strength.js` (индикатор сложности)
    - Экспортировать чистую функцию оценки пароля, возвращающую ровно один из ≥3
      дискретных уровней (например, слабый/средний/надёжный); пароль,
      соответствующий политике пароля realm, получает уровень не ниже
      несоответствующего
    - Подключить функцию к полю пароля формы регистрации
    - _Requirements: 6.8_

  - [ ]* 2.6 Property-тест функции оценки сложности пароля
    - **Property 3: Дискретные уровни индикатора сложности пароля**
    - **Validates: Requirements 6.8**
    - `fast-check`, ≥100 итераций, тег
      `Feature: custom-auth-page, Property 3: ...`

- [x] 3. FreeMarker-шаблоны аутентификации
  - [x] 3.1 Реализовать `login.ftl` (форма входа)
    - Поле `username` (вход по email/username), поле пароля с кнопкой «показать»,
      кнопка «Войти» (`bg-plum-600`), разделитель «Или», кнопки социальных
      провайдеров (динамическая итерация по `social.providers` — рендер всех
      включённых провайдеров без хардкода, grid-сетка, масштабируемая при любом
      количестве провайдеров), условная ссылка
      «Нет аккаунта? Зарегистрироваться» при `realm.registrationAllowed`
    - Извлечь логику видимости ссылки регистрации в тестируемую чистую JS-функцию
      (видна тогда и только тогда, когда `registrationAllowed=true`)
    - _Requirements: 2.4, 3.3, 4.1, 6.1, 6.2, 6.7, 8.1, 8.2, 8.3, 8.4_

  - [ ]* 3.2 Property-тест видимости перехода к регистрации
    - **Property 1: Видимость перехода к регистрации соответствует флагу realm**
    - **Validates: Requirements 6.1, 6.2**
    - `fast-check`, ≥100 итераций, генерация булева флага `registrationAllowed`,
      тег `Feature: custom-auth-page, Property 1: ...`

  - [x] 3.3 Реализовать `register.ftl` (форма регистрации)
    - Обязательные поля realm (минимум email, пароль, подтверждение пароля),
      индикатор сложности (`password-strength.js`), ссылка «Уже есть аккаунт? Войти»
      (`${url.loginUrl}`), повторный показ значений непарольных полей при ошибке
      через `messagesPerField`
    - Извлечь логику сохранения значений формы (сохранение непарольных полей,
      очистка полей пароля) в тестируемую чистую JS-функцию
    - _Requirements: 6.3, 6.4, 6.5, 6.6, 6.7, 6.8_

  - [ ]* 3.4 Property-тест сохранения значений формы регистрации при ошибке
    - **Property 2: Сохранение значений формы регистрации при ошибке валидации**
    - **Validates: Requirements 6.6**
    - `fast-check`, ≥100 итераций, генерация произвольных наборов значений полей,
      тег `Feature: custom-auth-page, Property 2: ...`

  - [x] 3.5 Реализовать шаблоны сброса пароля
    - `login-reset-password.ftl` (запрос сброса) и `login-update-password.ftl`
      (установка нового пароля) в стиле темы
    - _Requirements: 2.4, 3.5, 3.6_

  - [x] 3.6 Реализовать `login-verify-email.ftl` и `login-otp.ftl`
    - Страницы подтверждения email и ввода OTP в стиле темы
    - _Requirements: 2.4, 6.5_

- [x] 4. Локализация темы
  - [x] 4.1 Создать файлы сообщений `messages_ru.properties` и `messages_en.properties`
    - Ключи для форм входа/регистрации, ссылок перехода
      («Нет аккаунта? Зарегистрироваться», «Уже есть аккаунт? Войти»), индикатора
      сложности, сообщений об ошибках
    - _Requirements: 2.3, 2.5, 6.1, 6.4_

- [x] 5. Декларативная конфигурация `realm-export.json`
  - [x] 5.1 Настроить realm-уровневые параметры
    - Добавить `loginTheme: "kanji-flow"` и `verifyEmail: true`; подтвердить
      `registrationAllowed`, `resetPasswordAllowed`, `loginWithEmailAllowed`,
      brute force (`bruteForceProtected=true`, `failureFactor=5`,
      `maxFailureWaitSeconds=900`, `permanentLockout=false`),
      `accessTokenLifespan=300`, `actionTokenGeneratedByUserLifespan=300`,
      `defaultLocale=ru`, `supportedLocales=[ru,en]`
    - _Requirements: 2.4, 2.6, 3.1, 3.4, 3.5, 3.6, 6.5, 7.1_

  - [x] 5.2 Настроить клиент `nuxt-web` (PKCE, redirect URI, logout)
    - Подтвердить `publicClient`, Authorization Code Flow,
      `pkce.code.challenge.method=S256`, `frontchannelLogout=true`; добавить
      `https://kanji-flow.online/auth/callback` и dev-эквиваленты в `redirectUris`,
      сузить для production
    - _Requirements: 5.1, 5.2, 5.5, 5.6, 5.7, 7.1_

  - [x] 5.3 Настроить клиент `nest-api` и маппер ролей
    - Подтвердить конфиденциальность `nest-api` (`publicClient=false`,
      `serviceAccountsEnabled=true`); подтвердить/добавить protocol mapper realm
      roles, чтобы `realm_access.roles` попадали в выпускаемый токен
    - _Requirements: 5.9, 5.10, 7.1_

  - [x] 5.4 Добавить Telegram identity provider
    - Секция `identityProviders` с alias Telegram, параметрами (`client_id`/secret
      через переменные окружения), маппингами атрибутов
    - _Requirements: 4.1, 4.5, 7.1_

- [ ] 5b. Кастомный провайдер GeoIP_Фильтр (серверная гео-фильтрация)
  - [ ] 5b.1 Создать Java-проект GeoIP_Фильтр
    - Maven/Gradle проект с зависимостями: Keycloak SPI (`keycloak-server-spi`,
      `keycloak-server-spi-private`), MaxMind GeoIP2 Java API, встроенная БД
      `GeoLite2-Country.mmdb` в `src/main/resources/`
    - Структура: `src/main/java/com/kanjiflow/keycloak/geo/`,
      `src/main/resources/META-INF/services/`,
      `src/main/resources/GeoLite2-Country.mmdb`
    - _Requirements: 9.1, 9.6_

  - [ ] 5b.2 Реализовать GeoIP-lookup сервис
    - Класс, извлекающий IP из заголовков `X-Forwarded-For` (первый адрес) /
      `X-Real-IP` (fallback); определение страны (ISO 3166-1 alpha-2) по
      GeoLite2 базе через MaxMind GeoIP2 Java API; fallback-поведение при
      невозможности определить страну (конфигурируемое: `SHOW_ALL` /
      `SHOW_UNRESTRICTED`)
    - _Requirements: 9.1, 9.5_

  - [ ] 5b.3 Реализовать фильтрацию списка identity providers
    - Keycloak SPI (Authenticator или расширение LoginFormsProvider),
      перехватывающее рендер страницы входа; чтение атрибутов
      `geoAllowedCountries` / `geoBlockedCountries` из конфигурации каждого IdP;
      логика фильтрации: whitelist имеет приоритет над blacklist; отсутствие
      атрибутов = показать всем; фильтрация `social.providers` ДО передачи в
      FreeMarker — исключённые провайдеры не появляются в HTML
    - _Requirements: 9.2, 9.3, 9.4, 9.7, 9.8_

  - [ ] 5b.4 Собрать JAR и разместить в `providers/`
    - Сборка fat-JAR (с GeoLite2 базой и зависимостями MaxMind), размещение в
      `providers/keycloak-geo-provider-filter-*.jar`
    - _Requirements: 9.6, 7.2_

  - [ ] 5b.5 Настроить гео-атрибуты провайдеров в `realm-export.json`
    - Добавить атрибуты `geoAllowedCountries` / `geoBlockedCountries` для
      соответствующих identity providers (например, `geoBlockedCountries=RU` для
      Google/GitHub, `geoAllowedCountries=RU` для VK/Яндекс); документировать
      настройку в README
    - _Requirements: 9.4_

- [x] 6. Образ, переменные окружения и hostname/прокси
  - [x] 6.1 Обновить `Dockerfile`
    - На этапе `builder` копировать `themes/` и `providers/` (включая
      `keycloak-geo-provider-filter-*.jar`) в `/opt/keycloak/themes/` и
      `/opt/keycloak/providers/`, `realm-export.json` в
      `/opt/keycloak/data/import/realm.json`, выполнить `kc.sh build --db=postgres`;
      перенести оптимизированную сборку на этап `runtime`
    - _Requirements: 2.1, 4.5, 7.2, 9.6_

  - [x] 6.2 Обновить `.env` и `.env.example`
    - Переориентировать `KEYCLOAK_HOSTNAME` на `auth.kanji-flow.online`; добавить
      плейсхолдеры секретов Telegram-бота (`TELEGRAM_BOT_ID`/`TELEGRAM_BOT_TOKEN`
      или client secret IdP) без реальных значений; подтвердить SMTP-плейсхолдеры
    - _Requirements: 7.3_

  - [x] 6.3 Настроить hostname/прокси для `auth.kanji-flow.online`
    - Production-переменные: `KC_HOSTNAME=https://auth.kanji-flow.online`,
      `KC_HOSTNAME_STRICT=true`, `KC_HOSTNAME_BACKCHANNEL_DYNAMIC=false`,
      `KC_PROXY_HEADERS=xforwarded`, `KC_HTTP_ENABLED=false`, `KC_HOSTNAME_ADMIN`;
      сохранить мягкий режим (`KC_HTTP_ENABLED=true`, `KC_HOSTNAME_STRICT=false`)
      для локального `docker-compose`; обновить `docker-compose.yml`/env-шаблоны
    - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7_

- [x] 7. Checkpoint — сборка образа и импорт realm
  - Ensure all tests pass, ask the user if questions arise.

- [x] 8. Integration / smoke / snapshot тесты (сторона Keycloak)
  - [ ]* 8.1 Integration: обслуживание страницы входа и hostname
    - Отдача страницы входа на `auth.kanji-flow.online`, канонический хост в URL,
      issuer в `/.well-known/openid-configuration`; отклонение недопустимого хоста
      и HTTP в production; backchannel JWKS по внутреннему адресу
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 1.6, 1.7_

  - [ ]* 8.2 Integration: логин/пароль, brute force, сброс, Telegram, PKCE, роли
    - Логин по username/email (срок токена 300c), обобщённая ошибка без указания
      поля, brute force, сброс пароля и просроченная ссылка; Telegram-поток
      (существующий/новый аккаунт, ошибка/таймаут); PKCE-энфорсмент и валидация
      redirect URI на стороне Keycloak, logout завершает SSO; наличие
      `realm_access.roles` в выданном токене; доступность JWKS по общедоступной
      конечной точке
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2, 4.3, 4.4, 5.2, 5.3, 5.4, 5.5, 5.6, 5.7, 5.8, 5.9_

  - [ ]* 8.6 Integration: серверная гео-фильтрация identity providers
    - Запрос с IP из РФ (X-Forwarded-For → GeoIP=RU): видны только провайдеры с
      `geoAllowedCountries` включающим `RU` или без гео-атрибутов; провайдеры с
      `geoBlockedCountries=RU` отсутствуют в HTML
    - Запрос с IP не из РФ (US): провайдеры с `geoAllowedCountries=RU`
      отсутствуют; провайдеры без ограничений и с `geoAllowedCountries` включающим
      `US` присутствуют
    - IdP без атрибутов `geoAllowedCountries`/`geoBlockedCountries` отображается
      для всех стран
    - GeoIP failure (IP не найден): применяется поведение по умолчанию
    - HTML-ответ НЕ содержит упоминаний исключённых провайдеров (grep по source)
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.7, 9.8_

  - [ ]* 8.3 Integration: импорт realm и регистрация
    - Импорт realm с чистой БД ≤120c со всеми клиентами, `loginTheme` и IdP;
      применение к существующему realm (ручной порядок); успешная регистрация
      создаёт учётную запись и запускает required actions; прерывание импорта при
      отсутствующем/битом `realm-export.json` без частичного realm
    - _Requirements: 6.5, 7.4, 7.5, 7.6_

  - [ ]* 8.4 Smoke: наличие артефактов, конфигурация и секреты
    - Наличие темы и provider-JAR в образе, значения в `theme.properties`
      (`parent`, `locales`) и `realm-export.json` (`loginTheme`, атрибуты клиентов
      `nuxt-web`/`nest-api`, IdP); конфигурация прокси/hostname; плейсхолдеры
      секретов в `.env.example` и отсутствие реальных секретов в отслеживаемых
      файлах
    - _Requirements: 1.4, 2.1, 2.2, 2.3, 2.6, 4.5, 5.1, 5.10, 7.1, 7.2, 7.3_

  - [ ]* 8.5 Snapshot: соответствие рендера темы эталону
    - Snapshot рендера страниц входа и регистрации: палитра `plum`, тёмная тема,
      единые брендированные элементы (логотип, шрифты, карточка), применение темы
      ко всем страницам аутентификации и локали по умолчанию
    - _Requirements: 2.4, 2.5, 2.7, 2.8, 4.1, 6.7_

- [x] 9. Финальный checkpoint
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Задачи с постфиксом `*` — тестовые, опциональны для быстрого MVP и не
  реализуются автоматически.
- Каждая задача ссылается на конкретные подпункты требований для трассируемости.
- Спека охватывает **только сторону Keycloak**. Реализация фронтенда Nuxt
  (`nuxt-web`) и бэкенда NestJS (`nest-api`) — **вне области спеки**; шаги
  интеграции на их стороне будут описаны в **отдельном гайдлайне после
  реализации**. Настройка Keycloak лишь делает нужный сценарий возможным (PKCE,
  точный redirect URI, JWKS, роли в токене, logout).
- Property-based тесты покрывают **только наш собственный код в теме**
  `kanji-flow` (логика видимости ссылки регистрации, сохранение значений формы,
  оценка сложности пароля), реализуются на `fast-check` (≥100 итераций) и
  помечаются комментарием `Feature: custom-auth-page, Property {N}: {текст}`.
- Инфраструктурные, конфигурационные и встроенные потоки Keycloak
  (hostname/прокси, логин/пароль, PKCE, redirect URI, JWKS, роли, logout,
  Telegram, регистрация, импорт realm) покрываются integration/smoke/snapshot
  тестами.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "2.1", "5b.1"] },
    { "id": 1, "tasks": ["1.2", "2.2", "2.3", "2.4", "2.5", "5b.2"] },
    { "id": 2, "tasks": ["3.1", "3.3", "3.5", "3.6", "2.6", "5.1", "5b.3"] },
    { "id": 3, "tasks": ["3.2", "3.4", "4.1", "5.2", "5b.4"] },
    { "id": 4, "tasks": ["5.3", "5b.5", "6.1", "6.2"] },
    { "id": 5, "tasks": ["5.4", "6.3"] },
    { "id": 6, "tasks": ["8.1", "8.2", "8.3", "8.4", "8.5", "8.6"] }
  ]
}
```

# Design Document

## Overview

Фича превращает инстанс Keycloak (26.5.0.1, русская локализация,
образ `playaru/keycloak-russian`) в единую точку аутентификации экосистемы
Kanji Flow, обслуживаемую на публичном хосте `auth.kanji-flow.online`, для realm
`KanjiFlow`. Аутентификация (вход по логину/паролю, вход через Telegram,
регистрация) выполняется на брендированных страницах кастомной темы `kanji-flow`,
воспроизводящей вёрстку эталонной страницы входа фронтенда.

Ключевые принципы дизайна:

- **Декларативность.** Конфигурация realm (клиенты, тема, identity provider,
  политики) хранится в `realm-export.json`; тема и provider-JAR копируются в
  образ через `Dockerfile`; секреты передаются только через переменные
  окружения. (Requirement 7)
- **Разделение ответственности.** Keycloak отвечает за аутентификацию, выпуск
  токенов и публикацию ключей: `nuxt-web` (public, PKCE S256) делегирует вход
  через Authorization Code Flow; `nest-api` (confidential с сервисным аккаунтом)
  является потребителем токенов. Внутренняя логика этих приложений вне области
  спеки. (Requirement 5)
- **Единый бренд.** Тема `kanji-flow` наследует базовую тему `keycloak` и
  переопределяет только шаблоны, стили и сообщения, воспроизводя дизайн на
  утилитарных классах Tailwind CSS (палитра `plum`, тёмная тема) из эталонной
  статики `front_tmp/`. (Requirement 2)

### Область спеки и вынесенная интеграция

Спека охватывает **только сторону Keycloak**: hostname/прокси, тему, вход по
логину/паролю, Telegram IdP, настройку OIDC-клиентов и токенов, регистрацию и
декларативную конфигурацию. Реализация и поведение фронтенда (Nuxt) и бэкенда
(NestJS) находятся **вне области спеки**.

Шаги интеграции на стороне фронтенда и бэкенда будут описаны в **отдельном
гайдлайне после реализации**. Бэкенд уже поддерживает нужный сценарий: серверный
обмен authorization code на токены, установка собственных http-only кук для
`*.kanji-flow.online` и выпуск собственного CSRF-токена — по той же схеме, что и
существующий вход через Google-провайдер. Данный дизайн не специфицирует эту
логику, а лишь настраивает Keycloak так, чтобы такой сценарий был возможен
(PKCE, точный redirect URI, JWKS, роли в токене).

### Соответствие требованиям (карта разделов)

| Раздел дизайна | Требования |
|---|---|
| Architecture → Hostname/Proxy | R1 |
| Components → Тема `kanji-flow` | R2 |
| Components → Стратегия стилизации (Tailwind) | R2 |
| Components → Логин/пароль, brute force, reset | R3 |
| Components → Telegram IdP | R4 |
| Components → OIDC-клиенты и токены (Keycloak-side) | R5 |
| Components → Регистрация и переключение | R6 |
| Data Models → Конфигурация (`realm-export.json`, `Dockerfile`, `.env`) | R7 |
| Correctness Properties + Testing Strategy | R6 (тестируемая логика темы), интеграция/smoke — R1–R5, R7 |

### Замечание о переносе домена

Текущая инфраструктура (steering, `.env.example`, `realm-export.json`,
`docker-compose.yml`) ссылается на `keycloak.kanji-flow.online`. Дизайн
предусматривает переход на `auth.kanji-flow.online` как основной хост
аутентификации: обновляются `KC_HOSTNAME`/`KC_HOSTNAME_URL`, конфигурация
реверс-прокси и redirect URI клиентов. Прежний хост может быть оставлен как
редирект на уровне прокси на переходный период, но `KC_HOSTNAME_STRICT=true`
в production допускает единственный канонический хост `auth.kanji-flow.online`.

## Architecture

### Топология развёртывания

```mermaid
graph TB
    subgraph Internet
        User[Браузер пользователя]
        TG[Telegram OAuth<br/>oauth.telegram.org]
    end

    subgraph Edge["Реверс-прокси (HTTPS termination)"]
        Proxy["nginx / traefik / caddy<br/>auth.kanji-flow.online<br/>TLS + X-Forwarded-*"]
    end

    subgraph DockerNet["Docker-сеть kanji-flow"]
        KC["Keycloak 26.5.0.1<br/>service: keycloak:8080<br/>realm KanjiFlow<br/>тема kanji-flow"]
        PG[("PostgreSQL 16<br/>service: postgres:5432")]
    end

    subgraph External["Внешние потребители (вне области спеки)"]
        Nuxt["Nuxt SPA/SSR<br/>client nuxt-web (public, PKCE)"]
        Nest["NestJS<br/>client nest-api (confidential + service account)"]
    end

    User -->|"HTTPS auth.kanji-flow.online"| Proxy
    Proxy -->|"HTTP + X-Forwarded-*"| KC
    KC --> PG
    KC -. "OAuth редирект" .-> TG
    Nuxt -->|"OIDC authorize (front-channel)"| Proxy
    Nest -->|"token exchange / JWKS<br/>internal: http://keycloak:8080"| KC
```

Front-channel (браузерные редиректы, страница входа, ссылки в письмах) проходит
через публичный хост `auth.kanji-flow.online`. Back-channel (token endpoint,
получение JWKS) доступен по внутреннему имени Docker-сервиса
`http://keycloak:8080`, минуя публичный хост. Nuxt и NestJS показаны как внешние
потребители настроенных в Keycloak клиентов; их внутренняя реализация вне области
спеки. (Requirements 1.6, 5.8)

### Конфигурация hostname и прокси

Keycloak 26.x использует раздельные опции hostname v2. Значения для production:

| Переменная | Значение (prod) | Назначение | Требование |
|---|---|---|---|
| `KC_HOSTNAME` | `https://auth.kanji-flow.online` | Канонический публичный URL front-channel | 1.1, 1.3 |
| `KC_HOSTNAME_STRICT` | `true` | Запрет обслуживания на других хостах | 1.5 |
| `KC_HOSTNAME_BACKCHANNEL_DYNAMIC` | `false` | Backchannel по внутреннему адресу, не по публичному хосту | 1.6 |
| `KC_PROXY_HEADERS` | `xforwarded` | Доверять `X-Forwarded-*` от прокси | 1.4 |
| `KC_HTTP_ENABLED` | `false` | Отключить HTTP в production | 1.7 |
| `KC_HOSTNAME_ADMIN` | `https://auth.kanji-flow.online` | URL админ-консоли (при необходимости отдельный) | 1.3 |

Для локальной разработки (docker-compose) сохраняется мягкий режим:
`KC_HTTP_ENABLED=true`, `KC_HOSTNAME_STRICT=false`, доступ по
`http://localhost:8080`.

Реверс-прокси завершает TLS и проксирует на `keycloak:8080`, проставляя
`X-Forwarded-Proto: https`, `X-Forwarded-Host: auth.kanji-flow.online`,
`X-Forwarded-For`. Так Keycloak формирует все абсолютные URL (issuer, редиректы,
ссылки в письмах) со схемой `https` и хостом `auth.kanji-flow.online`.
(Requirements 1.3, 1.4)

Отклонение недопустимого хоста: при `KC_HOSTNAME_STRICT=true` запрос с
`Host`/`X-Forwarded-Host`, отличным от канонического, не обслуживается страницей
входа. (Requirement 1.5) Запрос по HTTP в production не обслуживается, т.к.
HTTP-listener выключен (`KC_HTTP_ENABLED=false`) и прокси принимает только
HTTPS. (Requirement 1.7)

### Многоуровневый образ и деплой

`Dockerfile` (multi-stage) на этапе `builder` копирует `providers/`, `themes/`
и `realm-export.json`, выполняет `kc.sh build --db=postgres`; этап `runtime`
переносит оптимизированную сборку. Тема и provider-JAR попадают в образ на этапе
сборки, поэтому доступны сразу после старта без ручной настройки.
(Requirements 2.1, 4.5, 7.2)

## Components and Interfaces

### 1. Тема `kanji-flow` (login theme)

Тема наследует базовую тему `keycloak` и переопределяет только необходимое:
шаблоны, стили, сообщения, ресурсы. (Requirement 2.2)

#### Структура каталога темы

```
themes/
└── kanji-flow/
    └── login/
        ├── theme.properties
        ├── login.ftl                 # форма входа (email/пароль, показать пароль)
        ├── register.ftl              # форма регистрации (+ индикатор сложности)
        ├── login-reset-password.ftl  # запрос сброса пароля
        ├── login-update-password.ftl # установка нового пароля
        ├── login-verify-email.ftl    # подтверждение email
        ├── login-otp.ftl             # ввод OTP
        ├── template.ftl              # общий каркас (header/footer/карточка)
        ├── messages/
        │   ├── messages_ru.properties
        │   └── messages_en.properties
        └── resources/
            ├── css/
            │   ├── entry.css         # скомпилированный Tailwind (из front_tmp/_nuxt/entry.*.css)
            │   ├── login.css         # доп. стили страницы входа (из front_tmp/_nuxt/login.*.css)
            │   └── kanji-flow.css    # маппинг классов провайдер-кнопок (auth-provider-btn и пр.)
            ├── js/
            │   ├── theme-mode.js     # инициализация тёмной темы (localStorage vueuse-color-scheme)
            │   ├── password-toggle.js# показать/скрыть пароль
            │   └── password-strength.js # индикатор сложности пароля (регистрация)
            └── img/
                ├── new-circle-logo.svg
                ├── new-logo.svg
                └── icons/            # google, telegram
```

#### `theme.properties`

```properties
parent=keycloak
import=common/keycloak
locales=ru,en
styles=css/entry.css css/login.css css/kanji-flow.css
scripts=js/theme-mode.js js/password-toggle.js js/password-strength.js
kcHtmlClass=min-h-screen flex flex-col bg-white text-gray-900 dark:bg-gray-900 dark:text-white
```

- `parent=keycloak` — наследование поведения и макросов базовой темы.
  (Requirement 2.2)
- `locales=ru,en` — согласовано с `supportedLocales` realm; при неподдерживаемой
  локали используется `defaultLocale=ru`. (Requirements 2.3, 2.5)
- `styles` подключает скомпилированный Tailwind CSS. (Requirements 2.7, 2.8)

Применение темы ко всем страницам аутентификации (вход, сброс пароля, OTP,
подтверждение email) обеспечивается тем, что `loginTheme=kanji-flow` в realm, а
переопределённые `.ftl` покрывают эти экраны. (Requirement 2.4)

### 2. Стратегия стилизации (Tailwind CSS) — критично

Эталон вёрстки — `front_tmp/auth/login/index.html`; источник истины по стилям —
скомпилированные бандлы в `front_tmp/_nuxt/`. Фактические файлы в текущей сборке:

- `front_tmp/_nuxt/entry.DMqLczhX.css` — основной бандл утилит Tailwind
  (базовые утилиты, палитра `plum`, тёмная тема через класс `dark` на `<html>`,
  токены `rounded-card`, `shadow-card`).
- `front_tmp/_nuxt/login.QleP5zni.css` — специфичные стили страницы входа.
- Инлайновые стили из `<style>` блоков эталона (например, класс
  `.auth-provider-btn` со скоупом `data-v-15dc68fb`) — переносятся в
  `resources/css/kanji-flow.css` уже без Vue-скоуп-атрибутов.

> Примечание: имена бандлов содержат контент-хэши сборки и меняются при каждой
> пересборке фронтенда. В теме файлы сохраняются под стабильными именами
> (`entry.css`, `login.css`), а исходные хэшированные версии из `front_tmp/_nuxt/`
> копируются/переименовываются на этапе подготовки темы.

#### Как получить/сшить CSS

1. **Базовый вариант (снимок).** Скопировать текущие `entry.*.css` и
   `login.*.css` из `front_tmp/_nuxt/` в
   `themes/kanji-flow/login/resources/css/` под стабильными именами. Это даёт
   попиксельное совпадение с эталоном без пересборки. Скоуп-стили провайдер-кнопок
   вынести в `kanji-flow.css`, убрав `[data-v-*]`.
2. **Воспроизводимый вариант (сборка Tailwind).** Отдельный минимальный
   Tailwind-конфиг с той же палитрой (`plum`), `darkMode: 'class'` и токенами
   (`rounded-card`, `shadow-card`), скомпилированный по контенту `.ftl`-шаблонов
   темы (`content: ['themes/kanji-flow/login/**/*.ftl']`). Результат кладётся в
   `resources/css/entry.css`. Этот путь исключает «мёртвые» утилиты и защищает от
   рассинхронизации имён бандлов.

Рекомендуется вариант 2 для поддерживаемости, с вариантом 1 как быстрым
стартом. В обоих случаях класс `dark` на `<html>` включается скриптом
`theme-mode.js`, повторяющим логику эталона (чтение `localStorage`
`vueuse-color-scheme` и `prefers-color-scheme`). (Requirements 2.7, 2.8)

#### Маппинг эталонной вёрстки на FreeMarker

Keycloak рендерит вход и регистрацию как **отдельные страницы** (`login.ftl` и
`register.ftl`), связанные ссылками, а не как SPA-переключатель. Эталонная
кнопка «Нет аккаунта? Зарегистрироваться» в теме становится ссылкой
`${url.registrationUrl}`, а на странице регистрации ссылка «Уже есть аккаунт?
Войти» ведёт на `${url.loginUrl}`. (Requirements 6.1, 6.4)

| Элемент эталона | Реализация в теме |
|---|---|
| Карточка `max-w-md rounded-card shadow-card` + логотип | Обёртка в `template.ftl`, логотип `new-circle-logo.svg` |
| Поле Email (`type=email required`) | `login.ftl`: `<input name="username" type="text">` (вход по email/username) |
| Поле Пароль + кнопка «показать» (глаз) | `login.ftl` + `password-toggle.js` |
| Кнопка «Войти» (`bg-plum-600`) | `<input type="submit">` с классами `plum` |
| Ссылка «Нет аккаунта? Зарегистрироваться» | `${url.registrationUrl}`, отображается при `realm.registrationAllowed` |
| Разделитель «Или» | Блок `relative` с `border-t` и `<span>Или</span>` |
| Кнопки Google + Telegram (grid 2 колонки) | Итерация по `social.providers` из базовой темы |
| Header/Footer с навигацией | `template.ftl` (упрощённые, ссылки на `kanji-flow.online`) |

Условие показа ссылки на регистрацию основано на `realm.registrationAllowed`:
при `false` элемент не выводится. (Requirements 6.1, 6.2)

### 3. Вход по логину/паролю, brute force, сброс пароля

Поведение полностью определяется настройками realm (см. Data Models) и базовой
логикой Keycloak; тема отвечает только за отображение.

- Аутентификация по username **или** email (`loginWithEmailAllowed=true`),
  идентификатор 1–255 символов; при успехе выпускается access token с
  `accessTokenLifespan=300`. (Requirements 3.1, 3.2)
- Неверные данные: вход отклоняется, токен не выпускается, пользователь остаётся
  на странице входа, показывается обобщённое сообщение об ошибке без указания,
  какое поле неверно (стандартное `invalidUserMessage`). (Requirement 3.3)
- Brute force: `bruteForceProtected=true`, `failureFactor=5`,
  `maxFailureWaitSeconds=900`, `permanentLockout=false`. (Requirement 3.4)
- Сброс пароля: `resetPasswordAllowed=true`; письмо со ссылкой на
  `auth.kanji-flow.online`, срок `actionTokenGeneratedByUserLifespan=300`;
  просроченная ссылка отклоняется, пароль не меняется, показывается сообщение об
  истечении срока. (Requirements 3.5, 3.6)

### 4. Telegram identity provider

```mermaid
sequenceDiagram
    participant U as Пользователь
    participant KC as Keycloak (тема kanji-flow)
    participant TG as Telegram OAuth
    U->>KC: Открывает страницу входа
    KC-->>U: Кнопка "Telegram" (social.providers)
    U->>KC: Клик "Войти через Telegram"
    KC->>TG: Редирект на авторизацию Telegram
    TG-->>U: Виджет/подтверждение Telegram
    U->>TG: Подтверждает (в пределах 60 c)
    TG->>KC: Данные пользователя Telegram
    alt Аккаунт с этим Telegram ID существует
        KC->>KC: Связывает сессию с аккаунтом
        KC-->>U: Access token + сессия
    else Аккаунта нет
        KC->>KC: Создаёт аккаунт, привязывает Telegram ID
        KC-->>U: Access token + сессия
    else Ошибка / таймаут > 60 c
        KC-->>U: Возврат на страницу входа с ошибкой (без токена/сессии)
    end
```

- Provider-JAR `keycloak-telegram-identity-provider-1.0.3.jar` из `providers/`
  копируется в образ. (Requirement 4.5)
- Кнопка Telegram отображается темой как отдельный способ входа (итерация по
  `social.providers`). (Requirement 4.1)
- Существующий аккаунт — связывание сессии; отсутствующий — создание аккаунта с
  привязкой Telegram ID; успех в пределах 60 c → access token.
  (Requirements 4.2, 4.3)
- Ошибка/таймаут → возврат на страницу входа с сообщением, без токена и сессии.
  (Requirement 4.4)

Конфигурация identity provider (alias, client_id/secret Telegram-бота через env)
хранится в `realm-export.json` в секции `identityProviders`. (Requirement 7.1)

### 5. OIDC-клиенты и токены Keycloak (`nuxt-web`, `nest-api`)

Раздел описывает **поведение эндпоинтов Keycloak** и конфигурацию клиентов.
Браузер и клиентские приложения — внешние акторы; их реализация вне области
спеки. Диаграмма показывает поведение authorize/token эндпоинтов Keycloak при
взаимодействии с внешним клиентом `nuxt-web`.

```mermaid
sequenceDiagram
    participant B as Внешний клиент (браузер / nuxt-web)
    participant KC as Keycloak (auth.kanji-flow.online)
    Note over B: Клиент формирует code_verifier + code_challenge (S256) — вне области спеки
    B->>KC: GET /authorize?client_id=nuxt-web&code_challenge&method=S256&redirect_uri
    alt Некорректный запрос (нет challenge / метод != S256 / чужой redirect_uri)
        KC-->>B: Ошибка, код не выпускается, редиректа нет
    else Корректный запрос
        KC-->>B: Страница входа (тема kanji-flow)
        B->>KC: Учётные данные / Telegram
        KC-->>B: Редирект на точно зарегистрированный redirect_uri с code
    end
    B->>KC: POST /token (code + code_verifier)
    alt code_verifier не соответствует code_challenge
        KC-->>B: Ошибка PKCE, токены не выпускаются
    else Проверка PKCE успешна
        KC-->>B: access_token (с realm_access.roles) + id_token + refresh_token
    end
    Note over KC: JWKS публикуется по общедоступной конечной точке для проверки токенов
```

Поведение и конфигурация на стороне Keycloak:

- `nuxt-web`: public client, Authorization Code Flow,
  `pkce.code.challenge.method=S256`. (Requirement 5.1)
- Обязательность `code_challenge` + `S256`; при нарушении — отклонение запроса
  авторизации без выпуска кода. (Requirements 5.2, 5.3)
- Несоответствие `code_verifier` ↔ `code_challenge` при обмене — отклонение, без
  выпуска токенов. (Requirement 5.4)
- Редирект только на точно зарегистрированный redirect URI; несовпадение —
  отклонение без редиректа. (Requirements 5.5, 5.6)
- Logout: завершение SSO-сессии + front-channel logout
  (`frontchannelLogout=true`) для клиента `nuxt-web`. (Requirement 5.7)
- Keycloak публикует открытые ключи подписи (JWKS) по общедоступной конечной
  точке для проверки выпущенных токенов. (Requirement 5.8)
- В выпускаемый access token включаются роли пользователя (`realm_access.roles`)
  через стандартный protocol mapper realm roles. (Requirement 5.9)
- `nest-api`: конфиденциальный клиент (`publicClient=false`) с включённым
  сервисным аккаунтом (`serviceAccountsEnabled=true`). (Requirement 5.10)

### 6. Регистрация и переключение между входом и регистрацией

Регистрация реализуется страницей `register.ftl` темы `kanji-flow` поверх
встроенного механизма регистрации Keycloak.

- Ссылка перехода к регистрации на странице входа отображается тогда и только
  тогда, когда `realm.registrationAllowed=true`, с текстом «Нет аккаунта?
  Зарегистрироваться» и ведёт на `${url.registrationUrl}`. (Requirements 6.1, 6.2)
- Страница регистрации содержит обязательные поля realm (как минимум email,
  пароль и подтверждение пароля) и ссылку «Уже есть аккаунт? Войти» на
  `${url.loginUrl}`. (Requirements 6.3, 6.4)
- Успешная регистрация создаёт учётную запись и запускает настроенные required
  actions (например, подтверждение email при `verifyEmail=true`). Это встроенное
  поведение Keycloak. (Requirement 6.5)
- При ошибке валидации (email уже занят, пароль не соответствует политике,
  незаполнено обязательное поле) форма отображается повторно с сохранением
  значений всех непарольных полей и пустыми полями пароля, с сообщением у
  проблемного поля (используется `messagesPerField` базовой темы).
  (Requirement 6.6)
- Единые брендированные элементы (логотип KanjiFlow, палитра, шрифты, карточка)
  задаются в общем `template.ftl` и переиспользуются входом и регистрацией.
  (Requirement 6.7)
- При вводе пароля отображается индикатор сложности (`password-strength.js`) не
  менее чем с тремя различимыми уровнями, отражающими соответствие политике
  пароля realm. (Requirement 6.8)

Логика видимости ссылки регистрации, сохранения значений формы при ошибке и
оценки сложности пароля — это **наш код в теме** и является предметом
property-based тестов (см. Correctness Properties).

## Data Models

Изменения носят конфигурационный характер и остаются декларативными.

### `realm-export.json` (realm `KanjiFlow`)

Существующие значения уже удовлетворяют части требований. Необходимые дополнения
и подтверждения:

| Поле | Значение | Требование |
|---|---|---|
| `loginTheme` | `"kanji-flow"` (добавить) | 2.4, 2.6, 7.1 |
| `registrationAllowed` | `true` (есть) | 6.1 |
| `resetPasswordAllowed` | `true` (есть) | 3.5 |
| `loginWithEmailAllowed` | `true` (есть) | 3.2 |
| `verifyEmail` | `true` (добавить для required action email) | 6.5 |
| `bruteForceProtected` / `failureFactor` / `maxFailureWaitSeconds` / `permanentLockout` | `true / 5 / 900 / false` (есть) | 3.4 |
| `accessTokenLifespan` | `300` (есть) | 3.1 |
| `actionTokenGeneratedByUserLifespan` | `300` (есть) | 3.6 |
| `defaultLocale` / `supportedLocales` | `ru` / `[ru,en]` (есть) | 2.3, 2.5 |
| `clients[nuxt-web].attributes.pkce.code.challenge.method` | `"S256"` (есть) | 5.1 |
| `clients[nuxt-web].redirectUris` | добавить `https://kanji-flow.online/auth/callback` и dev-эквиваленты; сузить в prod | 5.5, 5.6 |
| `clients[nuxt-web].frontchannelLogout` | `true` (есть) | 5.7 |
| `clients[nest-api].publicClient` / `serviceAccountsEnabled` | `false` / `true` (есть) | 5.10 |
| protocol mapper realm roles (`realm_access.roles` в токене) | по умолчанию | 5.9 |
| `identityProviders[telegram]` | добавить (alias, config через env) | 4.1, 7.1 |

`smtpServer` уже параметризован через `${SMTP_*}` — секреты не хранятся в файле.
(Requirement 7.3)

### `Dockerfile`

```dockerfile
# этап builder — раскомментировать копирование тем
COPY themes/ /opt/keycloak/themes/
COPY providers/ /opt/keycloak/providers/
COPY realm-export.json /opt/keycloak/data/import/realm.json
RUN /opt/keycloak/bin/kc.sh build --db=postgres
```

(Requirements 2.1, 4.5, 7.2)

### `.env` / `.env.example`

Добавить/уточнить плейсхолдеры (без реальных значений): `KEYCLOAK_HOSTNAME`
переориентировать на `auth.kanji-flow.online`; секреты Telegram-бота
(`TELEGRAM_BOT_ID`/`TELEGRAM_BOT_TOKEN` или client secret IdP); SMTP-секреты уже
присутствуют. (Requirement 7.3)

### Порядок применения к существующему realm

`--import-realm` **не перезаписывает** уже существующие сущности. Поэтому
документируется пошаговый порядок: (Requirements 7.4, 7.5, 7.6)

1. **Чистая БД (новый стенд).** Контейнер стартует, realm импортируется из
   `realm-export.json` со всеми клиентами, `loginTheme`, IdP автоматически за
   ≤ 120 c. (Requirement 7.5)
2. **Существующий realm.** Изменения (новый `loginTheme`, `verifyEmail`, IdP,
   redirect URI) применяются вручную одним из способов:
   - через Admin Console (точечно), либо
   - через partial import / kcadm.sh с явным обновлением сущностей, либо
   - управляемое пересоздание realm при допустимости потери данных
     (`down -v`).
   (Requirement 7.4)
3. **Некорректный/отсутствующий JSON.** Импорт прерывается с сообщением об
   ошибке, частичный realm не создаётся. (Requirement 7.6)

## Correctness Properties

*Свойство (property) — это характеристика или поведение, которое должно
выполняться для всех допустимых исполнений системы; по сути, формальное
утверждение о том, что система обязана делать. Свойства служат мостом между
человекочитаемой спецификацией и машинно-проверяемыми гарантиями
корректности.*

Большая часть фичи носит инфраструктурно-конфигурационный и UI-характер
(hostname/прокси, деклар. конфигурация realm, вёрстка темы, встроенные потоки
Keycloak: логин/пароль, PKCE, redirect URI, JWKS, роли в токене, logout, Telegram,
регистрация как таковая) — эти пункты покрываются интеграционными, smoke- и
snapshot-тестами (см. Testing Strategy) и не формулируются как property-based
свойства, так как проверяют поведение самого Keycloak и его конфигурацию, а не наш
код.

Свойства ниже покрывают **наш собственный код в теме `kanji-flow`**: логику
видимости перехода к регистрации, сохранение значений формы регистрации при
ошибке валидации и функцию индикатора сложности пароля.

### Property 1: Видимость перехода к регистрации соответствует флагу realm

*Для любого* значения `registrationAllowed` наличие элемента перехода к
регистрации на странице входа темы `kanji-flow` равно значению этого флага
(виден тогда и только тогда, когда `registrationAllowed=true`).

**Validates: Requirements 6.1, 6.2**

### Property 2: Сохранение значений формы регистрации при ошибке валидации

*Для любого* набора введённых значений формы регистрации, приводящего к ошибке
валидации, повторно отображаемая форма содержит прежние значения всех
непарольных полей и пустые значения полей пароля и подтверждения пароля.

**Validates: Requirements 6.6**

### Property 3: Дискретные уровни индикатора сложности пароля

*Для любой* строки пароля функция оценки индикатора сложности возвращает ровно
один из не менее чем трёх дискретных уровней, и пароль, удовлетворяющий политике
пароля realm, получает уровень не ниже, чем пароль, ей не удовлетворяющий.

**Validates: Requirements 6.8**

## Error Handling

| Сценарий | Обработка | Требование |
|---|---|---|
| Запрос с недопустимым хостом (STRICT) | Keycloak не отдаёт страницу входа, ответ о недопустимом хосте | 1.5 |
| HTTP-запрос в production | Не обслуживается (listener выключен, прокси только HTTPS) | 1.7 |
| Неверные учётные данные | Отказ, токен не выпускается, обобщённое сообщение без указания поля | 3.3 |
| Превышение `failureFactor` | Временная блокировка до `maxFailureWaitSeconds`, без permanent lockout | 3.4 |
| Просроченная ссылка сброса пароля | Отказ, пароль не меняется, сообщение об истечении срока | 3.6 |
| Ошибка/таймаут Telegram (>60c) | Возврат на страницу входа с ошибкой, без токена и сессии | 4.4 |
| Отсутствует/plain `code_challenge` или метод != S256 | Отклонение запроса авторизации, код не выпускается | 5.3 |
| Несоответствие `code_verifier` при обмене | Отклонение обмена, токены не выпускаются | 5.4 |
| Незарегистрированный redirect URI | Отказ без редиректа | 5.6 |
| Logout | Завершение SSO-сессии + front-channel logout для `nuxt-web` | 5.7 |
| Ошибки валидации регистрации | Повторный показ формы, значения непарольных полей сохранены, поля пароля пусты, сообщение у поля | 6.6 |
| Отсутствует/битый `realm-export.json` | Импорт прерывается, частичный realm не создаётся, лог ошибки | 7.6 |

## Testing Strategy

Комбинированный подход: property-based тесты для универсальной логики нашего
кода в теме, integration — для встроенного поведения Keycloak и инфраструктуры,
smoke — для конфигурации и наличия артефактов, snapshot — для рендера темы.

### Property-based тесты

Применимы **только к нашему коду в теме** `kanji-flow`: функция оценки сложности
пароля (`password-strength.js`), логика видимости ссылки регистрации и логика
сохранения значений формы регистрации при ошибке валидации. Требования к
реализации:

- Использовать готовую PBT-библиотеку целевого языка (для JS/TypeScript —
  `fast-check`); **не** реализовывать PBT с нуля.
- Минимум **100 итераций** на каждый property-тест.
- Каждый тест помечается комментарием с ссылкой на свойство дизайна в формате:
  **Feature: custom-auth-page, Property {number}: {property_text}**.
- Каждое свойство корректности реализуется **одним** property-тестом.

Соответствие свойств тестам: Property 1 (видимость ссылки регистрации — генерация
булева флага `registrationAllowed`, проверка эквивалентности «виден ⇔ флаг»),
Property 2 (сохранение значений формы — генерация произвольных наборов значений
полей, приводящих к ошибке валидации; проверка сохранения непарольных значений и
очистки полей пароля), Property 3 (функция оценки сложности пароля — генерация
произвольных строк паролей; проверка возврата ровно одного из ≥3 дискретных
уровней и монотонности относительно соответствия политике).

### Unit / Example тесты

- Рендер обязательных полей формы регистрации (email, пароль, подтверждение) и
  ссылки «Уже есть аккаунт? Войти» (6.3, 6.4).
- Рендер формы входа: поле username/email, поле пароля, кнопка «показать пароль»
  (3.1).

### Integration тесты

Встроенное поведение Keycloak и инфраструктура (запуск контейнера):

- Отдача страницы входа на `auth.kanji-flow.online`, канонический хост в URL,
  issuer в `/.well-known/openid-configuration` (1.1, 1.2, 1.3).
- Отклонение недопустимого хоста и HTTP в prod (1.5, 1.7).
- Backchannel JWKS по внутреннему адресу (1.6).
- Логин по username/email, срок токена 300c, обобщённая ошибка, brute force,
  сброс пароля и просроченная ссылка (3.1–3.6).
- Telegram-поток: существующий/новый аккаунт, ошибка/таймаут (4.2–4.4).
- PKCE-энфорсмент и валидация redirect URI на стороне Keycloak: authorize без
  `code_challenge`/с неверным методом → отказ; несоответствие `code_verifier` →
  отказ обмена; чужой redirect URI → отказ; logout завершает SSO (5.2–5.7).
- Доступность JWKS по общедоступной конечной точке (5.8).
- Наличие `realm_access.roles` в выданном токене (5.9).
- Успешная регистрация создаёт учётную запись и запускает required actions (6.5).
- Импорт realm с чистой БД за ≤120c (7.5); применение к существующему realm
  (7.4); прерывание импорта при битом `realm-export.json` (7.6).

### Smoke / Snapshot тесты

- Smoke: наличие темы и provider-JAR в образе, значения в `theme.properties`
  (`parent`, `locales`), значения в `realm-export.json` (`loginTheme`, атрибуты
  клиентов `nuxt-web`/`nest-api`, IdP), плейсхолдеры секретов в `.env.example` и
  отсутствие реальных секретов в отслеживаемых файлах, конфигурация
  прокси/hostname (1.4, 2.1, 2.2, 2.3, 2.6, 4.5, 5.1, 5.10, 7.1, 7.2, 7.3).
- Snapshot/визуальные: соответствие рендера темы эталону, палитра `plum`, тёмная
  тема, единые брендированные элементы входа и регистрации (2.4, 2.5, 2.7, 2.8,
  4.1, 6.7).

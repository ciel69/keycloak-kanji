# Project Structure

## Directory Layout

```
keycloak-kanji/
├── .env                    # Environment variables (credentials, hostnames)
├── .env.example            # Template for environment variables
├── .git/                   # Git version control
├── .github/                # GitHub Actions workflows
│   └── workflows/
│       └── build-and-push.yml  # CI/CD for Docker image publishing
├── .kiro/                  # Kiro AI assistant configuration
│   └── steering/           # AI guidance documents
├── docker-compose.yml      # Service orchestration configuration
├── Dockerfile              # Multi-stage Keycloak build definition
├── README.md               # Project documentation
├── realm-export.json       # KanjiFlow realm auto-import configuration
├── providers/              # Custom Keycloak extensions (JAR files)
│   └── keycloak-telegram-identity-provider-1.0.3.jar
└── themes/                 # Custom Keycloak themes (optional)
```

## File Descriptions

### Root Configuration Files

- **`.env`**: Contains sensitive configuration (passwords, admin credentials, hostname). Never commit actual secrets.
- **`.env.example`**: Template for environment variables. Should be copied to `.env` for local development.
- **`docker-compose.yml`**: Defines two services (keycloak and postgres) with dependency management and health checks.
- **`Dockerfile`**: Multi-stage build extending official Keycloak image, includes realm auto-import and healthcheck.
- **`realm-export.json`**: KanjiFlow realm configuration with pre-configured OIDC clients (nuxt-web, nest-api).
- **`README.md`**: Project documentation with setup instructions and troubleshooting.

### Providers Directory

Contains JAR files for custom Keycloak identity providers and extensions. Files placed here are automatically deployed to `/opt/keycloak/providers/` in the container during build stage.

### GitHub Actions

- **`build-and-push.yml`**: Automatically builds and publishes Docker image to GitHub Container Registry on:
  - Push to `main` or `develop` branches
  - Creation of version tags (`v*`)
  - Image tagged with branch name, SHA, version, and `latest` (for main branch)

## Architecture

### Service Dependencies

1. **postgres**: PostgreSQL database (starts first, includes health check)
2. **keycloak**: Keycloak server (starts after postgres is healthy)

### Network Architecture

- Keycloak exposes port 8080 for HTTP traffic
- PostgreSQL runs internally (no external port exposure)
- Services communicate via Docker network using service names as hostnames

## Configuration Conventions

### Environment Variables

All environment-specific configuration uses the `.env` file pattern. Key variables:
- `POSTGRES_PASSWORD`: Database password
- `KEYCLOAK_ADMIN`: Admin username
- `KEYCLOAK_ADMIN_PASSWORD`: Admin password
- `KEYCLOAK_HOSTNAME`: Production domain name

Use `.env.example` as a template. Copy it to `.env` and customize for your environment.

### Realm Configuration

The `realm-export.json` file contains the KanjiFlow realm definition with:
- Pre-configured OIDC clients: `nuxt-web` (public, PKCE), `nest-api` (confidential)
- Default roles: `user`, `admin`
- Russian and English localization support
- Security settings: brute force protection, password reset enabled
- Redirect URIs for local (`localhost:3001`) and production (`kanji-flow.online`)

### Docker Configuration

- Container names use descriptive prefixes (`kc_` for Keycloak-related services)
- All services have `restart: always` for production resilience
- Health checks ensure proper startup ordering

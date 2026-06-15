# Technology Stack

## Base Technology

- **Keycloak**: Version 26.5.0.1 with Russian localization (playaru/keycloak-russian image)
- **PostgreSQL**: Version 16 for data persistence
- **Docker**: Containerized deployment using Docker Compose with multi-stage builds
- **GitHub Container Registry**: Automated image publishing via GitHub Actions

## Infrastructure

- **Container Runtime**: Docker with Docker Compose orchestration
- **Database**: PostgreSQL 16 with health checks
- **Reverse Proxy**: Edge proxy configuration for HTTPS termination
- **Custom Providers**: Telegram Identity Provider (JAR-based extension)
- **Realm Auto-Import**: KanjiFlow realm with pre-configured clients (nuxt-web, nest-api)
- **Healthcheck**: Built-in `/health/ready` endpoint with 60s startup grace period

## Environment Configuration

The project uses `.env` file for sensitive configuration:
- Database credentials
- Admin credentials  
- Hostname configuration

## Common Commands

### Start Services
```bash
docker-compose up -d
```

### Stop Services
```bash
docker-compose down
```

### View Logs
```bash
docker-compose logs -f keycloak
docker-compose logs -f postgres
```

### Rebuild After Changes
```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Check Service Health
```bash
docker-compose ps
```

### Access Keycloak Admin Console
- Local: http://localhost:8080
- Production: https://keycloak.kanji-flow.online

### Export Realm Configuration
```bash
docker exec -it keycloak /opt/keycloak/bin/kc.sh export --dir /tmp/export --realm KanjiFlow
docker cp keycloak:/tmp/export/KanjiFlow-realm.json ./realm-export.json
```

### Pull Published Image
```bash
docker pull ghcr.io/<your-org>/kanji-flow-keycloak:latest
```

## Custom Extensions

Custom Keycloak providers (JAR files) are placed in the `providers/` directory and automatically copied into the container during build.

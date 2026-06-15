# Deployment and CI/CD

This document describes the deployment workflow, CI/CD pipeline, and integration with the kanji-flow-infra repository.

## CI/CD Pipeline

### GitHub Actions Workflow

The project uses GitHub Actions to automatically build and publish Docker images to GitHub Container Registry (ghcr.io).

**Workflow file**: `.github/workflows/build-and-push.yml`

**Triggers**:
- Push to `main` branch → builds `latest` tag
- Push to `develop` branch → builds `develop` tag
- Push to any branch → builds `<branch-name>` tag
- Git tags matching `v*` → builds version tags (e.g., `v1.0.0`, `v1`, `v1.0`)
- Pull requests → builds PR-specific tags

**Image tags created**:
```
ghcr.io/<org>/kanji-flow-keycloak:latest      # main branch only
ghcr.io/<org>/kanji-flow-keycloak:develop     # develop branch
ghcr.io/<org>/kanji-flow-keycloak:v1.0.0      # version tags
ghcr.io/<org>/kanji-flow-keycloak:v1.0        # major.minor
ghcr.io/<org>/kanji-flow-keycloak:v1          # major
ghcr.io/<org>/kanji-flow-keycloak:main-abc123 # branch + SHA
```

### Build Process

The Dockerfile uses a multi-stage build:

1. **Builder stage** (`FROM playaru/keycloak-russian:26.5.0.1 AS builder`)
   - Uses Russian-localized Keycloak base image
   - Copies custom providers from `providers/` directory
   - Copies realm configuration from `realm-export.json` for auto-import
   - Runs `kc.sh build --db=postgres` to optimize for PostgreSQL

2. **Runtime stage** (`FROM playaru/keycloak-russian:26.5.0.1 AS runtime`)
   - Copies optimized build from builder stage
   - Includes Russian localization
   - Runs as non-privileged user (UID 1000)
   - Exposes port 8080
   - Includes healthcheck on `/health/ready` endpoint

### Healthcheck Configuration

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/health/ready || exit 1
```

- **Interval**: 30 seconds between checks
- **Timeout**: 3 seconds per check
- **Start period**: 60 seconds grace period for initialization
- **Retries**: 3 consecutive failures before marking unhealthy

## Local Development

### Quick Start

```bash
# Clone repository
git clone <repo-url>
cd keycloak-kanji

# Create .env from template
cp .env.example .env

# Edit .env if needed (defaults are fine for local dev)
# nano .env

# Start services
docker-compose up -d

# Check logs
docker-compose logs -f keycloak

# Wait for "Keycloak 26.0 started" message
```

**Access**:
- Keycloak Admin Console: http://localhost:8080
- Credentials: `admin` / `admin` (from `.env`)

### Development Workflow

1. **Make changes** to providers or realm configuration
2. **Rebuild** the container:
   ```bash
   docker-compose down
   docker-compose build --no-cache
   docker-compose up -d
   ```
3. **Verify** changes in Admin Console or via API

### Testing Realm Import

The `realm-export.json` is automatically imported on first startup. To test changes:

```bash
# Remove volumes to reset database
docker-compose down -v

# Restart (will re-import realm)
docker-compose up -d

# Check import logs
docker-compose logs keycloak | grep -i import
```

## Integration with kanji-flow-infra

### Repository Structure

The Keycloak service integrates with the main infrastructure repository:

```
kanji-flow-infra/
├── local/
│   ├── docker-compose.local.yml   # References keycloak image
│   ├── .env.local                  # Local secrets (not in git)
│   └── postgres-init.sql           # Creates keycloak database
└── env/
    └── keycloak.env.example        # Template for keycloak env vars
```

### Using Published Images

In `kanji-flow-infra/local/docker-compose.local.yml`:

```yaml
services:
  keycloak:
    image: ghcr.io/<your-org>/kanji-flow-keycloak:latest
    container_name: kc_keycloak
    restart: always
    env_file:
      - ../env/keycloak.env
    environment:
      KC_DB: postgres
      KC_DB_URL: jdbc:postgresql://postgres:5432/keycloak
      KC_DB_USERNAME: keycloak
      KC_DB_PASSWORD: ${POSTGRES_PASSWORD}
    command: start --import-realm
    ports:
      - "8080:8080"
    depends_on:
      postgres:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health/ready"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 60s
```

### Using Local Build

For development with local changes:

```yaml
services:
  keycloak:
    build:
      context: ../keycloak-kanji
      dockerfile: Dockerfile
    # ... rest of configuration
```

### Environment Variables

The `env/keycloak.env.example` should contain:

```bash
# Database
KC_DB=postgres
KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=${POSTGRES_PASSWORD}

# Admin
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=${KEYCLOAK_ADMIN_PASSWORD}

# Local development
KC_HTTP_ENABLED=true
KC_HOSTNAME_PORT=8080
KC_HOSTNAME_STRICT=false
KC_HOSTNAME_STRICT_BACKCHANNEL=false

# Production (commented out for local)
# KC_HOSTNAME=keycloak.kanji-flow.online
# KC_HOSTNAME_URL=https://keycloak.kanji-flow.online
# KC_PROXY=edge
# KC_PROXY_HEADERS=xforwarded
```

## Production Deployment

### Prerequisites

1. Published Docker image in ghcr.io
2. PostgreSQL database for Keycloak
3. Reverse proxy with HTTPS (nginx, traefik, caddy)
4. Domain name pointing to server

### Production Environment Variables

```bash
# Database
KC_DB=postgres
KC_DB_URL=jdbc:postgresql://postgres:5432/keycloak
KC_DB_USERNAME=keycloak
KC_DB_PASSWORD=<strong-password>

# Admin
KEYCLOAK_ADMIN=admin
KEYCLOAK_ADMIN_PASSWORD=<strong-password>

# Production hostname
KC_HOSTNAME=keycloak.kanji-flow.online
KC_HOSTNAME_URL=https://keycloak.kanji-flow.online
KC_HOSTNAME_ADMIN_URL=https://keycloak.kanji-flow.online

# Proxy configuration (for HTTPS termination)
KC_PROXY=edge
KC_PROXY_HEADERS=xforwarded

# Security
KC_HOSTNAME_STRICT=true
KC_HOSTNAME_STRICT_BACKCHANNEL=true
KC_HTTP_ENABLED=false  # Only HTTPS in production
```

### Deployment Steps

1. **Set up reverse proxy** with HTTPS certificate (Let's Encrypt)
2. **Configure proxy** to forward to Keycloak port 8080:
   ```nginx
   server {
       listen 443 ssl http2;
       server_name keycloak.kanji-flow.online;
       
       ssl_certificate /etc/letsencrypt/live/keycloak.kanji-flow.online/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/keycloak.kanji-flow.online/privkey.pem;
       
       location / {
           proxy_pass http://keycloak:8080;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
           proxy_set_header X-Forwarded-Proto $scheme;
           proxy_set_header X-Forwarded-Port $server_port;
       }
   }
   ```
3. **Deploy** using docker-compose or Kamal
4. **Verify** healthcheck: `curl https://keycloak.kanji-flow.online/health/ready`
5. **Configure clients** with production redirect URIs

### Kamal Deployment (if using kamal-deploy)

In `config/deploy.yml`:

```yaml
service: kanji-flow-keycloak
image: ghcr.io/<your-org>/kanji-flow-keycloak

servers:
  web:
    hosts:
      - keycloak.kanji-flow.online
    labels:
      traefik.http.routers.keycloak.rule: Host(`keycloak.kanji-flow.online`)
      traefik.http.services.keycloak.loadbalancer.server.port: 8080

env:
  clear:
    KC_DB: postgres
    KC_PROXY: edge
  secret:
    - KC_DB_PASSWORD
    - KEYCLOAK_ADMIN_PASSWORD

healthcheck:
  path: /health/ready
  port: 8080
  interval: 30s
  timeout: 3s
```

## Realm Configuration Management

### Exporting Realm

To export current realm configuration:

```bash
# Export from running container
docker exec -it keycloak /opt/keycloak/bin/kc.sh export \
  --dir /tmp/export \
  --realm KanjiFlow \
  --users skip

# Copy to host
docker cp keycloak:/tmp/export/KanjiFlow-realm.json ./realm-export.json
```

**Note**: Use `--users skip` to exclude user data from export.

### Importing Realm Changes

1. Update `realm-export.json` with desired changes
2. Rebuild Docker image:
   ```bash
   docker-compose build --no-cache
   ```
3. Deploy new image
4. Realm will be updated on container restart

**Important**: Existing realm data is preserved. Only new settings from JSON are applied.

### Version Control

Always commit `realm-export.json` changes:

```bash
git add realm-export.json
git commit -m "feat: add new OIDC client for mobile app"
git push origin main
```

This ensures realm configuration is tracked and reproducible.

## Client Configuration

### Pre-configured Clients

The `realm-export.json` includes two clients:

#### 1. nuxt-web (Public Client)

```json
{
  "clientId": "nuxt-web",
  "publicClient": true,
  "standardFlowEnabled": true,
  "directAccessGrantsEnabled": false,
  "redirectUris": [
    "http://localhost:3001/*",
    "https://kanji-flow.online/*"
  ],
  "webOrigins": ["+"],
  "attributes": {
    "pkce.code.challenge.method": "S256"
  }
}
```

**Usage**: Frontend Nuxt.js application with PKCE flow.

#### 2. nest-api (Confidential Client)

```json
{
  "clientId": "nest-api",
  "publicClient": false,
  "standardFlowEnabled": true,
  "serviceAccountsEnabled": true,
  "redirectUris": ["*"]
}
```

**Usage**: Backend NestJS API for token validation and service account.

### Adding New Clients

1. **Via Admin Console** (recommended for development):
   - Login to Admin Console
   - Select KanjiFlow realm
   - Clients → Create client
   - Configure client settings
   - Export realm to save changes

2. **Via realm-export.json** (for production):
   - Add client configuration to `clients` array
   - Rebuild and deploy

## Monitoring and Debugging

### Health Check Endpoint

```bash
# Check if Keycloak is ready
curl http://localhost:8080/health/ready

# Check if Keycloak is alive
curl http://localhost:8080/health/live

# Full health check
curl http://localhost:8080/health
```

### Logs

```bash
# Follow all logs
docker-compose logs -f keycloak

# Search for errors
docker-compose logs keycloak | grep -i error

# Check startup
docker-compose logs keycloak | grep "Keycloak.*started"

# Check realm import
docker-compose logs keycloak | grep -i import
```

### Common Issues

#### Realm not importing

**Symptom**: KanjiFlow realm doesn't exist after startup

**Solution**:
```bash
# Check if realm-export.json is in container
docker exec keycloak ls -la /opt/keycloak/data/import/

# Check import logs
docker-compose logs keycloak | grep import

# Force re-import by removing volume
docker-compose down -v
docker-compose up -d
```

#### Database connection failed

**Symptom**: `Connection refused` errors in logs

**Solution**:
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Check healthcheck
docker-compose exec postgres pg_isready -U keycloak

# Verify connection string in docker-compose.yml
```

#### Healthcheck failing

**Symptom**: Container keeps restarting

**Solution**:
```bash
# Check logs for startup errors
docker-compose logs keycloak | tail -100

# Increase start_period if slow startup
# Edit docker-compose.yml healthcheck start_period
```

## Security Best Practices

### Production Checklist

- [ ] Change default admin password
- [ ] Use strong database password
- [ ] Enable HTTPS only (`KC_HTTP_ENABLED=false`)
- [ ] Set strict hostname (`KC_HOSTNAME_STRICT=true`)
- [ ] Configure proper CORS origins (not `*`)
- [ ] Enable brute force protection (default enabled in realm-export.json)
- [ ] Review client redirect URIs (no wildcards in production)
- [ ] Enable audit logging
- [ ] Regular backups of PostgreSQL database
- [ ] Keep Keycloak version updated
- [ ] Review and remove unused clients/realms

### Secrets Management

**Never commit** `.env` file with real secrets.

Use environment-specific secrets:
- Local: `.env` (in .gitignore)
- CI/CD: GitHub Secrets
- Production: Secure vault (HashiCorp Vault, AWS Secrets Manager)

## Troubleshooting

### Reset Everything

```bash
# Stop and remove all containers and volumes
docker-compose down -v

# Remove images to force rebuild
docker rmi $(docker images 'keycloak-kanji*' -q)

# Start fresh
docker-compose build --no-cache
docker-compose up -d
```

### Access Container Shell

```bash
# Access Keycloak container
docker-compose exec keycloak /bin/bash

# Check files
ls -la /opt/keycloak/data/import/
ls -la /opt/keycloak/providers/

# Check Keycloak CLI
/opt/keycloak/bin/kc.sh --help
```

### Database Access

```bash
# Access PostgreSQL
docker-compose exec postgres psql -U keycloak

# List tables
\dt

# Check realm
SELECT * FROM realm WHERE name = 'KanjiFlow';
```

## References

- [Keycloak Server Configuration](https://www.keycloak.org/server/configuration)
- [Keycloak in Containers](https://www.keycloak.org/server/containers)
- [Keycloak Realm Export/Import](https://www.keycloak.org/server/importExport)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)

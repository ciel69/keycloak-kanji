# Keycloak Customization Guidelines

This document provides guidance for customizing Keycloak for the Kanji Flow project, including theme development, form customization, and provider extensions.

## Theme Development

### Theme Structure

Keycloak themes are organized in the `themes/` directory with the following structure:

```
themes/
└── kanji-flow/              # Custom theme name
    ├── login/               # Login page customization
    │   ├── theme.properties
    │   ├── messages/
    │   │   ├── messages_en.properties
    │   │   └── messages_ru.properties
    │   ├── resources/
    │   │   ├── css/
    │   │   ├── js/
    │   │   └── img/
    │   └── *.ftl            # FreeMarker templates
    ├── account/             # Account console customization
    ├── admin/               # Admin console customization
    └── email/               # Email template customization
```

### Development Workflow

#### Enable Development Mode

For theme development, disable caching to see changes immediately:

```bash
# In docker-compose.yml, add to keycloak command:
command: start --spi-theme-static-max-age=-1 --spi-theme-cache-themes=false --spi-theme-cache-templates=false
```

**IMPORTANT**: Re-enable caching in production for performance.

#### Creating a Custom Theme

1. Create theme directory structure in `themes/kanji-flow/login/`
2. Create `theme.properties` with parent theme:

```properties
parent=keycloak
import=common/keycloak
styles=css/login.css css/custom.css
scripts=js/custom.js
locales=en,ru
```

3. Copy theme directory to container via Dockerfile:

```dockerfile
FROM playaru/keycloak-russian:26.5.0.1

# Copy custom theme
COPY themes/ /opt/keycloak/themes/

# Copy custom providers
COPY providers/ /opt/keycloak/providers/

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
```

4. Rebuild container to apply changes:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Theme Configuration

#### Extending vs Overriding

- **Extend** the `keycloak` or `base` theme to leverage existing functionality
- **Override** only specific resources (CSS, templates, messages) as needed
- Avoid copying entire templates unless necessary (reduces maintenance burden during upgrades)

#### CSS Customization

Add custom styles without overriding templates:

```css
/* themes/kanji-flow/login/resources/css/custom.css */

/* Custom branding colors */
.login-pf body {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.card-pf {
    border-radius: 12px;
    box-shadow: 0 4px 20px rgba(0,0,0,0.1);
}

/* Custom button styles */
#kc-form-buttons .btn-primary {
    background-color: #667eea;
    border-color: #667eea;
}
```

#### JavaScript Customization

Add custom behavior:

```javascript
// themes/kanji-flow/login/resources/js/custom.js

document.addEventListener('DOMContentLoaded', function() {
    // Add custom form validation
    // Add analytics tracking
    // Add custom UI interactions
});
```

### FreeMarker Template Customization

#### When to Override Templates

Only override templates when:
- CSS/JavaScript changes are insufficient
- Need to add/remove form fields
- Need to change page structure significantly

#### Template Override Process

1. Copy base template from `themes/base/login/<template>.ftl`
2. Place in `themes/kanji-flow/login/<template>.ftl`
3. Make minimal necessary changes
4. Document changes for future upgrades

**Common templates to customize:**
- `login.ftl` - Main login form
- `register.ftl` - Registration form
- `login-reset-password.ftl` - Password reset
- `login-otp.ftl` - Two-factor authentication
- `template.ftl` - Main layout template
- `footer.ftl` - Custom footer content

#### Template Best Practices

```ftl
<#-- Always import the layout template -->
<#import "template.ftl" as layout>

<#-- Use Keycloak's built-in macros and variables -->
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password')>
    
    <#-- Custom content here -->
    <div id="kc-form">
        <#-- Use ${url.*} for URLs -->
        <#-- Use ${msg("key")} for i18n messages -->
        <#-- Use ${realm.*} for realm properties -->
    </div>
    
</@layout.registrationLayout>
```

### Internationalization (i18n)

#### Message Bundle Structure

Create message files for supported locales:

```properties
# themes/kanji-flow/login/messages/messages_en.properties
loginTitle=Sign in to Kanji Flow
loginWelcome=Welcome back! Please sign in to continue.

# themes/kanji-flow/login/messages/messages_ru.properties
loginTitle=Войти в Kanji Flow
loginWelcome=Добро пожаловать! Войдите, чтобы продолжить.
```

#### Using Messages in Templates

```ftl
<h1>${msg("loginTitle")}</h1>
<p>${msg("loginWelcome")}</p>
```

### Email Template Customization

Customize email subjects and bodies:

```properties
# themes/kanji-flow/email/messages/messages_en.properties
passwordResetSubject=Kanji Flow - Reset Your Password
passwordResetBody=Click here to reset: {0}
passwordResetBodyHtml=<div><a href="{0}">Reset Password</a></div>
```

**IMPORTANT**: Use `${url.resourcesCommonUrl}` (not `resourcesCommonPath`) for images in emails - email clients require absolute URLs.

## Custom Providers (SPI Extensions)

### Provider Types

Keycloak supports custom providers through Service Provider Interface (SPI):

- **Authenticator** - Custom authentication mechanisms
- **Identity Provider** - Social login integrations (e.g., Telegram provider)
- **User Storage** - External user databases
- **Event Listener** - Audit logging and analytics
- **Theme Resource** - Dynamic theme resources
- **Protocol Mapper** - Token customization

### Provider Deployment

1. Build provider as JAR file with dependencies
2. Place in `providers/` directory
3. Rebuild container:

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### Provider Structure

```
custom-provider/
├── src/main/java/
│   └── com/kanjiflow/keycloak/
│       ├── MyAuthenticatorFactory.java
│       └── MyAuthenticator.java
├── src/main/resources/
│   └── META-INF/services/
│       └── org.keycloak.authentication.AuthenticatorFactory
└── pom.xml
```

### Custom Authenticator Example

```java
// MyAuthenticatorFactory.java
public class MyAuthenticatorFactory implements AuthenticatorFactory {
    public static final String PROVIDER_ID = "my-authenticator";
    
    @Override
    public String getId() {
        return PROVIDER_ID;
    }
    
    @Override
    public String getDisplayType() {
        return "My Custom Authenticator";
    }
    
    @Override
    public Authenticator create(KeycloakSession session) {
        return new MyAuthenticator();
    }
}
```

### Provider Registration

Create file `META-INF/services/org.keycloak.authentication.AuthenticatorFactory`:

```
com.kanjiflow.keycloak.MyAuthenticatorFactory
```

## Keycloak Configuration

### Environment Variables

Use environment variables for configuration (defined in `.env` and `docker-compose.yml`):

- `KC_HOSTNAME` - Production hostname
- `KC_HOSTNAME_URL` - Full URL with HTTPS
- `KC_PROXY` - Proxy mode (edge for HTTPS termination)
- `KC_PROXY_HEADERS` - Enable X-Forwarded headers
- `KC_HTTP_ENABLED` - Enable HTTP (for development)
- `KC_DB_*` - Database configuration

### Admin Console Configuration

After deployment, configure through Admin Console:

1. **Realm Settings → Themes**
   - Login Theme: `kanji-flow`
   - Account Theme: `kanji-flow`
   - Email Theme: `kanji-flow`
   - Dark mode: Enable/disable as needed

2. **Authentication → Flows**
   - Configure authentication flows
   - Add custom authenticators
   - Set required actions

3. **Identity Providers**
   - Configure Telegram provider
   - Set display names and icons
   - Configure attribute mappings

### Realm Export/Import

For reproducible configuration, export realm settings:

```bash
docker exec -it keycloak /opt/keycloak/bin/kc.sh export --dir /tmp/export --realm kanji-flow
```

Store exported JSON in version control for disaster recovery.

## Testing Strategy

### Local Testing

1. Start services with development settings
2. Make theme changes
3. Refresh browser to see changes (no rebuild needed with caching disabled)
4. Test all authentication flows:
   - Login
   - Registration
   - Password reset
   - Two-factor authentication
   - Social login (Telegram)

### Cross-Browser Testing

Test login forms in:
- Chrome/Edge
- Firefox
- Safari
- Mobile browsers

### Email Testing

Use email testing service or local SMTP server to verify email templates.

## Security Considerations

### Theme Security

- **Never include sensitive data** in theme files
- Validate all user input in custom JavaScript
- Use CSP-compliant scripts
- Escape user-generated content in templates

### Provider Security

- Validate all external data
- Use secure communication protocols
- Follow principle of least privilege
- Log security-relevant events

### Production Checklist

- [ ] Theme caching enabled
- [ ] HTTPS enforced (`KC_PROXY=edge`)
- [ ] Strong admin credentials
- [ ] Database credentials secured
- [ ] Custom providers from trusted sources only
- [ ] Regular Keycloak updates
- [ ] Audit logs enabled

## Troubleshooting

### Theme Not Appearing

1. Check theme name in Admin Console matches directory name
2. Verify `theme.properties` exists
3. Check container logs: `docker-compose logs -f keycloak`
4. Rebuild container if adding new themes
5. Clear browser cache

### Template Errors

1. Check FreeMarker syntax
2. Review container logs for stack traces
3. Verify all required variables are available
4. Test with minimal template first

### Provider Not Loading

1. Check JAR is in `providers/` directory
2. Verify `META-INF/services` registration file
3. Check for class loading errors in logs
4. Ensure all dependencies are included in JAR

## Resources

- [Keycloak Official Theme Documentation](https://www.keycloak.org/ui-customization/themes)
- [FreeMarker Manual](https://freemarker.apache.org/docs/index.html)
- [Keycloak Server Development](https://www.keycloak.org/docs/latest/server_development/)
- Base theme templates: `themes/base/` in Keycloak distribution
- Default keycloak theme: `themes/keycloak/` for reference

## Quick Reference

### Rebuild After Theme Changes

```bash
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

### View Theme in Action

- Local: http://localhost:8080/realms/kanji-flow/account
- Production: https://keycloak.kanji-flow.online/realms/kanji-flow/account

### Common File Paths

- Themes: `/opt/keycloak/themes/` (in container)
- Providers: `/opt/keycloak/providers/` (in container)
- Logs: `docker-compose logs -f keycloak`

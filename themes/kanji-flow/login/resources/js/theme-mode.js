/**
 * Theme mode initialization — dark/light theme detection and application.
 *
 * Reproduces the logic from the Nuxt frontend (front_tmp/auth/login/index.html):
 * reads `vueuse-color-scheme` from localStorage, falls back to
 * `prefers-color-scheme: dark` media query, and toggles the `dark` class
 * on <html> accordingly. This ensures Keycloak login pages respect the same
 * dark mode preference as the Nuxt frontend.
 *
 * Cross-origin sync: the Nuxt app (kanji-flow.online) and Keycloak
 * (keycloak.kanji-flow.online) are different origins, so localStorage is
 * NOT shared between them. To carry the user's theme choice across the
 * redirect to the login page, the Nuxt app appends a `?theme=dark|light`
 * query param to the Keycloak authorization URL. If present, it takes
 * priority over the (origin-local) localStorage value and is persisted so
 * subsequent Keycloak-internal pages (register, reset-password, OTP, etc.)
 * within the same auth flow keep the same theme even though they don't
 * carry the query param themselves.
 *
 * Note: locale is handled separately via the standard OIDC `ui_locales`
 * param (not `kc_locale` — see LocaleUtil.processLocaleParam in Keycloak,
 * which isn't invoked on the initial /auth request for the standard code
 * flow, only ui_locales is read at that point via CLIENT_REQUEST_LOCALE).
 */
(function () {
  var queryTheme = new URLSearchParams(window.location.search).get('theme');
  var stored;

  if (queryTheme === 'dark' || queryTheme === 'light') {
    stored = queryTheme;
    localStorage.setItem('vueuse-color-scheme', stored);
  } else {
    stored = localStorage.getItem('vueuse-color-scheme');
  }

  var isDark = stored === 'dark' || (stored !== 'light' && window.matchMedia('(prefers-color-scheme: dark)').matches);
  document.documentElement.classList[isDark ? 'add' : 'remove']('dark');
})();

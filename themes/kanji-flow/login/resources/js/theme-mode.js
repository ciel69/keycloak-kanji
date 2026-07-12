/**
 * Theme mode initialization — dark/light theme detection and application.
 *
 * Reproduces the logic from the Nuxt frontend (front_tmp/auth/login/index.html):
 * reads `vueuse-color-scheme` from localStorage, falls back to
 * `prefers-color-scheme: dark` media query, and toggles the `dark` class
 * on <html> accordingly. This ensures Keycloak login pages respect the same
 * dark mode preference as the Nuxt frontend.
 */
(function () {
  var stored = localStorage.getItem('vueuse-color-scheme');
  var isDark = stored === 'dark' || (stored !== 'light' && window.matchMedia('(prefers-color-scheme: dark)').matches);
  document.documentElement.classList[isDark ? 'add' : 'remove']('dark');
})();

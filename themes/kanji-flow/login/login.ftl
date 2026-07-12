<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','password'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-gray-900 dark:text-white">${msg("loginTitle","Вход в систему")}</h1>

<div class="space-y-4">
  <form class="space-y-4" action="${url.loginAction}" method="post">
    <!-- Username/Email field -->
    <div>
      <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("usernameOrEmail","Email")}
      </label>
      <input id="username" name="username" value="${(login.username!'')}" type="text" autocomplete="username"
             class="mt-1 block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
             <#if messagesPerField.existsError('username')>aria-invalid="true"</#if>
             autofocus>
      <#if messagesPerField.existsError('username')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('username'))?no_esc}</p>
      </#if>
    </div>

    <!-- Password field with toggle button -->
    <div>
      <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("password","Пароль")}
      </label>
      <div class="relative mt-1">
        <input id="password" name="password" type="password" autocomplete="current-password"
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
               <#if messagesPerField.existsError('password')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute top-1/2 -translate-y-1/2 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <#if messagesPerField.existsError('password')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('password'))?no_esc}</p>
      </#if>
    </div>

    <!-- Forgot password link -->
    <#if realm.resetPasswordAllowed>
      <div class="text-right">
        <a href="${url.loginResetCredentialsUrl}" class="text-xs text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300">
          ${msg("doForgotPassword","Забыли пароль?")}
        </a>
      </div>
    </#if>

    <!-- Submit button -->
    <button type="submit" name="login" id="kc-login"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors disabled:opacity-50 dark:focus:ring-offset-gray-800">
      ${msg("doLogIn","Войти")}
    </button>
  </form>

  <!-- Registration link (visible iff registrationAllowed) -->
  <#if realm.registrationAllowed>
    <div class="text-center" id="kc-registration">
      <a href="${url.registrationUrl}" class="min-h-[44px] inline-flex items-center text-sm text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-800">
        ${msg("noAccount","Нет аккаунта? Зарегистрироваться")}
      </a>
    </div>
  </#if>

  <!-- Social providers -->
  <#if social.providers?? && social.providers?size gt 0>
    <!-- Divider "Или" -->
    <div class="relative">
      <div class="absolute inset-0 flex items-center">
        <div class="w-full border-t border-gray-300 dark:border-gray-700"></div>
      </div>
      <div class="relative flex justify-center text-sm">
        <span class="px-2 bg-white text-gray-500 dark:bg-gray-800 dark:text-gray-400">${msg("or","Или")}</span>
      </div>
    </div>

    <!-- Provider buttons grid -->
    <div id="kc-social-providers" class="grid grid-cols-2 gap-4">
      <#list social.providers as p>
        <a href="${p.loginUrl}" class="auth-provider-btn ${p.alias} light dark:hidden" aria-label="${p.displayName}">
          <img src="${url.resourcesPath}/img/icons/${p.alias}.svg" alt="" class="w-5 h-5" onerror="this.style.display='none'">
          <span class="ml-2">${p.displayName}</span>
        </a>
        <a href="${p.loginUrl}" class="auth-provider-btn ${p.alias} dark hidden dark:inline-flex" aria-label="${p.displayName}">
          <img src="${url.resourcesPath}/img/icons/${p.alias}.svg" alt="" class="w-5 h-5" onerror="this.style.display='none'">
          <span class="ml-2">${p.displayName}</span>
        </a>
      </#list>
    </div>
  </#if>
</div>

</@layout.registrationLayout>

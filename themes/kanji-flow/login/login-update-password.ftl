<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-new','password-confirm'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-gray-900 dark:text-white">${msg("updatePasswordTitle","Новый пароль")}</h1>

<div class="space-y-4">
  <form class="space-y-4" action="${url.loginAction}" method="post">
    <input type="hidden" id="username" name="username" value="${username}" autocomplete="username" readonly>

    <!-- New password -->
    <div>
      <label for="password-new" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("passwordNew","Новый пароль")} <span class="text-red-500">*</span>
      </label>
      <div class="relative mt-1">
        <input id="password-new" name="password-new" type="password" required autocomplete="new-password" autofocus
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
               <#if messagesPerField.existsError('password-new')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute inset-y-0 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <#if messagesPerField.existsError('password-new')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('password-new'))?no_esc}</p>
      </#if>
    </div>

    <!-- Confirm new password -->
    <div>
      <label for="password-confirm" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("passwordConfirm","Подтвердите пароль")} <span class="text-red-500">*</span>
      </label>
      <div class="relative mt-1">
        <input id="password-confirm" name="password-confirm" type="password" required autocomplete="new-password"
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
               <#if messagesPerField.existsError('password-confirm')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute inset-y-0 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <#if messagesPerField.existsError('password-confirm')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</p>
      </#if>
    </div>

    <!-- Logout other sessions option (standard Keycloak feature) -->
    <#if isAppInitiatedAction??>
    <div class="flex items-center gap-2">
      <input type="checkbox" id="logout-sessions" name="logout-sessions" value="on" checked
             class="rounded border-gray-300 text-plum-600 focus:ring-plum-500 dark:border-gray-600 dark:bg-gray-700">
      <label for="logout-sessions" class="text-sm text-gray-700 dark:text-gray-300">
        ${msg("logoutOtherSessions","Выйти из других сессий")}
      </label>
    </div>
    </#if>

    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors dark:focus:ring-offset-gray-800">
      ${msg("doSubmit","Сохранить")}
    </button>
  </form>
</div>

</@layout.registrationLayout>

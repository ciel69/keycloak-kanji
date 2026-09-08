<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('password','password-new','password-confirm'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-foreground">${msg("updatePasswordTitle","Новый пароль")}</h1>

<div class="space-y-4">
  <form class="space-y-4" action="${url.loginAction}" method="post">
    <input type="hidden" id="username" name="username" value="${username}" autocomplete="username" readonly>

    <!-- New password -->
    <div>
      <label for="password-new" class="block text-sm font-medium text-muted">
        ${msg("passwordNew","Новый пароль")} <span class="text-red-500">*</span>
      </label>
      <div class="relative mt-1">
        <input id="password-new" name="password-new" type="password" required autocomplete="new-password" autofocus
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-surface text-foreground border-border focus:border-plum-500"
               <#if messagesPerField.existsError('password-new')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute top-1/2 -translate-y-1/2 right-0 flex items-center px-3 text-faint hover:text-muted" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <#if messagesPerField.existsError('password-new')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('password-new'))?no_esc}</p>
      </#if>
    </div>

    <!-- Confirm new password -->
    <div>
      <label for="password-confirm" class="block text-sm font-medium text-muted">
        ${msg("passwordConfirm","Подтвердите пароль")} <span class="text-red-500">*</span>
      </label>
      <div class="relative mt-1">
        <input id="password-confirm" name="password-confirm" type="password" required autocomplete="new-password"
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-surface text-foreground border-border focus:border-plum-500"
               <#if messagesPerField.existsError('password-confirm')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute top-1/2 -translate-y-1/2 right-0 flex items-center px-3 text-faint hover:text-muted" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
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
             class="rounded border-border text-plum-600 focus:ring-plum-500 bg-surface">
      <label for="logout-sessions" class="text-sm text-muted">
        ${msg("logoutOtherSessions","Выйти из других сессий")}
      </label>
    </div>
    </#if>

    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors focus:ring-offset-surface">
      ${msg("doSubmit","Сохранить")}
    </button>
  </form>
</div>

</@layout.registrationLayout>

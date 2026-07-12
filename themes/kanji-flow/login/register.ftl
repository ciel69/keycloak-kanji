<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','email','password','password-confirm'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-gray-900 dark:text-white">${msg("registerTitle","Регистрация")}</h1>

<div class="space-y-4">
  <form class="space-y-4" action="${url.registrationAction}" method="post">
    <!-- Username (required) -->
    <div>
      <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">${msg("username","Имя пользователя")} <span class="text-red-500">*</span></label>
      <input id="username" name="username" value="${(register.formData.username!'')}" type="text" required autocomplete="username"
             class="mt-1 block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
             <#if messagesPerField.existsError('username')>aria-invalid="true"</#if>>
      <#if messagesPerField.existsError('username')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('username'))?no_esc}</p>
      </#if>
    </div>

    <!-- Email (required) -->
    <div>
      <label for="email" class="block text-sm font-medium text-gray-700 dark:text-gray-300">${msg("email","Email")} <span class="text-red-500">*</span></label>
      <input id="email" name="email" value="${(register.formData.email!'')}" type="email" required autocomplete="email"
             class="mt-1 block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
             <#if messagesPerField.existsError('email')>aria-invalid="true"</#if>>
      <#if messagesPerField.existsError('email')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('email'))?no_esc}</p>
      </#if>
    </div>

    <!-- Password (required) with strength indicator -->
    <div>
      <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">${msg("password","Пароль")} <span class="text-red-500">*</span></label>
      <div class="relative mt-1">
        <input id="password" name="password" type="password" required autocomplete="new-password"
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
               <#if messagesPerField.existsError('password')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute top-1/2 -translate-y-1/2 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <!-- password-strength.js will inject indicator here -->
      <#if messagesPerField.existsError('password')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('password'))?no_esc}</p>
      </#if>
    </div>

    <!-- Confirm password (required) -->
    <div>
      <label for="password-confirm" class="block text-sm font-medium text-gray-700 dark:text-gray-300">${msg("passwordConfirm","Подтвердите пароль")} <span class="text-red-500">*</span></label>
      <div class="relative mt-1">
        <input id="password-confirm" name="password-confirm" type="password" required autocomplete="new-password"
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
               <#if messagesPerField.existsError('password-confirm')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute top-1/2 -translate-y-1/2 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <#if messagesPerField.existsError('password-confirm')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('password-confirm'))?no_esc}</p>
      </#if>
    </div>

    <!-- Submit -->
    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors disabled:opacity-50 dark:focus:ring-offset-gray-800">
      ${msg("doRegister","Зарегистрироваться")}
    </button>
  </form>

  <!-- Link back to login -->
  <div class="text-center">
    <a href="${url.loginUrl}" class="min-h-[44px] inline-flex items-center text-sm text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-800">
      ${msg("backToLogin","Уже есть аккаунт? Войти")}
    </a>
  </div>
</div>

<script src="${url.resourcesPath}/js/password-strength.js" type="text/javascript"></script>
</@layout.registrationLayout>

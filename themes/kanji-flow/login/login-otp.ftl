<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('totp'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-gray-900 dark:text-white">${msg("loginOtpTitle","Код подтверждения")}</h1>

<div class="space-y-4">
  <p class="text-sm text-gray-600 dark:text-gray-400 text-center">
    ${msg("loginOtpMessage","Введите одноразовый код из приложения-аутентификатора.")}
  </p>

  <form class="space-y-4" action="${url.loginAction}" method="post">
    <div>
      <label for="otp" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("loginOtpOneTime","Код")}
      </label>
      <input id="otp" name="otp" type="text" autocomplete="one-time-code" inputmode="numeric" autofocus
             class="mt-1 block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 text-sm border text-center tracking-wider font-mono bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
             <#if messagesPerField.existsError('totp')>aria-invalid="true"</#if>>
      <#if messagesPerField.existsError('totp')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('totp'))?no_esc}</p>
      </#if>
    </div>

    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors dark:focus:ring-offset-gray-800">
      ${msg("doSubmit","Подтвердить")}
    </button>
  </form>
</div>

</@layout.registrationLayout>

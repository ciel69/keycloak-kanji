<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-gray-900 dark:text-white">${msg("emailForgotTitle","Сброс пароля")}</h1>

<div class="space-y-4">
  <p class="text-sm text-gray-600 dark:text-gray-400 text-center mb-4">
    ${msg("emailInstruction","Введите ваш email для получения ссылки на сброс пароля.")}
  </p>

  <form class="space-y-4" action="${url.loginAction}" method="post">
    <div>
      <label for="username" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("usernameOrEmail","Email")}
      </label>
      <input id="username" name="username" type="text" autocomplete="email" autofocus
             class="mt-1 block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
             <#if messagesPerField.existsError('username')>aria-invalid="true"</#if>>
      <#if messagesPerField.existsError('username')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('username'))?no_esc}</p>
      </#if>
    </div>

    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors dark:focus:ring-offset-gray-800">
      ${msg("doSubmit","Отправить")}
    </button>
  </form>

  <div class="text-center">
    <a href="${url.loginUrl}" class="text-sm text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300">
      ${msg("backToLogin","Вернуться к входу")}
    </a>
  </div>
</div>

</@layout.registrationLayout>

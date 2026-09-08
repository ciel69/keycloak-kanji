<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-foreground">${msg("emailForgotTitle","Сброс пароля")}</h1>

<div class="space-y-4">
  <p class="text-sm text-muted text-center mb-4">
    ${msg("emailInstruction","Введите ваш email для получения ссылки на сброс пароля.")}
  </p>

  <form class="space-y-4" action="${url.loginAction}" method="post">
    <div>
      <label for="username" class="block text-sm font-medium text-muted">
        ${msg("usernameOrEmail","Email")}
      </label>
      <input id="username" name="username" type="text" autocomplete="email" autofocus
             class="mt-1 block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 text-sm border bg-surface text-foreground border-border focus:border-plum-500"
             <#if messagesPerField.existsError('username')>aria-invalid="true"</#if>>
      <#if messagesPerField.existsError('username')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.get('username'))?no_esc}</p>
      </#if>
    </div>

    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors focus:ring-offset-surface">
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

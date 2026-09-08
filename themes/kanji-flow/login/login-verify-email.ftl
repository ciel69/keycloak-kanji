<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=true; section>

<h1 class="text-2xl font-bold mb-6 text-center text-foreground">${msg("emailVerifyTitle","Подтвердите email")}</h1>

<div class="space-y-4 text-center">
  <p class="text-sm text-muted">
    ${msg("emailVerifyInstruction1","Мы отправили письмо с ссылкой для подтверждения на ваш email.")}
  </p>

  <p class="text-sm text-muted">
    ${msg("emailVerifyInstruction2","Не получили письмо? Проверьте папку «Спам» или нажмите ниже.")}
  </p>

  <div class="pt-4">
    <a href="${url.loginAction}"
       class="w-full inline-flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors focus:ring-offset-surface">
      ${msg("doClickHere","Отправить повторно")}
    </a>
  </div>

  <div class="text-center pt-2">
    <a href="${url.loginUrl}" class="text-sm text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300">
      ${msg("backToLogin","Вернуться к входу")}
    </a>
  </div>
</div>

</@layout.registrationLayout>

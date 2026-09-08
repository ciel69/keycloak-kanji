<#import "template.ftl" as layout>
<@layout.registrationLayout>

<h1 class="text-2xl font-bold mb-6 text-center text-foreground">${msg("logoutConfirmTitle","Выход")}</h1>

<div class="space-y-4">
  <p class="text-sm text-muted text-center">
    ${msg("logoutConfirmHeader","Вы уверены, что хотите выйти?")}
  </p>

  <form action="${url.logoutConfirmAction}" method="POST">
    <input type="hidden" name="session_code" value="${logoutConfirm.code}">
    <button type="submit" name="confirmLogout"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors disabled:opacity-50 focus:ring-offset-surface">
      ${msg("doLogout","Выйти")}
    </button>
  </form>

  <#if url.loginUrl??>
    <div class="text-center">
      <a href="${url.loginUrl}" class="min-h-[44px] inline-flex items-center text-sm text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300">
        ${msg("doLogIn","Войти")}
      </a>
    </div>
  </#if>
</div>

</@layout.registrationLayout>

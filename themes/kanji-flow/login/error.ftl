<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=true>

<h1 class="text-2xl font-bold mb-6 text-center text-foreground">${msg("errorTitle","Ошибка")}</h1>

<div class="space-y-4">
  <#if message?has_content>
    <div class="p-4 rounded-md text-sm bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-300 border border-red-200 dark:border-red-800">
      ${kcSanitize(message.summary)?no_esc}
    </div>
  </#if>

  <#if client?? && client.baseUrl?has_content>
    <div class="text-center">
      <a href="${client.baseUrl}" class="min-h-[44px] inline-flex items-center text-sm text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-2 focus-visible:ring-offset-surface">
        ${msg("backToApplication","Вернуться в приложение")}
      </a>
    </div>
  </#if>
</div>

</@layout.registrationLayout>

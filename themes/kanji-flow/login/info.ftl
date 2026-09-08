<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=false>

<h1 class="text-2xl font-bold mb-6 text-center text-foreground">${msg("infoTitle","Готово")}</h1>

<div class="space-y-4 text-center">
  <p class="text-sm text-muted">
    <#if messageHeader??>
      ${kcSanitize(msg("${messageHeader}"))?no_esc}
    <#else>
      ${message.summary}
    </#if>
  </p>

  <#if requiredActions??>
    <p class="text-sm text-muted">
      <#list requiredActions>
        <b><#items as reqActionItem>${kcSanitize(msg("requiredAction.${reqActionItem}"))?no_esc}<#sep>, </#items></b>
      </#list>
    </p>
  </#if>

  <#if !skipLink??>
    <#if pageRedirectUri?has_content>
      <div class="pt-4">
        <a href="${pageRedirectUri}"
           class="w-full inline-flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors focus:ring-offset-surface">
          ${msg("backToApplication","Вернуться в приложение")}
        </a>
      </div>
    <#elseif actionUri?has_content>
      <div class="pt-4">
        <a href="${actionUri}"
           class="w-full inline-flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors focus:ring-offset-surface">
          ${msg("proceedWithAction","Продолжить")}
        </a>
      </div>
    <#elseif (client.baseUrl)?has_content>
      <div class="pt-4">
        <a href="${client.baseUrl}"
           class="w-full inline-flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors focus:ring-offset-surface">
          ${msg("backToApplication","Вернуться в приложение")}
        </a>
      </div>
    </#if>
  </#if>
</div>

</@layout.registrationLayout>

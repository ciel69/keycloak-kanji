<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=!messagesPerField.existsError('username','email','password','password-confirm'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-gray-900 dark:text-white">${msg("registerTitle","Регистрация")}</h1>

<div class="space-y-4">
  <form class="space-y-4" action="${url.registrationAction}" method="post">

    <#-- Render User Profile fields (username, email) -->
    <#list profile.attributes as attribute>
      <#if attribute.name == "username" || attribute.name == "email">
        <div>
          <label for="${attribute.name}" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
            ${advancedMsg(attribute.displayName!attribute.name)}
            <#if attribute.required><span class="text-red-500">*</span></#if>
          </label>
          <input id="${attribute.name}" name="${attribute.name}"
                 value="${(attribute.value!'')}"
                 type="<#if attribute.name == 'email'>email<#else>text</#if>"
                 <#if attribute.required>required</#if>
                 <#if attribute.name == 'email'>autocomplete="email"<#else>autocomplete="username"</#if>
                 class="mt-1 block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500 <#if messagesPerField.existsError(attribute.name)>border-red-500 dark:border-red-500</#if>"
                 <#if messagesPerField.existsError(attribute.name)>aria-invalid="true"</#if>>
          <#if messagesPerField.existsError(attribute.name)>
            <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.getFirstError(attribute.name))?no_esc}</p>
          </#if>
        </div>
      <#else>
        <#-- Hidden field for profile attributes we don't display (firstName, lastName, etc.) -->
        <input type="hidden" name="${attribute.name}" value="${(attribute.value!'')}">
      </#if>
    </#list>

    <#-- Password field with strength indicator and rules -->
    <div>
      <label for="password" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("password","Пароль")} <span class="text-red-500">*</span>
      </label>
      <div class="relative mt-1">
        <input id="password" name="password" type="password" required autocomplete="new-password"
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500 <#if messagesPerField.existsError('password')>border-red-500 dark:border-red-500</#if>"
               <#if messagesPerField.existsError('password')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute top-1/2 -translate-y-1/2 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <#-- Strength indicator (4 segments) + rules injected by password-strength.js -->
      <div id="password-strength-container"></div>
      <#if messagesPerField.existsError('password')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.getFirstError('password'))?no_esc}</p>
      </#if>
    </div>

    <#-- Confirm password with match indicator -->
    <div>
      <label for="password-confirm" class="block text-sm font-medium text-gray-700 dark:text-gray-300">
        ${msg("passwordConfirm","Подтвердите пароль")} <span class="text-red-500">*</span>
      </label>
      <div class="relative mt-1">
        <input id="password-confirm" name="password-confirm" type="password" required autocomplete="new-password"
               class="block w-full rounded-md shadow-sm focus:ring-2 focus:ring-plum-500 focus:outline-none transition-colors px-3 py-2 pr-10 text-sm border bg-white text-gray-900 border-gray-300 focus:border-plum-500 dark:bg-gray-700 dark:text-white dark:border-gray-600 dark:focus:border-gray-500"
               <#if messagesPerField.existsError('password-confirm')>aria-invalid="true"</#if>>
        <button type="button" class="password-toggle-btn absolute top-1/2 -translate-y-1/2 right-0 flex items-center px-3 text-gray-400 hover:text-gray-600 dark:hover:text-gray-300" data-password-toggle aria-label="${msg("showPassword","Показать пароль")}">
        </button>
      </div>
      <div id="password-match-indicator" class="mt-1 text-xs hidden"></div>
      <#if messagesPerField.existsError('password-confirm')>
        <p class="mt-1 text-xs text-red-500">${kcSanitize(messagesPerField.getFirstError('password-confirm'))?no_esc}</p>
      </#if>
    </div>

    <#-- Newsletter consent (optional, unchecked by default) -->
    <div class="flex items-start gap-2">
      <input id="user.attributes.newsletterConsent" name="user.attributes.newsletterConsent" type="checkbox" value="true"
             <#if (register.formData['user.attributes.newsletterConsent']!'') == 'true'>checked</#if>
             class="mt-0.5 h-4 w-4 rounded border-gray-300 text-plum-600 focus:ring-plum-500 dark:border-gray-600 dark:bg-gray-700">
      <label for="user.attributes.newsletterConsent" class="text-xs text-gray-600 dark:text-gray-400">
        ${msg("newsletterConsentLabel","Хочу получать новости и предложения на email.")}
        <a href="https://kanji-flow.online/newsletter-consent" rel="noopener noreferrer" target="_blank" class="underline hover:no-underline text-plum-600 dark:text-plum-400">${msg("newsletterConsentLink","Условия рассылки")}</a>
      </label>
    </div>

    <#-- Submit -->
    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors disabled:opacity-50 dark:focus:ring-offset-gray-800">
      ${msg("doRegister","Зарегистрироваться")}
    </button>
  </form>

  <#-- Legal disclaimer (same block as login.ftl) -->
  <div class="text-center text-xs text-gray-500 dark:text-gray-400">
    <p>
      ${msg("legalDisclaimerPrefix","Продолжая, вы соглашаетесь с")}
      <a href="https://kanji-flow.online/terms" rel="noopener noreferrer" target="_blank" class="underline hover:no-underline text-plum-600 hover:text-plum-700 dark:text-plum-400 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-1 dark:focus-visible:ring-offset-gray-800">${msg("legalTermsLink","Пользовательским соглашением")}</a>,
      <a href="https://kanji-flow.online/policy" rel="noopener noreferrer" target="_blank" class="underline hover:no-underline text-plum-600 hover:text-plum-700 dark:text-plum-400 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-1 dark:focus-visible:ring-offset-gray-800">${msg("legalPolicyLink","Политикой конфиденциальности")}</a>,
      <a href="https://kanji-flow.online/offer" rel="noopener noreferrer" target="_blank" class="underline hover:no-underline text-plum-600 hover:text-plum-700 dark:text-plum-400 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-1 dark:focus-visible:ring-offset-gray-800">${msg("legalOfferLink","Офертой на платный функционал")}</a>
      ${msg("legalAnd","и")}
      <a href="https://kanji-flow.online/personal-data-consent" rel="noopener noreferrer" target="_blank" class="underline hover:no-underline text-plum-600 hover:text-plum-700 dark:text-plum-400 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-1 dark:focus-visible:ring-offset-gray-800">${msg("legalPersonalDataLink","Согласием на обработку персональных данных")}</a>.
    </p>
  </div>

  <#-- Link back to login -->
  <div class="text-center">
    <a href="${url.loginUrl}" class="min-h-[44px] inline-flex items-center text-sm text-plum-600 hover:text-plum-700 dark:text-plum-400 dark:hover:text-plum-300 rounded focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-800">
      ${msg("backToLogin","Уже есть аккаунт? Войти")}
    </a>
  </div>
</div>

<script src="${url.resourcesPath}/js/password-strength.js" type="text/javascript"></script>

</@layout.registrationLayout>

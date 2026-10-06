<#import "template.ftl" as layout>
<#import "user-profile-commons.ftl" as userProfileCommons>
<@layout.registrationLayout displayMessage=messagesPerField.exists('global'); section>

<h1 class="text-2xl font-bold mb-6 text-center text-foreground">${msg("loginIdpReviewProfileTitle","Подтвердите данные профиля")}</h1>

<div class="space-y-4">
  <p class="text-sm text-muted">
    ${msg("idpReviewProfileHint","Мы получили данные от провайдера. Проверьте их и при необходимости укажите e-mail.")}
  </p>

  <form id="kc-idp-review-profile-form" class="space-y-4" action="${url.loginAction}" method="post">

    <#-- Поля профиля рендерит штатный макрос Keycloak: корректные имена
         (email, username, user.attributes.*), required и вывод ошибок. -->
    <@userProfileCommons.userProfileFormFields/>

    <button type="submit"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 transition-colors disabled:opacity-50 focus:ring-offset-surface">
      ${msg("doSubmit","Продолжить")}
    </button>
  </form>
</div>

</@layout.registrationLayout>

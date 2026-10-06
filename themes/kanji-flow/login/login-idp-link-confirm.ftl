<#import "template.ftl" as layout>
<@layout.registrationLayout displayMessage=true; section>

<#-- Экран связывания: аккаунт с таким email уже существует.
     Текст плашки с email приходит из message.summary и рендерится template.ftl,
     здесь — только две кнопки-действия в стиле kanji-flow. -->
<div class="space-y-3">
  <form id="kc-register-form" class="space-y-3" action="${url.loginAction}" method="post">

    <#-- «Обзор профиля»: посмотреть/поправить данные, полученные от провайдера -->
    <#if !hideReviewButton?has_content>
      <button type="submit" name="submitAction" id="updateProfile" value="updateProfile"
              class="w-full flex justify-center py-2 px-4 rounded-md shadow-sm text-sm font-medium border bg-surface text-foreground border-border hover:bg-canvas focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 focus:ring-offset-surface transition-colors">
        ${msg("confirmLinkIdpReviewProfile")}
      </button>
    </#if>

    <#-- «Добавить в существующую учётную запись»: связать вход через VK с аккаунтом -->
    <button type="submit" name="submitAction" id="linkAccount" value="linkAccount"
            class="w-full flex justify-center py-2 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-plum-600 hover:bg-plum-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-plum-500 focus:ring-offset-plum-500 focus:ring-offset-surface transition-colors">
      ${msg("confirmLinkIdpContinue", idpDisplayName)}
    </button>

  </form>
</div>

</@layout.registrationLayout>

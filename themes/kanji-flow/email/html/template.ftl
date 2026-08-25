<#macro emailLayout>
<html lang="${locale.language}" dir="${(ltr)?then('ltr','rtl')}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Kanji Flow</title>
<style>
  body, table, td { -webkit-text-size-adjust: 100%; -ms-text-size-adjust: 100%; }
  img { border: 0; outline: none; text-decoration: none; max-width: 100%; }
  a { word-break: break-all; overflow-wrap: break-word; }
  table { table-layout: fixed; }
</style>
</head>
<body style="margin:0; padding:0; background-color:#dfe3e8; font-family:Arial,Helvetica,sans-serif; width:100%; overflow-x:hidden;">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background-color:#dfe3e8; padding:32px 16px; table-layout:fixed;">
  <tr>
    <td align="center" style="word-wrap:break-word; overflow-wrap:break-word;">
      <table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="max-width:480px; width:100%; table-layout:fixed; background-color:#ffffff; border:1px solid #e5e7eb; border-radius:12px; overflow:hidden;">
        <#-- Branded header with logo + tagline -->
        <tr>
          <td style="background-color:#ffffff; padding:32px 24px 20px; text-align:center; border-bottom:1px solid #e5e7eb;">
            <img src="${url.resourcesUrl}/img/logo.png" width="120" height="92" alt="Kanji Flow" style="display:block; width:120px; height:92px; margin:0 auto;">
            <span style="display:block; margin-top:8px; font-size:13px; color:#6b7280; line-height:1.3;">
              ${kcSanitize(msg("emailTagline","платформа для изучения японского языка"))?no_esc}
            </span>
          </td>
        </tr>
        <#-- Body content (nested email template) -->
        <tr>
          <td style="padding:32px 24px; color:#1f2937; font-size:15px; line-height:1.6; word-wrap:break-word; overflow-wrap:break-word;">
            <#nested>
          </td>
        </tr>
        <#-- Footer -->
        <tr>
          <td style="padding:20px 24px; background-color:#f3f4f6; text-align:center; font-size:12px; color:#9ca3af; border-top:1px solid #e5e7eb;">
            <p style="margin:0 0 8px; color:#6b7280;">${kcSanitize(msg("emailFooterSignoff","Команда Kanji Flow"))?no_esc}</p>
            <p style="margin:0 0 8px;">
              <a href="https://kanji-flow.online" style="color:#8b5a8f; text-decoration:none; font-weight:600;">kanji-flow.online</a>
              &nbsp;&middot;&nbsp;
              <a href="https://kanji-flow.online/contacts" style="color:#8b5a8f; text-decoration:none;">${kcSanitize(msg("emailFooterSupport","поддержка"))?no_esc}</a>
            </p>
            <p style="margin:0;">&copy; ${.now?string("yyyy")} Kanji Flow</p>
          </td>
        </tr>
      </table>
    </td>
  </tr>
</table>
</body>
</html>
</#macro>

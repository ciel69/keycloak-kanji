<#macro registrationLayout bodyClass="" displayInfo=false displayMessage=true displayRequiredFields=false>
<!DOCTYPE html>
<html class="${properties.kcHtmlClass!}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="robots" content="noindex, nofollow">

    <#if properties.meta?has_content>
        <#list properties.meta?split(' ') as meta>
            <meta name="${meta?split('==')[0]}" content="${meta?split('==')[1]}"/>
        </#list>
    </#if>

    <title>${msg("loginTitle",(realm.displayName!''))}</title>

    <link rel="icon" href="${url.resourcesPath}/img/new-circle-logo.svg" type="image/svg+xml">

    <#if properties.stylesCommon?has_content>
        <#list properties.stylesCommon?split(' ') as style>
            <link href="${url.resourcesCommonPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>
    <#if properties.styles?has_content>
        <#list properties.styles?split(' ') as style>
            <link href="${url.resourcesPath}/${style}" rel="stylesheet" />
        </#list>
    </#if>

    <#if properties.scripts?has_content>
        <#list properties.scripts?split(' ') as script>
            <script src="${url.resourcesPath}/${script}" type="text/javascript"></script>
        </#list>
    </#if>
</head>

<body class="min-h-screen flex flex-col bg-white text-gray-900 dark:bg-gray-900 dark:text-white transition-colors duration-300">

    <#-- Header -->
    <header class="fixed top-0 left-0 right-0 z-50 backdrop-blur-md bg-white/80 dark:bg-gray-900/80 border-b border-gray-200/60 dark:border-gray-700/60">
        <div class="mx-auto max-w-7xl px-3 sm:px-6 h-14 md:h-16 flex items-center gap-2 md:gap-8">
            <a href="https://kanji-flow.online" class="min-h-[44px] flex items-center shrink-0">
                <img src="${url.resourcesPath}/img/new-circle-logo.svg" alt="KanjiFlow" class="h-8 w-8 md:h-12 md:w-12">
            </a>
            <div class="flex-1"></div>
            <nav class="flex items-center gap-0.5 md:gap-1">
                <a href="https://kanji-flow.online/about"
                   class="min-h-[44px] flex items-center px-2 md:px-3 py-1.5 text-xs md:text-sm rounded-md transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-2 dark:focus-visible:ring-offset-gray-900 text-gray-600 dark:text-gray-300 hover:text-plum-600 dark:hover:text-plum-400 hover:bg-gray-100 dark:hover:bg-gray-800">
                    ${msg("navAbout","О проекте")}
                </a>
            </nav>

        </div>
    </header>

    <#-- Main content -->
    <main class="flex-1 pt-14 md:pt-16">
        <div class="relative overflow-x-hidden">
            <#-- Decorative background blur -->
            <div class="absolute top-1/3 left-1/2 -translate-x-1/2 -z-10 w-[400px] h-[400px] rounded-full bg-plum-100/40 dark:bg-plum-700/20 blur-3xl pointer-events-none" aria-hidden="true"></div>

            <div class="flex flex-col items-center justify-center min-h-[calc(100vh-8rem)] p-6">
                <div class="w-full max-w-md rounded-card shadow-card border border-gray-200 bg-white dark:border-gray-700 dark:bg-gray-800 p-6 sm:p-8">

                    <#-- Logo above form -->
                    <div class="flex justify-center mb-4">
                        <img src="${url.resourcesPath}/img/new-circle-logo.svg" alt="KanjiFlow" class="h-12 w-12">
                    </div>

                    <#-- Messages (success/error/warning/info) -->
                    <#if displayMessage && message?has_content && (message.type != 'warning' || !isAppInitiatedAction??)>
                        <div class="mb-4 p-3 rounded-md text-sm
                            <#if message.type = 'success'>bg-green-50 dark:bg-green-900/20 text-green-700 dark:text-green-300 border border-green-200 dark:border-green-800</#if>
                            <#if message.type = 'warning'>bg-yellow-50 dark:bg-yellow-900/20 text-yellow-700 dark:text-yellow-300 border border-yellow-200 dark:border-yellow-800</#if>
                            <#if message.type = 'error'>bg-red-50 dark:bg-red-900/20 text-red-700 dark:text-red-300 border border-red-200 dark:border-red-800</#if>
                            <#if message.type = 'info'>bg-blue-50 dark:bg-blue-900/20 text-blue-700 dark:text-blue-300 border border-blue-200 dark:border-blue-800</#if>"
                            role="alert">
                            ${kcSanitize(message.summary)?no_esc}
                        </div>
                    </#if>

                    <#-- Nested page content (login.ftl / register.ftl / etc.) -->
                    <#nested>
                </div>
            </div>
        </div>
    </main>

    <#-- Footer (mirrors the Nuxt frontend footer, front_tmp/auth/login/index.html) -->
    <footer class="border-t border-gray-200 dark:border-gray-700 bg-gray-100 dark:bg-gray-800 mt-8">
        <div class="mx-auto max-w-4xl px-4 sm:px-6 py-8 sm:py-10">
            <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-6">
                <div class="flex flex-col gap-3">
                    <a href="https://kanji-flow.online" class="inline-flex items-center hover:opacity-80 transition-opacity">
                        <img src="${url.resourcesPath}/img/new-logo.svg" class="h-12 w-auto" alt="Kanji Flow">
                    </a>
                    <p class="text-sm text-gray-500 dark:text-gray-400 leading-relaxed max-w-xs">
                        ${msg("footerTagline","Платформа для изучения японского языка: кандзи, кана, слова и грамматика.")}
                    </p>
                </div>

                <div class="flex flex-col gap-4 sm:items-end">
                    <nav class="flex flex-wrap gap-x-4 gap-y-1.5 text-sm text-gray-500 dark:text-gray-400 sm:justify-end">
                        <a href="https://kanji-flow.online/about" class="no-underline hover:text-plum-600 dark:hover:text-plum-400 transition-colors">${msg("navAbout","О проекте")}</a>
                        <a href="https://kanji-flow.online/contacts" class="no-underline hover:text-plum-600 dark:hover:text-plum-400 transition-colors">${msg("navContacts","Контакты")}</a>
                        <a href="https://kanji-flow.online/policy" class="no-underline hover:text-plum-600 dark:hover:text-plum-400 transition-colors">${msg("navPolicy","Политика")}</a>
                        <a href="https://kanji-flow.online/terms" class="no-underline hover:text-plum-600 dark:hover:text-plum-400 transition-colors">${msg("navTerms","Условия")}</a>
                    </nav>

                    <div class="flex items-center gap-2">
                        <span class="text-xs text-gray-400 dark:text-gray-500">${msg("footerSocialLabel","Мы в соцсетях:")}</span>
                        <div class="flex items-center gap-3">
                            <a href="https://vk.ru/kanji.flow" target="_blank" rel="noopener noreferrer"
                               aria-label="${msg("footerSocialVkAria","Kanji Flow в ВКонтакте")}"
                               class="group flex flex-col items-center gap-1.5 rounded-full focus:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-2">
                                <span class="h-10 w-10 border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 text-gray-500 dark:text-gray-400 shadow-sm hover:text-plum-600 dark:hover:text-plum-400 hover:border-plum-300 dark:hover:border-plum-600 hover:shadow-card motion-safe:hover:-translate-y-0.5 motion-reduce:transition-none inline-flex items-center justify-center rounded-full overflow-hidden transition-all duration-200">
                                    <svg viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" class="motion-safe:group-hover:scale-110 transition-transform duration-200 h-5 w-5">
                                        <path d="M11.701 18.771h1.437s.433-.047.654-.284c.21-.221.21-.63.21-.63s-.031-1.927.869-2.21c.887-.281 2.012 1.86 3.211 2.683.916.629 1.605.494 1.605.494l3.211-.044s1.682-.105.887-1.426c-.061-.105-.451-.975-2.371-2.76-2.012-1.861-1.742-1.561.676-4.787 1.469-1.965 2.07-3.166 1.875-3.676-.166-.48-1.26-.361-1.26-.361l-3.602.031s-.27-.031-.465.09c-.195.119-.314.391-.314.391s-.572 1.529-1.336 2.82c-1.623 2.729-2.268 2.879-2.523 2.699-.604-.391-.449-1.58-.449-2.432 0-2.641.404-3.75-.781-4.035-.39-.091-.681-.15-1.685-.166-1.29-.014-2.378.01-2.995.311-.405.203-.72.652-.539.675.24.03.779.146 1.064.537.375.506.359 1.636.359 1.636s.211 3.116-.494 3.503c-.495.262-1.155-.28-2.595-2.756-.735-1.26-1.291-2.67-1.291-2.67s-.105-.256-.299-.406c-.227-.165-.557-.225-.557-.225l-3.435.03s-.51.016-.689.24c-.166.195-.016.615-.016.615s2.686 6.287 5.732 9.453c2.79 2.902 5.956 2.715 5.956 2.715l-.05-.055z"/>
                                    </svg>
                                </span>
                            </a>
                            <a href="https://t.me/KanjiFlow" target="_blank" rel="noopener noreferrer"
                               aria-label="${msg("footerSocialTelegramAria","Kanji Flow в Telegram")}"
                               class="group flex flex-col items-center gap-1.5 rounded-full focus:outline-none focus-visible:ring-2 focus-visible:ring-plum-500 focus-visible:ring-offset-2">
                                <span class="h-10 w-10 border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-900 text-gray-500 dark:text-gray-400 shadow-sm hover:text-plum-600 dark:hover:text-plum-400 hover:border-plum-300 dark:hover:border-plum-600 hover:shadow-card motion-safe:hover:-translate-y-0.5 motion-reduce:transition-none inline-flex items-center justify-center rounded-full overflow-hidden transition-all duration-200">
                                    <svg viewBox="0 0 512 512" fill="currentColor" xmlns="http://www.w3.org/2000/svg" aria-hidden="true" class="motion-safe:group-hover:scale-110 transition-transform duration-200 h-5 w-5">
                                        <path d="M446.7 98.6 379.1 417.4c-5.1 22.5-18.4 28.1-37.3 17.5l-103-76-49.7 47.8c-5.5 5.5-10.1 10.1-20.6 10.1l7.4-104.9L366.8 138.8c8.3-7.4-1.8-11.5-12.8-4.1L112.1 277.9l-102.6-32.1c-22.3-7-22.7-22.3 4.9-33.1L419.6 66.6c18.6-7 34.8 4.1 27.1 32z"/>
                                    </svg>
                                </span>
                            </a>
                        </div>
                    </div>
                </div>
            </div>

            <div class="mt-6 pt-4 border-t border-gray-200 dark:border-gray-700 text-center sm:text-left text-xs text-gray-400 dark:text-gray-500">
                <p>${msg("footerCopyright", .now?string('yyyy'))}</p>
            </div>
        </div>
    </footer>

</body>
</html>
</#macro>

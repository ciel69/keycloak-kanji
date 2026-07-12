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

            <#-- Locale selector -->
            <#if realm.internationalizationEnabled && locale.supported?size gt 1>
                <div class="relative" id="kc-locale">
                    <button id="kc-locale-toggle"
                            class="min-h-[44px] flex items-center px-2 md:px-3 py-1.5 text-xs md:text-sm rounded-md transition-colors text-gray-600 dark:text-gray-300 hover:text-plum-600 dark:hover:text-plum-400 hover:bg-gray-100 dark:hover:bg-gray-800"
                            aria-label="${msg("languages","Язык")}"
                            aria-haspopup="true"
                            aria-expanded="false"
                            onclick="document.getElementById('kc-locale-dropdown').classList.toggle('hidden')">
                        ${locale.current}
                        <svg class="ml-1 w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                        </svg>
                    </button>
                    <ul id="kc-locale-dropdown"
                        class="hidden absolute right-0 mt-1 py-1 w-32 bg-white dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-md shadow-lg z-50"
                        role="menu">
                        <#list locale.supported as l>
                            <li role="none">
                                <a role="menuitem"
                                   href="${l.url}"
                                   class="block px-4 py-2 text-sm text-gray-700 dark:text-gray-300 hover:bg-gray-100 dark:hover:bg-gray-700 hover:text-plum-600 dark:hover:text-plum-400">
                                    ${l.label}
                                </a>
                            </li>
                        </#list>
                    </ul>
                </div>
            </#if>
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

    <#-- Footer -->
    <footer class="bg-gray-100 dark:bg-gray-800 py-5 mt-8">
        <div class="mx-auto max-w-7xl px-4 sm:px-6 flex flex-col sm:flex-row items-center justify-between gap-3">
            <a href="https://kanji-flow.online" class="flex items-center hover:opacity-80 transition-opacity">
                <img src="${url.resourcesPath}/img/new-logo.svg" class="h-12 w-auto" alt="Kanji Flow">
            </a>
            <nav class="flex flex-wrap justify-center gap-1 text-sm text-gray-500 dark:text-gray-400">
                <a href="https://kanji-flow.online/about" class="no-underline px-3 py-1 rounded transition-colors hover:text-plum-600 dark:hover:text-plum-400">${msg("navAbout","О проекте")}</a>
                <a href="https://kanji-flow.online/contacts" class="no-underline px-3 py-1 rounded transition-colors hover:text-plum-600 dark:hover:text-plum-400">${msg("navContacts","Контакты")}</a>
                <a href="https://kanji-flow.online/policy" class="no-underline px-3 py-1 rounded transition-colors hover:text-plum-600 dark:hover:text-plum-400">${msg("navPolicy","Политика")}</a>
                <a href="https://kanji-flow.online/terms" class="no-underline px-3 py-1 rounded transition-colors hover:text-plum-600 dark:hover:text-plum-400">${msg("navTerms","Условия")}</a>
            </nav>
            <p class="text-xs text-gray-400 dark:text-gray-500">&copy; ${.now?string('yyyy')} Kanji Flow</p>
        </div>
    </footer>

</body>
</html>
</#macro>

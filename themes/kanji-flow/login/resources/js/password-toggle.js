/**
 * password-toggle.js
 * Переключение видимости пароля (показать/скрыть) для полей формы.
 *
 * Работает с кнопками, имеющими атрибут [data-password-toggle] или
 * класс .password-toggle-btn. Ожидает структуру:
 *
 *   <div class="relative ...">
 *     <input type="password" ...>
 *     <button type="button" class="password-toggle-btn ..." data-password-toggle aria-label="...">
 *       <!-- SVG eye icon (заменяется скриптом) -->
 *     </button>
 *   </div>
 *
 * Поддерживает несколько полей на одной странице (регистрация: password + confirm).
 */
(function () {
  'use strict';

  // SVG: глаз открыт (пароль скрыт — кликни, чтобы показать)
  var EYE_OPEN_SVG =
    '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true" class="w-4 h-4">' +
      '<path stroke-linecap="round" stroke-linejoin="round" d="M2.036 12.322a1.012 1.012 0 0 1 0-.639C3.423 7.51 7.36 4.5 12 4.5c4.638 0 8.573 3.007 9.963 7.178.07.207.07.431 0 .639C20.577 16.49 16.64 19.5 12 19.5c-4.638 0-8.573-3.007-9.963-7.178Z"/>' +
      '<path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 1 1-6 0 3 3 0 0 1 6 0Z"/>' +
    '</svg>';

  // SVG: глаз перечёркнут (пароль виден — кликни, чтобы скрыть)
  var EYE_OFF_SVG =
    '<svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" aria-hidden="true" class="w-4 h-4">' +
      '<path stroke-linecap="round" stroke-linejoin="round" d="M3.98 8.223A10.477 10.477 0 0 0 1.934 12c1.292 4.338 5.31 7.5 10.066 7.5.993 0 1.953-.138 2.863-.395M6.228 6.228A10.451 10.451 0 0 1 12 4.5c4.756 0 8.773 3.162 10.065 7.498a10.522 10.522 0 0 1-4.293 5.774M6.228 6.228 3 3m3.228 3.228 3.65 3.65m7.894 7.894L21 21m-3.228-3.228-3.65-3.65m0 0a3 3 0 1 0-4.243-4.243m4.242 4.242L9.88 9.88"/>' +
    '</svg>';

  /**
   * Находит связанный input[type=password] или input[type=text] для кнопки.
   * Ищет среди соседних элементов в родительском контейнере.
   */
  function findPasswordInput(button) {
    var parent = button.parentElement;
    if (!parent) return null;
    return parent.querySelector('input[type="password"], input[type="text"][data-password-field]');
  }

  /**
   * Инициализирует переключение для одной кнопки.
   */
  function initToggleButton(button) {
    var input = findPasswordInput(button);
    if (!input) return;

    // Помечаем input для последующего поиска после смены type
    input.setAttribute('data-password-field', '');

    // Устанавливаем начальную иконку
    button.innerHTML = EYE_OPEN_SVG;

    button.addEventListener('click', function () {
      var isPassword = input.getAttribute('type') === 'password';

      if (isPassword) {
        input.setAttribute('type', 'text');
        button.innerHTML = EYE_OFF_SVG;
        button.setAttribute('aria-label', 'Скрыть пароль');
      } else {
        input.setAttribute('type', 'password');
        button.innerHTML = EYE_OPEN_SVG;
        button.setAttribute('aria-label', 'Показать пароль');
      }
    });
  }

  /**
   * Инициализация всех кнопок переключения на странице.
   */
  function init() {
    var buttons = document.querySelectorAll('[data-password-toggle], .password-toggle-btn');
    for (var i = 0; i < buttons.length; i++) {
      initToggleButton(buttons[i]);
    }
  }

  // Запуск при загрузке DOM
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

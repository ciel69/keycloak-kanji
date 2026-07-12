/**
 * password-strength.js — Индикатор сложности пароля для формы регистрации.
 *
 * Feature: custom-auth-page
 * Validates: Requirements 6.8
 *
 * Экспортирует чистую функцию evaluatePasswordStrength(password), возвращающую
 * ровно один из 3 дискретных уровней: 'weak', 'medium', 'strong'.
 *
 * Логика оценки (согласована с типичной политикой пароля realm):
 *  - 'weak':   длина < 8 ИЛИ только один класс символов
 *  - 'medium': длина >= 8 И минимум 2 класса символов
 *  - 'strong': длина >= 12 И минимум 3 класса символов
 *
 * Пароль, соответствующий политике realm (длина >= 8, >= 2 классов), ВСЕГДА
 * получает уровень не ниже 'medium'. Пароль, не соответствующий политике,
 * ВСЕГДА получает 'weak'.
 */

(function () {
  'use strict';

  /**
   * Подсчитывает количество различных классов символов в пароле.
   * Классы: lowercase, uppercase, digits, special.
   *
   * @param {string} password
   * @returns {number} от 0 до 4
   */
  function countCharacterClasses(password) {
    var classes = 0;
    if (/[a-z]/.test(password)) classes++;
    if (/[A-Z]/.test(password)) classes++;
    if (/[0-9]/.test(password)) classes++;
    if (/[^a-zA-Z0-9]/.test(password)) classes++;
    return classes;
  }

  /**
   * Оценивает сложность пароля.
   *
   * @param {string} password — строка пароля
   * @returns {'weak'|'medium'|'strong'} — ровно один из 3 уровней
   */
  function evaluatePasswordStrength(password) {
    if (typeof password !== 'string') {
      return 'weak';
    }

    var length = password.length;
    var classes = countCharacterClasses(password);

    // strong: длина >= 12 И минимум 3 класса
    if (length >= 12 && classes >= 3) {
      return 'strong';
    }

    // medium: длина >= 8 И минимум 2 класса
    if (length >= 8 && classes >= 2) {
      return 'medium';
    }

    // всё остальное — weak
    return 'weak';
  }

  // Сделать функцию доступной глобально для property-based тестирования
  window.evaluatePasswordStrength = evaluatePasswordStrength;

  // --- DOM-интеграция: индикатор сложности на форме регистрации ---

  /**
   * Создаёт HTML-структуру индикатора, если она отсутствует в DOM.
   *
   * @param {HTMLElement} passwordField — поле пароля, после которого вставить индикатор
   * @returns {HTMLElement|null} — корневой элемент индикатора
   */
  function createIndicator(passwordField) {
    var existing = document.getElementById('password-strength-indicator');
    if (existing) {
      return existing;
    }

    var container = document.createElement('div');
    container.id = 'password-strength-indicator';
    container.className = 'mt-2';
    container.innerHTML =
      '<div class="flex gap-1">' +
        '<div class="h-1 flex-1 rounded-full bg-gray-200 dark:bg-gray-700">' +
          '<div class="h-full rounded-full transition-all duration-300" id="strength-bar-1"></div>' +
        '</div>' +
        '<div class="h-1 flex-1 rounded-full bg-gray-200 dark:bg-gray-700">' +
          '<div class="h-full rounded-full transition-all duration-300" id="strength-bar-2"></div>' +
        '</div>' +
        '<div class="h-1 flex-1 rounded-full bg-gray-200 dark:bg-gray-700">' +
          '<div class="h-full rounded-full transition-all duration-300" id="strength-bar-3"></div>' +
        '</div>' +
      '</div>' +
      '<p class="text-xs mt-1" id="strength-text"></p>';

    // Вставляем после поля пароля (или его родительской обёртки)
    var parent = passwordField.parentNode;
    if (parent) {
      parent.insertBefore(container, passwordField.nextSibling);
    }

    return container;
  }

  /**
   * Обновляет визуальное состояние индикатора на основе уровня сложности.
   *
   * @param {'weak'|'medium'|'strong'} level
   */
  function updateIndicator(level) {
    var bar1 = document.getElementById('strength-bar-1');
    var bar2 = document.getElementById('strength-bar-2');
    var bar3 = document.getElementById('strength-bar-3');
    var text = document.getElementById('strength-text');

    if (!bar1 || !bar2 || !bar3 || !text) return;

    // Сброс
    var emptyStyle = 'width: 0%;';
    bar1.setAttribute('style', emptyStyle);
    bar2.setAttribute('style', emptyStyle);
    bar3.setAttribute('style', emptyStyle);
    bar1.className = 'h-full rounded-full transition-all duration-300';
    bar2.className = 'h-full rounded-full transition-all duration-300';
    bar3.className = 'h-full rounded-full transition-all duration-300';
    text.textContent = '';
    text.className = 'text-xs mt-1';

    if (level === 'weak') {
      bar1.setAttribute('style', 'width: 100%;');
      bar1.className = 'h-full rounded-full transition-all duration-300 bg-red-500';
      text.textContent = '\u0421\u043B\u0430\u0431\u044B\u0439'; // Слабый
      text.className = 'text-xs mt-1 text-red-500';
    } else if (level === 'medium') {
      bar1.setAttribute('style', 'width: 100%;');
      bar2.setAttribute('style', 'width: 100%;');
      bar1.className = 'h-full rounded-full transition-all duration-300 bg-amber-500';
      bar2.className = 'h-full rounded-full transition-all duration-300 bg-amber-500';
      text.textContent = '\u0421\u0440\u0435\u0434\u043D\u0438\u0439'; // Средний
      text.className = 'text-xs mt-1 text-amber-500';
    } else if (level === 'strong') {
      bar1.setAttribute('style', 'width: 100%;');
      bar2.setAttribute('style', 'width: 100%;');
      bar3.setAttribute('style', 'width: 100%;');
      bar1.className = 'h-full rounded-full transition-all duration-300 bg-green-500';
      bar2.className = 'h-full rounded-full transition-all duration-300 bg-green-500';
      bar3.className = 'h-full rounded-full transition-all duration-300 bg-green-500';
      text.textContent = '\u041D\u0430\u0434\u0451\u0436\u043D\u044B\u0439'; // Надёжный
      text.className = 'text-xs mt-1 text-green-500';
    }
  }

  /**
   * Инициализация: подключение к полю пароля на странице регистрации.
   */
  function init() {
    // Ищем поле пароля на странице регистрации
    var passwordField = document.getElementById('password') || document.querySelector('input[name="password"]');

    if (!passwordField) return;

    // Создаём индикатор (если его нет в шаблоне)
    createIndicator(passwordField);

    // Обработчик ввода
    passwordField.addEventListener('input', function () {
      var value = passwordField.value;
      if (!value) {
        // При пустом поле скрываем индикатор
        updateIndicator('');
        return;
      }
      var level = evaluatePasswordStrength(value);
      updateIndicator(level);
    });
  }

  // Запуск при загрузке DOM
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

/**
 * password-strength.js — Индикатор сложности пароля (4 сегмента).
 * Работает ТОЛЬКО на странице регистрации (определяется по наличию формы с action registrationAction).
 * НЕ отображается на странице входа (login).
 *
 * Feature: custom-auth-page
 * Validates: Requirements 6.8
 *
 * 4 уровня: none (0/4), weak (1/4), medium (2/4), strong (3/4), very-strong (4/4)
 */
(function () {
  'use strict';

  function countCharacterClasses(password) {
    var classes = 0;
    if (/[a-z]/.test(password)) classes++;
    if (/[A-Z]/.test(password)) classes++;
    if (/[0-9]/.test(password)) classes++;
    if (/[^a-zA-Z0-9]/.test(password)) classes++;
    return classes;
  }

  /**
   * @param {string} password
   * @returns {0|1|2|3|4} — количество заполненных сегментов из 4
   */
  function evaluatePasswordStrength(password) {
    if (typeof password !== 'string' || password.length === 0) {
      return 0;
    }

    var length = password.length;
    var classes = countCharacterClasses(password);

    // 4/4: длина >= 12 И все 4 класса символов
    if (length >= 12 && classes >= 4) return 4;

    // 3/4: длина >= 10 И минимум 3 класса
    if (length >= 10 && classes >= 3) return 3;

    // 2/4: длина >= 8 И минимум 2 класса
    if (length >= 8 && classes >= 2) return 2;

    // 1/4: хоть что-то введено
    return 1;
  }

  window.evaluatePasswordStrength = evaluatePasswordStrength;

  function getSegmentColor(level) {
    if (level <= 1) return 'bg-red-500';
    if (level === 2) return 'bg-orange-400';
    if (level === 3) return 'bg-amber-400';
    return 'bg-green-500';
  }

  function createIndicator(passwordField) {
    var existing = document.getElementById('password-strength-indicator');
    if (existing) return existing;

    var container = document.createElement('div');
    container.id = 'password-strength-indicator';
    container.className = 'mt-2 flex gap-1';
    container.innerHTML =
      '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-1"></div></div>' +
      '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-2"></div></div>' +
      '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-3"></div></div>' +
      '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-4"></div></div>';

    var wrapper = passwordField.closest('.relative') || passwordField.parentNode;
    if (wrapper && wrapper.parentNode) {
      wrapper.parentNode.insertBefore(container, wrapper.nextSibling);
    }

    return container;
  }

  function updateIndicator(level) {
    var color = getSegmentColor(level);
    for (var i = 1; i <= 4; i++) {
      var seg = document.getElementById('str-seg-' + i);
      if (!seg) continue;
      if (i <= level) {
        seg.style.width = '100%';
        seg.className = 'h-full rounded-full transition-all duration-300 ' + color;
      } else {
        seg.style.width = '0%';
        seg.className = 'h-full rounded-full transition-all duration-300';
      }
    }
  }

  function init() {
    // Работаем ТОЛЬКО на странице регистрации
    var regForm = document.querySelector('form[action*="registration"]');
    if (!regForm) return;

    var passwordField = regForm.querySelector('input[name="password"]');
    if (!passwordField) return;

    createIndicator(passwordField);

    passwordField.addEventListener('input', function () {
      var level = evaluatePasswordStrength(passwordField.value);
      updateIndicator(level);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

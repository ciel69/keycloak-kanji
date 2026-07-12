/**
 * password-strength.js — 4-segment strength indicator + password rules + match check.
 * Only runs on the registration page.
 *
 * Feature: custom-auth-page
 * Validates: Requirements 6.8
 */
(function () {
  'use strict';

  var RULES = [
    { id: 'rule-length', label: 'Минимум 8 символов', test: function(p) { return p.length >= 8; } },
    { id: 'rule-upper', label: 'Хотя бы одна заглавная буква (A–Z)', test: function(p) { return /[A-Z]/.test(p); } },
    { id: 'rule-lower', label: 'Хотя бы одна строчная буква (a–z)', test: function(p) { return /[a-z]/.test(p); } },
    { id: 'rule-digit', label: 'Хотя бы одна цифра (0–9)', test: function(p) { return /[0-9]/.test(p); } }
  ];

  function evaluatePasswordStrength(password) {
    if (typeof password !== 'string' || password.length === 0) return 0;
    var passed = 0;
    for (var i = 0; i < RULES.length; i++) {
      if (RULES[i].test(password)) passed++;
    }
    return passed; // 0-4
  }

  window.evaluatePasswordStrength = evaluatePasswordStrength;

  function getSegmentColor(level) {
    if (level <= 1) return 'bg-red-500';
    if (level === 2) return 'bg-orange-400';
    if (level === 3) return 'bg-amber-400';
    return 'bg-green-500';
  }

  function getLevelLabel(level) {
    if (level <= 1) return 'Слабый';
    if (level === 2) return 'Средний';
    if (level === 3) return 'Хороший';
    return 'Надёжный';
  }

  function getLevelColor(level) {
    if (level <= 1) return 'text-red-500';
    if (level === 2) return 'text-orange-400';
    if (level === 3) return 'text-amber-400';
    return 'text-green-500';
  }

  function createStrengthUI(container) {
    container.innerHTML =
      '<div class="mt-2 flex gap-1" id="strength-bars">' +
        '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-1"></div></div>' +
        '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-2"></div></div>' +
        '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-3"></div></div>' +
        '<div class="h-1.5 flex-1 rounded-full bg-gray-200 dark:bg-gray-600 overflow-hidden"><div class="h-full rounded-full transition-all duration-300" id="str-seg-4"></div></div>' +
      '</div>' +
      '<p class="text-xs mt-1 font-medium" id="strength-label"></p>' +
      '<ul class="mt-2 space-y-0.5 text-xs" id="password-rules"></ul>';

    var rulesContainer = container.querySelector('#password-rules');
    for (var i = 0; i < RULES.length; i++) {
      var li = document.createElement('li');
      li.id = RULES[i].id;
      li.className = 'flex items-center gap-1.5 text-gray-400 dark:text-gray-500';
      li.innerHTML = '<span class="rule-icon">·</span> ' + RULES[i].label;
      rulesContainer.appendChild(li);
    }
  }

  function updateStrengthUI(password) {
    var level = evaluatePasswordStrength(password);
    var color = getSegmentColor(level);

    // Update bars
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

    // Update label
    var label = document.getElementById('strength-label');
    if (label) {
      if (password.length === 0) {
        label.textContent = '';
        label.className = 'text-xs mt-1 font-medium';
      } else {
        label.textContent = getLevelLabel(level);
        label.className = 'text-xs mt-1 font-medium ' + getLevelColor(level);
      }
    }

    // Update rules
    for (var j = 0; j < RULES.length; j++) {
      var li = document.getElementById(RULES[j].id);
      if (!li) continue;
      var passed = password.length > 0 && RULES[j].test(password);
      if (passed) {
        li.className = 'flex items-center gap-1.5 text-green-500';
        li.querySelector('.rule-icon').textContent = '✓';
      } else {
        li.className = 'flex items-center gap-1.5 text-gray-400 dark:text-gray-500';
        li.querySelector('.rule-icon').textContent = '·';
      }
    }
  }

  function setupPasswordMatch(passwordField, confirmField) {
    var indicator = document.getElementById('password-match-indicator');
    if (!indicator) return;

    function check() {
      var pass = passwordField.value;
      var confirm = confirmField.value;

      if (confirm.length === 0) {
        indicator.classList.add('hidden');
        confirmField.classList.remove('border-green-500', 'dark:border-green-500', 'border-red-500', 'dark:border-red-500');
        return;
      }

      indicator.classList.remove('hidden');

      if (pass === confirm) {
        indicator.textContent = '✓ Пароли совпадают';
        indicator.className = 'mt-1 text-xs text-green-500';
        confirmField.classList.remove('border-red-500', 'dark:border-red-500');
        confirmField.classList.add('border-green-500', 'dark:border-green-500');
      } else {
        indicator.textContent = '✗ Пароли не совпадают';
        indicator.className = 'mt-1 text-xs text-red-500';
        confirmField.classList.remove('border-green-500', 'dark:border-green-500');
        confirmField.classList.add('border-red-500', 'dark:border-red-500');
      }
    }

    passwordField.addEventListener('input', check);
    confirmField.addEventListener('input', check);
  }

  function init() {
    // Only run on registration page
    var regForm = document.querySelector('form[action*="registration"]');
    if (!regForm) return;

    var passwordField = regForm.querySelector('input[name="password"]');
    var confirmField = regForm.querySelector('input[name="password-confirm"]');
    if (!passwordField) return;

    // Create strength UI in the designated container
    var container = document.getElementById('password-strength-container');
    if (container) {
      createStrengthUI(container);
      passwordField.addEventListener('input', function() {
        updateStrengthUI(passwordField.value);
      });
    }

    // Setup password match indicator
    if (confirmField) {
      setupPasswordMatch(passwordField, confirmField);
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

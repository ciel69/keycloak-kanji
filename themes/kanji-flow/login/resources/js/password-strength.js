/**
 * password-strength.js — Password strength indicator + rules + match check.
 * Only runs on registration page (form action contains "registration").
 * Renders into #password-strength-container and #password-match-indicator.
 */
(function () {
  'use strict';

  var RULES = [
    { id: 'len', label: 'Минимум 8 символов', test: function(p) { return p.length >= 8; } },
    { id: 'upper', label: 'Хотя бы одна заглавная буква (A–Z)', test: function(p) { return /[A-Z]/.test(p); } },
    { id: 'lower', label: 'Хотя бы одна строчная буква (a–z)', test: function(p) { return /[a-z]/.test(p); } },
    { id: 'digit', label: 'Хотя бы одна цифра (0–9)', test: function(p) { return /[0-9]/.test(p); } }
  ];

  function getLevel(password) {
    if (!password || password.length === 0) return 0;
    var passed = 0;
    for (var i = 0; i < RULES.length; i++) {
      if (RULES[i].test(password)) passed++;
    }
    return passed; // 0-4
  }

  function getColor(level) {
    if (level <= 1) return '#ef4444'; // red
    if (level === 2) return '#f97316'; // orange
    if (level === 3) return '#eab308'; // yellow/amber
    return '#22c55e'; // green
  }

  function buildUI(container) {
    container.innerHTML =
      '<div style="display:flex;gap:4px;margin-top:8px;" id="str-bars">' +
        '<div style="flex:1;height:6px;border-radius:3px;background:#4b5563;overflow:hidden;"><div id="str-s1" style="height:100%;width:0;border-radius:3px;transition:all .3s;"></div></div>' +
        '<div style="flex:1;height:6px;border-radius:3px;background:#4b5563;overflow:hidden;"><div id="str-s2" style="height:100%;width:0;border-radius:3px;transition:all .3s;"></div></div>' +
        '<div style="flex:1;height:6px;border-radius:3px;background:#4b5563;overflow:hidden;"><div id="str-s3" style="height:100%;width:0;border-radius:3px;transition:all .3s;"></div></div>' +
        '<div style="flex:1;height:6px;border-radius:3px;background:#4b5563;overflow:hidden;"><div id="str-s4" style="height:100%;width:0;border-radius:3px;transition:all .3s;"></div></div>' +
      '</div>' +
      '<ul id="str-rules" style="list-style:none;padding:0;margin:6px 0 0;font-size:12px;"></ul>';

    var rulesList = container.querySelector('#str-rules');
    for (var i = 0; i < RULES.length; i++) {
      var li = document.createElement('li');
      li.id = 'rule-' + RULES[i].id;
      li.style.cssText = 'padding:2px 0;color:#9ca3af;';
      li.innerHTML = '<span style="margin-right:4px;">·</span>' + RULES[i].label;
      rulesList.appendChild(li);
    }
  }

  function updateBars(level) {
    var color = getColor(level);
    for (var i = 1; i <= 4; i++) {
      var seg = document.getElementById('str-s' + i);
      if (!seg) continue;
      if (i <= level) {
        seg.style.width = '100%';
        seg.style.background = color;
      } else {
        seg.style.width = '0';
        seg.style.background = 'transparent';
      }
    }
  }

  function updateRules(password) {
    for (var i = 0; i < RULES.length; i++) {
      var li = document.getElementById('rule-' + RULES[i].id);
      if (!li) continue;
      var passed = password.length > 0 && RULES[i].test(password);
      if (passed) {
        li.style.color = '#22c55e';
        li.innerHTML = '<span style="margin-right:4px;">✓</span><strong>' + RULES[i].label + '</strong>';
      } else {
        li.style.color = '#9ca3af';
        li.innerHTML = '<span style="margin-right:4px;">·</span>' + RULES[i].label;
      }
    }
  }

  function initMatchIndicator(passwordField, confirmField, matchContainer) {
    function check() {
      var pw = passwordField.value;
      var confirm = confirmField.value;
      if (!confirm || confirm.length === 0) {
        matchContainer.style.display = 'none';
        confirmField.style.borderColor = '';
        return;
      }
      if (pw === confirm) {
        matchContainer.style.display = 'block';
        matchContainer.style.color = '#22c55e';
        matchContainer.innerHTML = '✓ Пароли совпадают';
        confirmField.style.borderColor = '#22c55e';
      } else {
        matchContainer.style.display = 'block';
        matchContainer.style.color = '#ef4444';
        matchContainer.innerHTML = '✗ Пароли не совпадают';
        confirmField.style.borderColor = '#ef4444';
      }
    }
    passwordField.addEventListener('input', check);
    confirmField.addEventListener('input', check);
  }

  function init() {
    var regForm = document.querySelector('form[action*="registration"]');
    if (!regForm) return;

    var passwordField = regForm.querySelector('input[name="password"]');
    var confirmField = regForm.querySelector('input[name="password-confirm"]');
    if (!passwordField) return;

    // Build strength UI
    var container = document.getElementById('password-strength-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'password-strength-container';
      var wrapper = passwordField.closest('div:not(.relative)') || passwordField.parentNode.parentNode;
      if (wrapper) wrapper.appendChild(container);
    }
    buildUI(container);

    passwordField.addEventListener('input', function () {
      var val = passwordField.value;
      var level = getLevel(val);
      updateBars(level);
      updateRules(val);
    });

    // Match indicator
    if (confirmField) {
      var matchContainer = document.getElementById('password-match-indicator');
      if (matchContainer) {
        initMatchIndicator(passwordField, confirmField, matchContainer);
      }
    }
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();

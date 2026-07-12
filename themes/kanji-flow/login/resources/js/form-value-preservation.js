/**
 * Feature: custom-auth-page, Property 2: Сохранение значений формы регистрации при ошибке валидации
 * 
 * Pure function that determines which field values to preserve on validation error.
 * Non-password fields are preserved; password fields are cleared.
 */
window.preserveFormValues = function(formValues) {
  if (!formValues || typeof formValues !== 'object') return {};
  var result = {};
  var passwordFields = ['password', 'password-confirm', 'passwordConfirm'];
  for (var key in formValues) {
    if (formValues.hasOwnProperty(key)) {
      if (passwordFields.indexOf(key) !== -1) {
        result[key] = '';
      } else {
        result[key] = formValues[key];
      }
    }
  }
  return result;
};

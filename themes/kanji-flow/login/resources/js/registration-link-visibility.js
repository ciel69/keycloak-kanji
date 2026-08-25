/**
 * Feature: custom-auth-page, Property 1: Видимость перехода к регистрации соответствует флагу realm
 *
 * Pure function that determines if the registration link should be visible.
 * Visible if and only if registrationAllowed === true.
 */
window.shouldShowRegistrationLink = function (registrationAllowed) {
  return registrationAllowed === true;
};

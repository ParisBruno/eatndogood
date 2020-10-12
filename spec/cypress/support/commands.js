// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add("login", (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add("drag", { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add("dismiss", { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This is will overwrite an existing command --
// Cypress.Commands.overwrite("visit", (originalFn, url, options) => { ... })


Cypress.Commands.add("login", (email, password) => { 
  //http://localhost:3000/live/users/sign_in?is_guest=yes
  // cy.appScenario('load_state')
  // cy.visit('/live/users/sign_in')
  cy.get("[name='app_user[email]']").type(email)
  cy.get("[name='app_user[password]']").type(password)

  cy.get('input.btn-success')
    .contains('Login')
    .click()
})
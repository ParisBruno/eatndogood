describe('recipes list', () => {
  beforeEach(() => {
    cy.app('clean')
    cy.app('load_seed')
    cy.appScenario('load_state')
    cy.visit('/live/users/sign_in')
  });

  it('lists all recipes', () => {
    cy.login('test@example.com', '123456');
    cy.get('.list-recipes').children().should('have.length', 2)
  });

  it('lists recipes without 1 allergen', () => {
    cy.login('test@example.com', '123456');
    cy.visit('/live/recipes')
    cy.wait(1000)
    cy.get('.dropdown.nav-item>a').contains('Allergens').click()
    cy.get('.dropdown.nav-item.open>.dropdown-menu>li:nth-child(1)>a>input').click()
    cy.wait(1000)
    cy.get('.list-recipes').children().should('have.length', 1)
    cy.get('.dropdown.nav-item.open>.dropdown-menu>li:nth-child(1)>a').invoke('text').then((text) => {
      cy.get('.alert-notice').contains(`All displayed recipes contain ${text.trim().toLowerCase()}`)
    })
  });

  it('lists recipes without 2 allergens', () => {
    cy.appFactories([
      ['create', 'allergen_with_recipes']
    ])
    cy.wait(1000)
    cy.login('test@example.com', '123456');
    cy.visit('/live/recipes')
    cy.wait(1000)
    cy.get('.list-recipes').children().should('have.length', 3)
    cy.wait(2000)
    cy.get('.dropdown.nav-item>a').contains('Allergens').click()
    cy.get('.dropdown.nav-item.open>.dropdown-menu>li:nth-child(1)>a>input').click()
    cy.get('.dropdown.nav-item.open>.dropdown-menu>li:nth-child(2)>a>input').click()
    cy.wait(1000)
    cy.get('.list-recipes').children().should('have.length', 2)
    cy.get('.dropdown.nav-item.open>.dropdown-menu>li:nth-child(1)>a').invoke('text').then((text1) => {
      cy.get('.dropdown.nav-item.open>.dropdown-menu>li:nth-child(2)>a').invoke('text').then((text2) => {
        cy.get('.alert-notice').contains(`All displayed recipes contain ${text2.trim().toLowerCase()},${text1.trim().toLowerCase()}`)
      })
    })
  });
})
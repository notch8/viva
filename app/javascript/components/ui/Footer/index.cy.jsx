import React from 'react'
import Footer from '.'

describe('<Footer />', () => {
  beforeEach(() => {
    cy.mount(<Footer />)
  })

  it('contains navigation links', () => {
    cy.get('a.nav-link').should('have.length', 3)
  })
})

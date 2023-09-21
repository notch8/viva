import React from 'react'
import Sidebar from '.'

describe('<Sidebar />', () => {
  beforeEach(() => {
    cy.mount(<Sidebar />)
  })

  it('contains 4 navigation links', () => {
    cy.get('a.nav-link').should('have.length', 4)
  })
})

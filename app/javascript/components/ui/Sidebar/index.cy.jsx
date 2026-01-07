import React from 'react'
import { Sidebar } from './index'

describe('Sidebar', () => {
  // since the Sidebar component is a pure component, we can test it with mocked props
  const defaultProps = {
    open: true,
    setOpen: () => {},
    currentUser: { admin: false },
    url: '/'
  }

  describe('admin button', () => {
    it('shows for admin users', () => {
      cy.mount(<Sidebar {...defaultProps} currentUser={{ admin: true }} />)
      cy.contains('Admin').should('exist')
    })

    it('hides for non-admin users', () => {
      cy.mount(<Sidebar {...defaultProps} currentUser={{ admin: false }} />)
      cy.contains('Admin').should('not.exist')
    })
  })

  describe('active state', () => {
    it('marks Search as active on root url', () => {
      cy.mount(<Sidebar {...defaultProps} url='/' />)
      cy.contains('Search All Questions').should('have.class', 'active')
    })

    it('marks Upload as active on uploads url', () => {
      cy.mount(<Sidebar {...defaultProps} url='/uploads' />)
      cy.contains('Upload Questions').should('have.class', 'active')
    })

    it('marks Settings as active on settings url', () => {
      cy.mount(<Sidebar {...defaultProps} url='/settings' />)
      cy.contains('Settings').should('have.class', 'active')
    })
  })

  describe('toggle button', () => {
    it('calls setOpen with toggled value when clicked', () => {
      const setOpen = cy.stub().as('setOpen')
      cy.mount(<Sidebar {...defaultProps} open={true} setOpen={setOpen} />)

      cy.get('[aria-controls="sidebar"]').click()
      cy.get('@setOpen').should('have.been.calledWith', false)
    })

    it('reflects open state in aria-expanded', () => {
      cy.mount(<Sidebar {...defaultProps} open={true} />)
      cy.get('[aria-controls="sidebar"]').should(
        'have.attr',
        'aria-expanded',
        'true'
      )
    })
  })

  describe('navigation links', () => {
    it('renders all standard nav items', () => {
      cy.mount(<Sidebar {...defaultProps} />)

      cy.contains('Search All Questions').should('exist')
      cy.contains('Upload Questions').should('exist')
      cy.contains('Settings').should('exist')
      cy.contains('Sign Out').should('exist')
    })
  })
})

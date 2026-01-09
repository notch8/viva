import React from 'react'
import { ExportModal } from './ExportModal'

describe('ExportModal', () => {
  const defaultProps = {
    show: false,
    onHide: () => {},
    hasBookmarks: true,
    lms: {
      canvas: [
        'Categorization (New only)',
        'Essay',
        'File Upload',
        'Matching',
        'Multiple Choice',
        'SelectAll That Apply'
      ],
      blackboard: [
        'Essay',
        'Matching',
        'Multiple Choice',
        'SelectAll That Apply'
      ],
      d2l: [
        'Essay',
        'File Upload',
        'Matching',
        'Multiple Choice',
        'SelectAll That Apply'
      ],
      moodle: ['Essay', 'Matching', 'Multiple Choice', 'SelectAll That Apply']
    }
  }

  it('does not render when show is false', () => {
    cy.mount(<ExportModal {...defaultProps} show={false} />)
    cy.get('.modal').should('not.exist')
  })

  it('renders when show is true', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('.modal').should('be.visible')
  })

  it('displays modal title', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('.modal-title').should('contain', 'Export Bookmarked Questions')
  })

  it('renders close button in header', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('.modal-header .btn-close').should('exist')
  })

  it('renders Close button in footer', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('.modal-footer').contains('button', 'Close').should('exist')
  })

  it('displays LMS tab', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.contains('Learning Management Systems').should('exist')
  })

  it('displays Text Formats tab', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.contains('Text Formats').should('exist')
  })

  it('renders Canvas export button', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('[data-format="canvas"]').should('exist')
  })

  it('renders Blackboard export button', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('[data-format="blackboard"]').should('exist')
  })

  it('renders D2L export button', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('[data-format="d2l"]').should('exist')
  })

  it('renders Moodle export button', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} />)
    cy.get('[data-format="moodle"]').should('exist')
  })

  it('enables export buttons when hasBookmarks is true', () => {
    cy.mount(<ExportModal {...defaultProps} show={true} hasBookmarks={true} />)
    cy.get('[data-format="canvas"]').should('not.be.disabled')
    cy.get('[data-format="blackboard"]').should('not.be.disabled')
    cy.get('[data-format="d2l"]').should('not.be.disabled')
    cy.get('[data-format="moodle"]').should('not.be.disabled')
  })
})

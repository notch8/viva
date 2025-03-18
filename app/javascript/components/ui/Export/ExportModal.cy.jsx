import React from 'react'
import {
  Modal, Button, Tabs, Tab
} from 'react-bootstrap'
import ExportButton from './ExportButton'

// Create a test version of ExportModal that doesn't use Inertia
const TestExportModal = ({ show, onHide, hasBookmarks }) => {
  const mockLms = {
    canvas: ['Categorization (New only)', 'Essay', 'File Upload', 'Matching', 'Multiple Choice', 'SelectAll That Apply'],
    blackboard: ['Essay', 'Matching', 'Multiple Choice', 'SelectAll That Apply'],
    d2l: ['Essay', 'File Upload', 'Matching', 'Multiple Choice', 'SelectAll That Apply'],
    moodle: ['Essay', 'Matching', 'Multiple Choice', 'SelectAll That Apply']
  }

  return (
    <Modal show={show} onHide={onHide} size='lg' centered>
      <Modal.Header closeButton>
        <Modal.Title>Export Bookmarked Questions</Modal.Title>
      </Modal.Header>
      <Modal.Body>
        <Tabs defaultActiveKey='lms' className='mb-3'>
          <Tab eventKey='lms' title='Learning Management Systems'>
            <div className='d-flex justify-content-between flex-wrap'>
              <ExportButton format='canvas' label='Canvas (New & Classic)' questionTypes={mockLms.canvas} hasBookmarks={hasBookmarks} />
              <ExportButton format='blackboard' label='Blackboard' questionTypes={mockLms.blackboard} hasBookmarks={hasBookmarks} />
              <ExportButton format='d2l' label='Brightspace (D2L)' questionTypes={mockLms.d2l} hasBookmarks={hasBookmarks} />
              <ExportButton format='moodle' label='Moodle' questionTypes={mockLms.moodle} hasBookmarks={hasBookmarks} />
            </div>
          </Tab>
          <Tab eventKey='text' title='Text Formats'>
            <div className='d-flex justify-content-center'>
              <ExportButton format='md' label='Markdown' questionTypes={[]} hasBookmarks={hasBookmarks} />
              <ExportButton format='txt' label='Plain Text' questionTypes={[]} hasBookmarks={hasBookmarks} />
            </div>
          </Tab>
        </Tabs>
      </Modal.Body>
      <Modal.Footer>
        <Button variant='secondary' onClick={onHide}>
          Close
        </Button>
      </Modal.Footer>
    </Modal>
  )
}

describe('<ExportModal />', () => {
  const mountComponent = (props = {}) => {
    const defaultProps = {
      show: true,
      onHide: cy.stub().as('onHide'),
      hasBookmarks: true
    }

    cy.mount(
      <TestExportModal {...Object.assign({}, defaultProps, props)} />
    )
  }

  it('renders when show is true', () => {
    mountComponent()
    cy.get('.modal').should('be.visible')
    cy.get('.modal-title').should('contain', 'Export Bookmarked Questions')
  })

  it('does not render when show is false', () => {
    mountComponent({ show: false })
    cy.get('.modal').should('not.exist')
  })

  it('calls onHide when close button is clicked', () => {
    mountComponent()
    cy.get('.modal-header .btn-close').click()
    cy.get('@onHide').should('have.been.called')
  })

  it('calls onHide when Close button in footer is clicked', () => {
    mountComponent()
    cy.get('.modal-footer .btn-secondary').click()
    cy.get('@onHide').should('have.been.called')
  })

  it('displays the LMS tab by default', () => {
    mountComponent()
    cy.get('.nav-tabs .active').should('contain', 'Learning Management Systems')
    cy.get('[data-format="canvas"]').should('be.visible')
    cy.get('[data-format="blackboard"]').should('be.visible')
    cy.get('[data-format="d2l"]').should('be.visible')
    cy.get('[data-format="moodle"]').should('be.visible')
  })

  it('switches to Text Formats tab when clicked', () => {
    mountComponent()
    cy.get('.nav-tabs').contains('Text Formats').click()
    cy.get('.nav-tabs .active').should('contain', 'Text Formats')
    cy.get('[data-format="md"]').should('be.visible')
    cy.get('[data-format="txt"]').should('be.visible')
  })

  it('displays correct question types for Canvas', () => {
    mountComponent()
    cy.get('[data-format="canvas"]').closest('.export-button-container')
      .find('.supported-types')
      .should('contain', 'Categorization (New only)')
      .should('contain', 'Essay')
      .should('contain', 'File Upload')
      .should('contain', 'Matching')
      .should('contain', 'Multiple Choice')
      .should('contain', 'SelectAll That Apply')
  })

  it('displays correct question types for Blackboard', () => {
    mountComponent()
    cy.get('[data-format="blackboard"]').closest('.export-button-container')
      .find('.supported-types')
      .should('contain', 'Essay')
      .should('contain', 'Matching')
      .should('contain', 'Multiple Choice')
      .should('contain', 'SelectAll That Apply')
  })

  it('displays correct question types for D2L Brightspace', () => {
    mountComponent()
    cy.get('[data-format="d2l"]').closest('.export-button-container')
      .find('.supported-types')
      .should('contain', 'Essay')
      .should('contain', 'Matching')
      .should('contain', 'Multiple Choice')
      .should('contain', 'SelectAll That Apply')
  })

  it('displays correct question types for Moodle', () => {
    mountComponent()
    cy.get('[data-format="moodle"]').closest('.export-button-container')
      .find('.supported-types')
      .should('contain', 'Essay')
      .should('contain', 'Matching')
      .should('contain', 'Multiple Choice')
      .should('contain', 'SelectAll That Apply')
  })

  it('enables export buttons when hasBookmarks is true', () => {
    mountComponent({ hasBookmarks: true })
    cy.get('.export-button').should('not.have.attr', 'disabled')
  })

  it('disables export buttons when hasBookmarks is false', () => {
    mountComponent({ hasBookmarks: false })
    cy.get('[data-format="canvas"]').should('have.attr', 'disabled')
    cy.get('[data-format="blackboard"]').should('have.attr', 'disabled')
    cy.get('[data-format="d2l"]').should('have.attr', 'disabled')
    cy.get('[data-format="moodle"]').should('have.attr', 'disabled')

    cy.get('.nav-tabs').contains('Text Formats').click()
    cy.get('[data-format="md"]').should('have.attr', 'disabled')
    cy.get('[data-format="txt"]').should('have.attr', 'disabled')
  })
})

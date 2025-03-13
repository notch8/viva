import React from 'react'
import EssayAnswers from './EssayAnswers'

describe('EssayAnswers Component', () => {
  it('renders simple HTML content', () => {
    const simpleHtml = {
      html: '<p>This is a simple paragraph.</p>'
    }

    cy.mount(<EssayAnswers answers={simpleHtml} />)

    // Check if the content is rendered correctly
    cy.get('p').should('exist')
    cy.get('p').should('contain', 'This is a simple paragraph.')
  })

  it('renders complex HTML content with multiple elements', () => {
    const complexHtml = {
      html: `
        <h1>Essay Title</h1>
        <p>This is the first paragraph of the essay.</p>
        <p>This is the second paragraph with <strong>bold</strong> and <em>italic</em> text.</p>
        <ul>
          <li>List item 1</li>
          <li>List item 2</li>
          <li>List item 3</li>
        </ul>
      `
    }

    cy.mount(<EssayAnswers answers={complexHtml} />)

    // Check if all elements are rendered correctly
    cy.get('h1').should('exist').and('contain', 'Essay Title')
    cy.get('p').should('have.length', 2)
    cy.get('p').first().should('contain', 'This is the first paragraph')
    cy.get('p').eq(1).should('contain', 'This is the second paragraph')
    cy.get('strong').should('exist').and('contain', 'bold')
    cy.get('em').should('exist').and('contain', 'italic')
    cy.get('ul').should('exist')
    cy.get('li').should('have.length', 3)
  })

  it('handles empty HTML content', () => {
    const emptyHtml = {
      html: ''
    }

    cy.mount(<EssayAnswers answers={emptyHtml} />)

    // The component should render an empty div
    cy.get('div').should('be.empty')
  })

  it('handles HTML content with special characters', () => {
    const specialCharsHtml = {
      html: '<p>Special characters: &lt; &gt; &amp; &quot; &apos;</p>'
    }

    cy.mount(<EssayAnswers answers={specialCharsHtml} />)

    // Check if special characters are rendered correctly
    cy.get('p').should('contain', 'Special characters: < > & " \'')
  })

  it('renders HTML content with links', () => {
    const htmlWithLinks = {
      html: '<p>Visit <a href="https://example.com">Example</a> website.</p>'
    }

    cy.mount(<EssayAnswers answers={htmlWithLinks} />)

    // Check if the link is rendered correctly
    cy.get('a').should('exist')
      .and('have.attr', 'href', 'https://example.com')
      .and('contain', 'Example')
  })

  it('renders HTML content with images', () => {
    const htmlWithImage = {
      html: '<p>An image: <img src="https://example.com/image.jpg" alt="Example Image" /></p>'
    }

    cy.mount(<EssayAnswers answers={htmlWithImage} />)

    // Check if the image is rendered correctly
    cy.get('img').should('exist')
      .and('have.attr', 'src', 'https://example.com/image.jpg')
      .and('have.attr', 'alt', 'Example Image')
  })

  it('renders HTML content with tables', () => {
    const htmlWithTable = {
      html: `
        <table>
          <thead>
            <tr>
              <th>Header 1</th>
              <th>Header 2</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Cell 1</td>
              <td>Cell 2</td>
            </tr>
            <tr>
              <td>Cell 3</td>
              <td>Cell 4</td>
            </tr>
          </tbody>
        </table>
      `
    }

    cy.mount(<EssayAnswers answers={htmlWithTable} />)

    // Check if the table is rendered correctly
    cy.get('table').should('exist')
    cy.get('thead').should('exist')
    cy.get('tbody').should('exist')
    cy.get('th').should('have.length', 2)
    cy.get('tr').should('have.length', 3) // 1 in thead + 2 in tbody
    cy.get('td').should('have.length', 4)
  })

  it('handles malformed HTML gracefully', () => {
    const malformedHtml = {
      html: '<p>This paragraph is not closed <strong>This is bold text</p>'
    }

    cy.mount(<EssayAnswers answers={malformedHtml} />)

    // The component should still render without errors
    cy.get('p').should('exist')
  })

  it('handles answers object with missing html property', () => {
    const invalidAnswers = {}

    // This should not throw an error
    cy.mount(<EssayAnswers answers={invalidAnswers} />)

    // The component should render an empty div
    cy.get('div').should('exist')
  })
})

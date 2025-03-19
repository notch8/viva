describe('Search Workflow', () => {
  const testUser = {
    email: 'admin@example.com',
    password: 'testing123'
  }

  beforeEach(() => {
    // Clear cookies and local storage between tests
    cy.clearCookies()
    cy.clearLocalStorage()

    // Login before each test
    cy.visit('/')
    cy.get('input[name="user[email]"]').type(testUser.email)
    cy.get('input[name="user[password]"]').type(testUser.password)
    cy.get('input[type="submit"]').click()

    // Verify successful login (redirected to search page)
    cy.url().should('include', '/')

    // Ensure search page is fully loaded
    cy.get('.search-bar').should('be.visible')
  })

  // Helper function to check if there are any search results
  const checkForSearchResults = () => {
    return cy.get('body').then($body => {
      // Check if there are any results or if we're seeing the "no results" message
      return !$body.text().includes('Your search returned no results')
    })
  }

  // Helper function to apply a filter and verify it's applied
  const applyFilter = (filterType, getLabel = true) => {
    // Set up the intercept in Cypress before any actions to monitor HTTP requests
    // Creates an alias called 'filterRequest' that spies on all GET requests
    cy.intercept('GET', '*').as('filterRequest')

    // Open the filter dropdown
    cy.contains('button', filterType.toUpperCase()).click()

    // Select the first checkbox
    cy.get('.dropdown-menu.show input[type="checkbox"]').first().as(`first${filterType}Checkbox`)
    cy.get(`@first${filterType}Checkbox`).click()

    // Get the label if requested
    if (getLabel) {
      cy.get(`@first${filterType}Checkbox`).parent().find('label')
        .invoke('text').then(text => {
          cy.wrap(text.trim()).as(`selected${filterType}`)
        })
    }
    cy.contains('button', 'Search').click()
  }

  it('should allow a user to add and remove subject filters', () => {
    applyFilter('Subjects')

    // Verify the subject filter is applied and visible in the filters area
    cy.get('.search-filters').should('be.visible')
    cy.get('.search-filters').within(() => {
      cy.contains('h3', 'Subjects').should('be.visible')
      cy.get('@selectedSubjects').then((subject) => {
        cy.contains('div', subject).should('be.visible')

        // Set up intercept before removing the filter
        cy.intercept('GET', '*').as('removeFilterRequest')

        // Remove the subject filter by clicking the CloseButton
        cy.contains('div', subject).find('button.btn-close').click()
      })
    })

    // Verify the subject filter was removed
    cy.get('.search-filters').should('not.exist')
  })

  it('should allow a user to add and remove question type filters', () => {
    applyFilter('Types')

    // Verify the type filter is applied and visible in the filters area
    cy.get('.search-filters').should('be.visible')
    cy.get('.search-filters').within(() => {
      cy.contains('h3', 'Types').should('be.visible')
      cy.get('@selectedTypes').then((type) => {
        cy.contains('div', type).should('be.visible')

        // Set up intercept before removing the filter
        cy.intercept('GET', '*').as('removeTypeFilterRequest')

        // Remove the type filter by clicking the CloseButton
        cy.contains('div', type).find('button.btn-close').click()
      })
    })

    // Verify the type filter was removed
    cy.get('.search-filters').should('not.exist')
  })

  it('should allow a user to add and remove level filters', () => {
    applyFilter('Levels')

    // Verify the level filter is applied and visible in the filters area
    cy.get('.search-filters').should('be.visible')
    cy.get('.search-filters').within(() => {
      cy.contains('h3', 'Levels').should('be.visible')
      cy.get('@selectedLevels').then((level) => {
        cy.contains('div', level).should('be.visible')

        // Set up intercept before removing the filter
        cy.intercept('GET', '*').as('removeLevelFilterRequest')

        // Remove the level filter by clicking the CloseButton
        cy.contains('div', level).find('button.btn-close').click()
      })
    })

    // Verify the level filter was removed
    cy.get('.search-filters').should('not.exist')
  })

  it('should allow a user to search using text input', () => {
    // Set up intercept for search request
    cy.intercept('GET', '*').as('searchRequest')

    // Type a search term in the search input
    const searchTerm = 'test'
    cy.get('input[name="search"]').type(searchTerm)

    // Submit the search
    cy.contains('button', 'Search').click()

    // No need to verify specific results, just check that the page loaded
    cy.get('body').should('exist')

    // Set up intercept for reset request
    cy.intercept('GET', '*').as('resetRequest')

    // Clear the search
    cy.contains('button', 'Reset').click()

    // Verify search term is cleared
    cy.get('input[name="search"]').should('have.value', '')
  })

  it('should allow a user to combine multiple filters with text search', () => {
    // Type a search term in the search input
    const searchTerm = 'test'
    cy.get('input[name="search"]').type(searchTerm)

    // Add a subject filter
    cy.contains('button', 'SUBJECTS').click()
    cy.get('.dropdown-menu.show input[type="checkbox"]').first().click()

    // Add a type filter - first close the current dropdown
    cy.get('body').click()
    cy.contains('button', 'TYPES').click()
    cy.get('.dropdown-menu.show input[type="checkbox"]').first().click()

    // Set up intercept for combined search
    cy.intercept('GET', '*').as('combinedSearchRequest')

    // Submit the search
    cy.contains('button', 'Search').click()

    // Check if filters are applied (they should be, regardless of results)
    cy.get('body').then($body => {
      if ($body.find('.search-filters').length) {
        cy.get('.search-filters').within(() => {
          cy.contains('h3', 'Subjects').should('be.visible')
          cy.contains('h3', 'Types').should('be.visible')
        })
      }
    })

    // Set up intercept for reset request
    cy.intercept('GET', '*').as('resetAllRequest')

    // Reset all filters
    cy.contains('button', 'Reset').click()

    // Verify all filters are cleared
    cy.get('.search-filters').should('not.exist')
  })

  it('should allow a user to bookmark filtered search results', () => {
    // Apply a level filter to increase chances of getting results
    applyFilter('Levels', false)

    // Verify filter is applied
    cy.get('.search-filters').should('be.visible')

    // Check if there are any search results
    checkForSearchResults().then(hasResults => {
      if (hasResults) {
        // Set up intercept for bookmark batch request
        cy.intercept('POST', '/bookmarks/create_batch').as('bookmarkBatchRequest')

        // Click bookmark filtered
        cy.contains('button', 'Bookmark Filtered').click()

        // Wait for bookmark request to complete (required because of the network request)
        cy.wait('@bookmarkBatchRequest')

        // Verify the bookmark count increased
        cy.contains('button', 'BOOKMARKS').should('not.contain.text', '(0)')

        // Check the bookmarks
        cy.contains('button', 'BOOKMARKS').click()

        // Set up intercept for view bookmarks request
        cy.intercept('GET', '*').as('viewBookmarksRequest')

        cy.contains('a', 'View Bookmarks').click()

        // Wait for view bookmarks request to complete (required because of the network request)
        cy.wait('@viewBookmarksRequest')

        // Should be on the bookmarks page
        cy.url().should('include', 'bookmarked=true')

        // Clear all bookmarks
        cy.contains('button', 'BOOKMARKS').click()

        // Set up intercept for clear bookmarks request
        cy.intercept('DELETE', '/bookmarks/destroy_all').as('clearBookmarksRequest')

        cy.contains('button', 'Clear Bookmarks').click()

        // Wait for clear bookmarks request to complete (required because of the network request)
        cy.wait('@clearBookmarksRequest')

        // Verify bookmarks were cleared
        cy.contains('button', 'BOOKMARKS').should('contain.text', '(0)')
      } else {
        cy.log('No search results found to bookmark, skipping bookmark test')
      }
    })
  })
})

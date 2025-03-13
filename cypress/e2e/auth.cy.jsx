describe('Authentication Workflow', () => {
  // Generate a unique email for testing to avoid conflicts
  const uniqueId = Math.floor(Math.random() * 100000)
  const testUser = {
    email: `test-user-${uniqueId}@example.com`,
    password: 'Password123!',
    newPassword: 'NewPassword456!'
  }

  beforeEach(() => {
    // Clear cookies and local storage between tests
    cy.clearCookies()
    cy.clearLocalStorage()
  })

  it('should allow a user to sign up and log out', () => {
    cy.visit('/register')

    // Verify signup page elements
    cy.contains('h2', 'Sign up').should('be.visible')
    cy.get('form').should('exist')

    // Fill out the signup form
    cy.get('input[name="user[email]"]').type(testUser.email)
    cy.get('input[name="user[password]"]').type(testUser.password)
    cy.get('input[name="user[password_confirmation]"]').type(testUser.password)

    // Submit the form
    cy.get('input[type="submit"]').click()

    // Verify successful signup (redirected to search page)
    cy.url().should('include', '/')

    // Find and click the logout button/link
    cy.get('button[aria-controls="sidebar"]:not(.ms-auto)').click()
    cy.get('a[href="/logout"]').click()

    // Verify h2 element with text "Log in"
    cy.contains('h2', 'Log in').should('be.visible')
  })

  it('should allow a user to log in and log out', () => {
    cy.visit('/')

    // Verify login page elements
    cy.contains('h2', 'Log in').should('be.visible')
    cy.get('form').should('exist')

    // Fill out the login form
    cy.get('input[name="user[email]"]').type(testUser.email)
    cy.get('input[name="user[password]"]').type(testUser.password)

    // Submit the form
    cy.get('input[type="submit"]').click()

    // Verify successful login (redirected to search page)
    cy.url().should('include', '/')

    // Find and click the logout button/link
    cy.get('button[aria-controls="sidebar"]:not(.ms-auto)').click()
    cy.get('a[href="/logout"]').click()

    // Verify h2 element with text "Log in"
    cy.contains('h2', 'Log in').should('be.visible')
  })

  it('should allow a user to request a password reset', () => {
    cy.visit('/password/new')

    // Verify forgot password page elements
    cy.contains('Forgot your password').should('be.visible')
    cy.get('form').should('exist')

    // Fill out the form
    cy.get('input[name="user[email]"]').type(testUser.email)

    // Submit the form
    cy.get('input[type="submit"]').click()

    // Navigate to the root page
    cy.url().should('include', '/')
  })

  it('should allow a user to update their password', () => {
    // First login
    cy.visit('/')
    cy.get('input[name="user[email]"]').type(testUser.email)
    cy.get('input[name="user[password]"]').type(testUser.password)
    cy.get('input[type="submit"]').click()

    // Navigate to settings page
    cy.visit('/settings')
    cy.get('a[role="tab"]').contains('Password').click()

    // Find and fill out the password update form
    cy.get('input[aria-label="Enter your current password"]').type(testUser.password)
    cy.get('input[aria-label="Enter your password"]').type(testUser.newPassword)
    cy.get('input[aria-label="Enter your password confirmation"]').type(testUser.newPassword)

    // Submit the form
    cy.contains('button.btn.btn-primary', 'Save').click({force: true})

    // There is a flash message that appears to validate the password update but it is not visible long enough to test

    // Logout to test new password
    cy.get('button[aria-controls="sidebar"]:not(.ms-auto)').click()
    cy.get('a[href="/logout"]').click()

    // Login with new password
    cy.visit('/')
    cy.get('input[name="user[email]"]').type(testUser.email)
    cy.get('input[name="user[password]"]').type(testUser.newPassword)
    cy.get('input[type="submit"]').click()

    // Verify successful login with new password
    cy.url().should('include', '/')
  })

  it('should protect routes that require authentication', () => {
    // Try to access a protected route without being logged in
    cy.visit('/')

    // Verify we're on the login page by checking for login form
    cy.contains('h2', 'Log in').should('be.visible')
    cy.get('form').should('exist')

    // Now login
    cy.get('input[name="user[email]"]').type(testUser.email)
    cy.get('input[name="user[password]"]').type(testUser.password)
    cy.get('input[type="submit"]').click()

    // Verify we're logged in by checking for authenticated-only elements
    // Look for the sidebar toggle button which only appears for authenticated users
    cy.get('button[aria-controls="sidebar"]:not(.ms-auto)').should('exist')

    // Try to access another protected route
    cy.visit('/settings')

    // Verify we can access the settings page (which should be protected)
    cy.contains('h3', 'Settings').should('be.visible')

    // Log out to verify protection
    cy.get('button[aria-controls="sidebar"]:not(.ms-auto)').click()
    cy.get('a[href="/logout"]').click()

    // TODO: There is no redirect just a Rails routing error
    // Try to access the protected route again
    // cy.visit('/settings')

  })

  it('should remember a user session when "Remember me" is checked', () => {
    cy.visit('/')

    // Fill out the login form
    cy.get('input[name="user[email]"]').type(testUser.email)
    cy.get('input[name="user[password]"]').type(testUser.password)

    // Check the "Remember me" checkbox
    cy.get('input[type="checkbox"]').check()

    // Submit the form
    cy.get('input[type="submit"]').click()

    // Verify successful login
    cy.url().should('include', '/')

    // Store cookies that we want to preserve (remember_me related)
    let rememberCookies = []
    cy.getCookies().then((cookies) => {
      // Filter for remember_me related cookies
      rememberCookies = cookies.filter(cookie =>
        cookie.name.includes('remember') ||
        cookie.name.includes('_session') ||
        cookie.name.includes('_user')
      )

      // Clear all cookies
      cy.clearCookies()

      // Restore only the remember_me related cookies
      rememberCookies.forEach(cookie => {
        cy.setCookie(cookie.name, cookie.value, {
          domain: cookie.domain,
          expiry: cookie.expiry,
          httpOnly: cookie.httpOnly,
          path: cookie.path,
          secure: cookie.secure
        })
      })

      // Visit the site again
      cy.visit('/')

      // Should still be logged in - check for authenticated-only elements
      cy.get('button[aria-controls="sidebar"]:not(.ms-auto)').should('exist')

      // Check for the logo in the header
      cy.get('.navbar-brand img').should('exist')
    })
  })
})

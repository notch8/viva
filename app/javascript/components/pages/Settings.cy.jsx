import { Settings } from '../../app/javascript/components/pages/Settings'

describe('<Settings />', () => {
  it('renders', () => {
    // see: https://on.cypress.io/mounting-react
    cy.mount(<Settings />)
  })
})
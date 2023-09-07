import React from 'react'
import { Route, Router } from 'wouter'
import Settings from './Settings'
import Header from './ui/Header'

// NOTE: Whatever you put here does not go away when being navigated to a different page. Use for routes only.
const App = () => {
  return (
    <Router>
      <Header />
      <Route path='/settings'><Settings /></Route>
    </Router>
  )
}

export default App

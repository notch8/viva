import React from 'react'
import { Route, Router } from 'wouter'
import Settings from './Settings'
import Header from './ui/Header'

const App = () => {
  return (
    <Router>
      <Header />
      <Route path='/settings'><Settings /></Route>
    </Router>
  )
}

export default App

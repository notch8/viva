import React from 'react'
import { Link } from "wouter"

const App = ({ name }) => {
  return (
    <div>
      <p>App.js {name}!</p>
      <Link href="/other">Go to another page</Link>
    </div>
  )
}

export default App

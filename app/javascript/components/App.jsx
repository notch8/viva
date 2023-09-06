import React from 'react'
import { Link } from 'wouter'
import Header from './ui/Header'

const App = ({ name }) => {
  return (
    <>
      <Header />
      <Link href='/other'>Go to another page</Link>
    </>
  )
}

export default App

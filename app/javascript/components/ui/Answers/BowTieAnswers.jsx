import React from 'react'
import IncorrectAnswers from '../IncorrectAnswers'

const BowTieAnswers = ({ answers }) => {
  return (
    <div className='BowTieAnswers'>
      // TODO: display the correctly formatted answers
      {/* TODO: pass the correct prop below */}
      <IncorrectAnswers incorrect_answers={[]} />
    </div>
  )
}

export default BowTieAnswers

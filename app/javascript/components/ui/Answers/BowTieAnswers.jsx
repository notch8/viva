import React from 'react'
import IncorrectAnswers from '../IncorrectAnswers'

const BowTieAnswers = ({ answers }) => {
  return (
    <div className='BowTieAnswers'>
      {/* {answers.map((answer, index) => { */}
        // TODO: display the correctly formatted answers
      {/* })} */}
      {/* TODO: pass the correct prop below */}
      <IncorrectAnswers incorrectAnswers={[]} />
    </div>
  )
}

export default BowTieAnswers

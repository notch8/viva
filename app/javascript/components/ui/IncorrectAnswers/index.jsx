import React from 'react'

const IncorrectAnswers = ({ incorrect_answers }) => {
  return (
    <div className='incorrect-question-answers'>
      <h4 className='h6 fw-bold'>Incorrect Answers</h4>
      {incorrect_answers.map((answer, index) => {
        // TODO: display the incorrect answers
      })}
    </div>
  )
}

export default IncorrectAnswers

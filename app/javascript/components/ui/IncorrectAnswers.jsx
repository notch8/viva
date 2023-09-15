import React from 'react'

const IncorrectAnswers = ({ incorrect_answers }) => {
  return (
    <div id='incorrect-question-answers'>
      <h6>Incorrect Answers</h6>
      {incorrect_answers.map((answer, index) => {
        // TODO: display the incorrect answers
      })}
    </div>
  )
}

export default IncorrectAnswers

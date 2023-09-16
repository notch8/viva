import React from 'react'
import IncorrectAnswers from '../IncorrectAnswers'

const DragAndDropAnswers = ({ answers }) => {
  return (
    <div class='DragAndDropAnswers'>
      {/* {answers.map((answer, index) => { */}
        // TODO: display the correctly formatted answers
      {/* })} */}
      {/* TODO: pass the correct prop below */}
      <IncorrectAnswers incorrect_answers={[]} />
    </div>
  )
}

export default DragAndDropAnswers

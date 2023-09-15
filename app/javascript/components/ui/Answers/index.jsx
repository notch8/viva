import React from 'react'
import BowTieAnswers from './BowTieAnswers'
import DragAndDropAnswers from './DragAndDropAnswers'
import MatchingAnswers from './MatchingAnswers'

const Answers = ({ question_type, answers }) => {
  console.log({ question_type, answers })

  return (
    <div id='question-answers'>
      <h6>Answers</h6>
      {question_type === 'Question::BowTie' && <BowTieAnswers answers={answers} />}
      {question_type === 'Question::Matching' && <MatchingAnswers answers={answers} />}
      {question_type === 'Question::DragAndDrop' && <DragAndDropAnswers answers={answers} />}

      {/* All other question types use the same format */}
      {answers.map((answer, index) => {
        console.log({ answer, index })
        // TODO: display the answers
        return <p>{answer}</p>
      })}
    </div>
  )
}

export default Answers

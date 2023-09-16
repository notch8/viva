import React from 'react'
import BowTieAnswers from './BowTieAnswers'
import DragAndDropAnswers from './DragAndDropAnswers'
import MatchingAnswers from './MatchingAnswers'
import StimulusCaseStudyAnswers from './StimulusCaseStudyAnswers'
import TraditionalAnswers from './TraditionalAnswers'

const Answers = ({ question_type, answers }) => {
  return (
    <>
      <h3 className='h6 fw-bold default-answers'>Answers</h3>
      {question_type === 'Question::BowTie' && <BowTieAnswers answers={answers} />}
      {question_type === 'Question::DragAndDrop' && <DragAndDropAnswers answers={answers} />}
      {question_type === 'Question::Matching' && <MatchingAnswers answers={answers} />}
      {question_type === 'Question::StimulusCaseStudy' && <StimulusCaseStudyAnswers answers={answers} />}
      {/* Traditional and SATA types use the same format */}
      {question_type === 'Question::Traditional' && <TraditionalAnswers answers={answers} />}
      {question_type === 'Question::SelectAllThatApply' && <TraditionalAnswers answers={answers} />}
    </>
  )
}

export default Answers

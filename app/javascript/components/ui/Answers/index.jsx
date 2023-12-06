import React from 'react'
import BowTieAnswers from './BowTieAnswers'
import DragAndDropAnswers from './DragAndDropAnswers'
import MatchingAnswers from './MatchingAnswers'
import StimulusCaseStudyAnswers from './StimulusCaseStudyAnswers'
import TraditionalAnswers from './TraditionalAnswers'
import EssayAnswers from './EssayAnswers'

const Answers = ({ question_type_name, answers }) => {
  return (
    <>
      {question_type_name === 'Stimulus Case Study' && (
        <StimulusCaseStudyAnswers answers={answers} />
      )}
      {(question_type_name === 'Essay' ||
        question_type_name === 'Upload') && (
        <EssayAnswers answers={answers} />
      )}
      {(question_type_name !== 'Stimulus Case Study' &&
        question_type_name !== 'Essay') && (
        <h3 className='h6 fw-bold default-answers'>Answers</h3>
      )}
      {question_type_name === 'Bow Tie' && <BowTieAnswers answers={answers} />}
      {question_type_name === 'Drag And Drop' && (
        <DragAndDropAnswers answers={answers} />
      )}
      {question_type_name === 'Matching' && (
        <MatchingAnswers answers={answers} />
      )}
      {/* Traditional and SATA types use the same format */}
      {(question_type_name === 'Traditional' ||
        question_type_name === 'Select All That Apply') && (
        <TraditionalAnswers answers={answers} />
      )}
    </>
  )
}

export default Answers

import React from 'react'
import Question from '../Question'
import Answers from '../Answers'

const StimulusCaseStudyAnswers = ({ answers }) => {
  return (
    <div className='StimulusCaseStudyAnswers'>
      {answers.map((answer, index) => {
        return (
          <React.Fragment key={index}>
            <Question text={answer.text} title={answer.type_label} images={answer.images} />
            {answer.data && (
              <Answers
                question_type_name={answer.type_name}
                answers={answer.data}
              />
            )}
          </React.Fragment>
        )
      })}
    </div>
  )
}

export default StimulusCaseStudyAnswers

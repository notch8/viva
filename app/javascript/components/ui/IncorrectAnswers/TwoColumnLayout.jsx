import React from 'react'
import { Square } from '@phosphor-icons/react'

const TwoColumnLayout = ({ incorrectAnswers }) => {
  return (
    <div className='incorrect-question-answers mt-3'>
      <h4 className='h6 fw-bold'>Incorrect Answers</h4>
      <div className='d-flex flex-wrap justify-content-between'>
        {incorrectAnswers.map((incorrectAnswer, index) => {
          return (
            <div className='col-md-6 py-2' key={index}>
              <Square className="me-2" weight='fill' color='#155DBD' size={28}/>
              <span>{incorrectAnswer.answer}</span>
            </div>
          )
        })}
      </div>
    </div>
  )
}

export default TwoColumnLayout

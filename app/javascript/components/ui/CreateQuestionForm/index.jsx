import React, { useState } from 'react'
import Essay from './Essay'
import QuestionTypeDropdown from './QuestionTypeDropdown'

const CreateQuestionForm = () => {
  const [questionType, setQuestionType] = useState('')

  const handleQuestionTypeSelection = (type) => {
    setQuestionType(type)
  }
  return (
    <>
      <QuestionTypeDropdown handleQuestionTypeSelection={ handleQuestionTypeSelection } />
      {questionType === 'Essay' ? <Essay /> : 'nothing'}
    </>
  )
}

export default CreateQuestionForm

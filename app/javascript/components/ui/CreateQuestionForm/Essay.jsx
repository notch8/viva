import React from 'react'
import QuestionText from './QuestionText'

const Essay = ({ handleSubmit, handleTextChange, questionText, questionType}) => {

  return (
    <>
      <h3>{questionType} Question</h3>
      <QuestionText handleSubmit={ handleSubmit } questionText={ questionText } handleTextChange={ handleTextChange } />
    </>
  )
}

export default Essay

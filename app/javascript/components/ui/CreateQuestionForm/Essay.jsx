import React from 'react'
import QuestionText from './QuestionText'

const Essay = ({ handleSubmit, questionText, handleTextChange }) => {
  return (
    <>
      <QuestionText handleSubmit={ handleSubmit } questionText={ questionText } handleTextChange={ handleTextChange } />
    </>
  )
}

export default Essay

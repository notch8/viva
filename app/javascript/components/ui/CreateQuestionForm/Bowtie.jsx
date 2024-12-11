import React from 'react'
import QuestionText from './QuestionText'

const Bowtie = ({ handleSubmit, questionText, handleTextChange }) => {
  return (
    <>
      <QuestionText handleSubmit={ handleSubmit } questionText={ questionText } handleTextChange={ handleTextChange } />
    </>
  )
}

export default Bowtie

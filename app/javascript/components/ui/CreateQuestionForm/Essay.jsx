import React from 'react'
import QuestionText from './QuestionText'

const Essay = ({ handleTextChange, onDataChange, questionType, questionText, data }) => {
  const handleDataChange = (e) => {
    onDataChange(e.target.value)
  }

  return (
    <>
      <h3>{questionType} Question</h3>
      <QuestionText
        questionText={questionText}  // Add this prop
        handleTextChange={handleTextChange}
        formLabel='Enter Short Description'
        placeHolder='Enter your short description here'
        inputType='input'
        controlId='questionDescription'
      />
      <QuestionText
        questionText={data?.html}
        handleTextChange={handleDataChange}
      />
    </>
  )
}

export default Essay

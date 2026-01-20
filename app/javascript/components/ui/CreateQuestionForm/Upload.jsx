import React from 'react'
import QuestionText from './QuestionText'

const Upload = ({ handleTextChange, onDataChange, questionType, questionText, data }) => {
  const handleDataChange = (e) => {
    onDataChange(e.target.value)
  }

  return (
    <>
      <h3>{questionType} Question</h3>
      <QuestionText
        questionText={questionText}
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

export default Upload

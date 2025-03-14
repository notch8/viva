import React from 'react'
import QuestionText from './QuestionText'

const Upload = ({ handleTextChange, onDataChange, questionType}) => {
  const handleDataChange = (e) => {
    onDataChange(e.target.value)
  }

  return (
    <>
      <h3>{questionType} Question</h3>
      <QuestionText
        handleTextChange={handleTextChange}
        formLabel='Enter Short Description'
        placeHolder='Enter your short description here'
        inputType='input'
        controlId='questionDescription'
      />
      <QuestionText handleTextChange={handleDataChange} />
    </>
  )
}

export default Upload

import React, { useState, useEffect } from 'react'
import QuestionText from './QuestionText'
import AnswerSet from './AnswerSet'

const DragAndDrop = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [answers, setAnswers] = useState([])

  const getAnswers = (answersArray) => {
    setAnswers(answersArray)
  }

  useEffect(() => {
    onDataChange(answers)
  }, [answers, onDataChange])

  return (
    <>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />

      <AnswerSet
        resetFields={resetFields}
        getAnswerSet={getAnswers}
        title='Answers'
        multipleCorrectAnswers={true}
        numberOfDisplayedAnswers={1}
      />
    </>
  )
}

export default DragAndDrop

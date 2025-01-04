import React, { useState, useCallback, useRef } from 'react'
import QuestionText from './QuestionText'
import AnswerSet from './AnswerSet'

const SelectAllThatApply = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [answers, setAnswers] = useState([])
  const updateTimeout = useRef(null)

  const updateParent = useCallback((updatedAnswers) => {
    if (updateTimeout.current) {
      clearTimeout(updateTimeout.current)
    }

    updateTimeout.current = setTimeout(() => {
      onDataChange(updatedAnswers)
    }, 300)
  }, [onDataChange])

  const getAnswers = useCallback((answersArray) => {
    setAnswers(answersArray)
    updateParent(answersArray)
  }, [updateParent])

  // Cleanup timeout on unmount
  React.useEffect(() => {
    return () => {
      if (updateTimeout.current) {
        clearTimeout(updateTimeout.current)
      }
    }
  }, [])

  return (
    <>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />
      <AnswerSet
        resetFields={resetFields}
        getAnswerSet={getAnswers}
        title='Answers'
        multipleCorrectAnswers={true}
        numberOfDisplayedAnswers={4}
      />
    </>
  )
}

export default React.memo(SelectAllThatApply)
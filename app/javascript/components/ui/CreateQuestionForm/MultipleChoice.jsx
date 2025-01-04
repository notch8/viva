import React, { useCallback, useRef } from 'react'
import QuestionText from './QuestionText'
import AnswerSet from './AnswerSet'

const MultipleChoice = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const updateTimeout = useRef(null)

  const updateParent = useCallback((updatedAnswers) => {
    if (updateTimeout.current) {
      clearTimeout(updateTimeout.current)
    }

    updateTimeout.current = setTimeout(() => {
      onDataChange(updatedAnswers)
    }, 300)
  }, [onDataChange])

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
        getAnswerSet={updateParent}
        title='Answers'
        multipleCorrectAnswers={false}
        numberOfDisplayedAnswers={4}
      />
    </>
  )
}

export default React.memo(MultipleChoice)
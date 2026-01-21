import React, { useCallback, useRef } from 'react'
import QuestionText from './QuestionText'
import AnswerSet from './AnswerSet'

const DragAndDrop = ({
  handleTextChange,
  onDataChange,
  questionText,
  questionType,
  resetFields,
  data
}) => {
  const updateTimeout = useRef(null)

  const updateParent = useCallback(
    (updatedAnswers) => {
      if (updateTimeout.current) {
        clearTimeout(updateTimeout.current)
      }

      updateTimeout.current = setTimeout(() => {
        onDataChange(updatedAnswers)
      }, 300)
    },
    [onDataChange]
  )

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
      <h3>{questionType} Question</h3>
      <QuestionText
        questionText={questionText}
        handleTextChange={handleTextChange}
      />
      <AnswerSet
        resetFields={resetFields}
        getAnswerSet={updateParent}
        title='Answers'
        multipleCorrectAnswers={true}
        numberOfDisplayedAnswers={1}
        initialData={data}
      />
    </>
  )
}

export default React.memo(DragAndDrop)

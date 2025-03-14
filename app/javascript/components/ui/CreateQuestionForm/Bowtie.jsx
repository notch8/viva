import React, { useState, useCallback, useRef } from 'react'
import QuestionText from './QuestionText'
import AnswerSet from './AnswerSet'

const Bowtie = ({ handleTextChange, onDataChange, questionText, questionType,  resetFields }) => {
  const [centerAnswers, setCenterAnswers] = useState([])
  const [rightAnswers, setRightAnswers] = useState([])
  const [leftAnswers, setLeftAnswers] = useState([])
  const updateTimeout = useRef(null)

  const updateParent = useCallback((center, left, right) => {
    if (updateTimeout.current) {
      clearTimeout(updateTimeout.current)
    }

    updateTimeout.current = setTimeout(() => {
      const formattedAnswers = {
        center: { label: 'Center Label', answers: center },
        left: { label: 'Left Label', answers: left },
        right: { label: 'Right Label', answers: right }
      }
      onDataChange(formattedAnswers)
    }, 300)
  }, [onDataChange])

  const centerColumnAnswers = useCallback((answersArray) => {
    setCenterAnswers(answersArray)
    updateParent(answersArray, leftAnswers, rightAnswers)
  }, [leftAnswers, rightAnswers, updateParent])

  const leftColumnAnswers = useCallback((answersArray) => {
    setLeftAnswers(answersArray)
    updateParent(centerAnswers, answersArray, rightAnswers)
  }, [centerAnswers, rightAnswers, updateParent])

  const rightColumnAnswers = useCallback((answersArray) => {
    setRightAnswers(answersArray)
    updateParent(centerAnswers, leftAnswers, answersArray)
  }, [centerAnswers, leftAnswers, updateParent])

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
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />
      <AnswerSet
        resetFields={resetFields}
        getAnswerSet={centerColumnAnswers}
        title='Central Theme'
        multipleCorrectAnswers={false}
        numberOfDisplayedAnswers={1}
      />
      <AnswerSet
        resetFields={resetFields}
        getAnswerSet={leftColumnAnswers}
        title='Left Label'
        multipleCorrectAnswers={true}
        numberOfDisplayedAnswers={1}
      />
      <AnswerSet
        resetFields={resetFields}
        getAnswerSet={rightColumnAnswers}
        title='Right Label'
        multipleCorrectAnswers={true}
        numberOfDisplayedAnswers={1}
      />
    </>
  )
}

export default React.memo(Bowtie)

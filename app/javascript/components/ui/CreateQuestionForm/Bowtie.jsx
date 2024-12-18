import React, { useState, useEffect } from 'react'
import QuestionText from './QuestionText'
import AnswerSet from './AnswerSet'

const Bowtie = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [centerAnswers, setCenterAnswers] = useState({})
  const [rightAnswers, setRightAnswers] = useState({})
  const [leftAnswers, setLeftAnswers] = useState({})

  useEffect(() => {
    const formattedAnswers = {center: {}, left: {}, right: {}}
    Object.assign(formattedAnswers,
      {
        center: { label: 'Center Label', answers: centerAnswers },
        left: { label: 'Left Label', answers: rightAnswers },
        right: { label: 'Right Label', answers: leftAnswers }
      }
    )
    onDataChange(formattedAnswers)
  }, [centerAnswers, rightAnswers, leftAnswers, onDataChange])

  const centerColumnAnswers = (answersArray) => {
    setCenterAnswers(answersArray)
  }

  const leftColumnAnswers = (answersArray) => {
    setLeftAnswers(answersArray)
  }

  const rightColumnAnswers = (answersArray) => {
    setRightAnswers(answersArray)
  }

  return (
    <>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />

      <AnswerSet
        resetFields={resetFields}
        getColumnAnswers={centerColumnAnswers}
        title='Central Theme'
      />
      <AnswerSet
        resetFields={resetFields}
        getColumnAnswers={leftColumnAnswers}
        title='Left Label'
      />
      <AnswerSet
        resetFields={resetFields}
        getColumnAnswers={rightColumnAnswers}
        title='Right Label'
      />

    </>
  )
}

export default Bowtie

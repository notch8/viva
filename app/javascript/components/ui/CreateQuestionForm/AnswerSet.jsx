import React, { useState, useEffect } from 'react'
import { Button } from 'react-bootstrap'
import { Plus } from '@phosphor-icons/react'
import AnswerField from './AnswerField'

const AnswerSet = ({ resetFields, getColumnAnswers, title }) => {
  const [answers, setAnswers] = useState([{answer: '', correct: false}])
  const hasAtLeastOneCorrectAnswer = answers.some(answer => answer.correct && answer.answer.trim() !== '')

  useEffect(() => {
    if (resetFields) {
      setAnswers([{answer: '', correct: false}])
    }
  }, [resetFields])

  useEffect(() => {
    getColumnAnswers(answers)
  }, [answers, getColumnAnswers])

  const addAnswerField = () => {
    setAnswers([...answers, { answer: '', correct: false }])
  }

  const updateAnswer = (index, field, value) => {
    const updatedAnswers = answers.map((answer, i) => {
      if (i === index) {
        return { ...answer, [field]: value }
      }
      return answer
    })

    setAnswers(updatedAnswers)
  }

  const removeCenterAnswer = (index) => {
    const updatedAnswers = answers.filter((_, i) => i !== index)
    setAnswers(updatedAnswers)
  }

  return (
    <>
      <AnswerField answers={answers} updateAnswer={updateAnswer} removeAnswer={removeCenterAnswer} title={title} />

      <Button
        variant='secondary'
        onClick={addAnswerField}
        className='d-flex align-items-center'
      >
        <Plus className='me-2' /> Add Answer
      </Button>

      {!hasAtLeastOneCorrectAnswer && answers.some(answer => answer.answer.trim() !== '') && (
        <div className='text-danger mt-2'>
          Please mark at least one non-empty answer as correct.
        </div>
      )}
    </>
  )
}

export default AnswerSet

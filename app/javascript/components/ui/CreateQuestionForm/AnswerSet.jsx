import React, { useState, useEffect } from 'react'
import { Button } from 'react-bootstrap'
import { Plus } from '@phosphor-icons/react'
import AnswerField from './AnswerField'

const AnswerSet = ({ resetFields, getAnswerSet, title, multipleCorrectAnswers, numberOfDisplayedAnswers = 1 }) => {
  const numberOfDisplayedAnswersArray = Array.from({ length: numberOfDisplayedAnswers }, () => ({ ...[{answer: '', correct: false}][0] }))
  const [answers, setAnswers] = useState(numberOfDisplayedAnswersArray)
  const hasAtLeastOneCorrectAnswer = answers.some(answer => answer.correct && answer.answer.trim() !== '')
  const hasExactlyOneCorrectAnswer = answers.filter(answer => answer.correct && answer.answer.trim() !== '').length === 1

  useEffect(() => {
    if (resetFields) {
      setAnswers(numberOfDisplayedAnswersArray)
    }
  }, [resetFields])

  useEffect(() => {
    getAnswerSet(answers)
  }, [answers, getAnswerSet])

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

  const removeAnswer = (index) => {
    const updatedAnswers = answers.filter((_, i) => i !== index)
    setAnswers(updatedAnswers)
  }

  return (
    <>
      <AnswerField
        answers={answers}
        updateAnswer={updateAnswer}
        removeAnswer={removeAnswer}
        title={title}
        buttonType={multipleCorrectAnswers ? 'checkbox' : 'radio'}
      />
      <Button
        variant='secondary'
        onClick={addAnswerField}
        className='d-flex align-items-center'
      >
        <Plus className='me-2' /> Add Answer
      </Button>

      {!hasExactlyOneCorrectAnswer && !multipleCorrectAnswers && answers.some(answer => answer.answer.trim() !== '') && (
        <div className='text-danger mt-2'>
          Please mark exactly one answer as correct.
        </div>
      )}

      {!hasAtLeastOneCorrectAnswer && multipleCorrectAnswers && answers.some(answer => answer.answer.trim() !== '') && (
        <div className='text-danger mt-2'>
          Please mark at least one non-empty answer as correct.
        </div>
      )}
    </>
  )
}

export default AnswerSet

import React, {
  useState, useEffect, useMemo, useCallback, useRef
} from 'react'
import { Button } from 'react-bootstrap'
import { Plus } from '@phosphor-icons/react'
import AnswerField from './AnswerField'

const AnswerSet = ({
  resetFields,
  getAnswerSet,
  title,
  multipleCorrectAnswers,
  numberOfDisplayedAnswers = 1,
  initialData = null
}) => {
  const initialAnswers = useMemo(() => {
    if (initialData && Array.isArray(initialData) && initialData.length > 0) {
      return initialData
    }
    return Array.from({ length: numberOfDisplayedAnswers }, () => ({
      answer: '',
      correct: false
    }))
  }, [numberOfDisplayedAnswers, initialData])

  const [answers, setAnswers] = useState(initialAnswers)

  const debounceTimeout = useRef(null)

  useEffect(() => {
    if (resetFields) {
      setAnswers(initialAnswers)
    }
  }, [resetFields, initialAnswers])

  const notifyParent = useCallback(
    (updatedAnswers) => {
      if (debounceTimeout.current) {
        clearTimeout(debounceTimeout.current)
      }

      debounceTimeout.current = setTimeout(() => {
        if (updatedAnswers.some((answer) => answer.answer || answer.correct)) {
          getAnswerSet(updatedAnswers)
        }
      }, 300)
    },
    [getAnswerSet]
  )

  const addAnswerField = useCallback(() => {
    const updatedAnswers = [...answers, { answer: '', correct: false }]
    setAnswers(updatedAnswers)
    notifyParent(updatedAnswers)
  }, [answers, notifyParent])

  const updateAnswer = useCallback(
    (index, field, value) => {
      let updatedAnswers

      if (field === 'correct' && value === true && !multipleCorrectAnswers) {
        // For radio buttons (single correct answer), only one can be true at a time
        updatedAnswers = answers.map((answer, i) => ({
          ...answer,
          correct: i === index // Only the selected one is correct
        }))
      } else {
        // For text changes or checkbox changes
        updatedAnswers = answers.map((answer, i) =>
          i === index ? { ...answer, [field]: value } : answer
        )
      }

      setAnswers(updatedAnswers)
      notifyParent(updatedAnswers)
    },
    [answers, multipleCorrectAnswers, notifyParent]
  )

  const removeAnswer = useCallback(
    (index) => {
      const updatedAnswers = answers.filter((_, i) => i !== index)
      setAnswers(updatedAnswers)
      notifyParent(updatedAnswers)
    },
    [answers, notifyParent]
  )

  const hasAtLeastOneCorrectAnswer = answers.some(
    (answer) => answer.correct && answer.answer.trim() !== ''
  )

  const hasExactlyOneCorrectAnswer =
    answers.filter((answer) => answer.correct && answer.answer.trim() !== '')
      .length === 1

  useEffect(() => {
    return () => {
      if (debounceTimeout.current) {
        clearTimeout(debounceTimeout.current)
      }
    }
  }, [])

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
        className='d-flex align-items-center mt-2'
      >
        <Plus className='me-2' /> Add Answer
      </Button>
      {!hasExactlyOneCorrectAnswer &&
        !multipleCorrectAnswers &&
        answers.some((answer) => answer.answer.trim() !== '') && (
        <div className='text-danger mt-2'>
            Please mark exactly one answer as correct.
        </div>
      )}
      {!hasAtLeastOneCorrectAnswer &&
        multipleCorrectAnswers &&
        answers.some((answer) => answer.answer.trim() !== '') && (
        <div className='text-danger mt-2'>
            Please mark at least one non-empty answer as correct.
        </div>
      )}
    </>
  )
}

export default React.memo(AnswerSet)

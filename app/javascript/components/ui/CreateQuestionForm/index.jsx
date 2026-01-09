// index.jsx
import React, { useState } from 'react'
import QuestionFormUI from './QuestionFormUI'

const CreateQuestionForm = ({ subjectOptions, question }) => {
  const [questionType, setQuestionType] = useState(question?.type || '')
  const [questionText, setQuestionText] = useState('')
  const [images, setImages] = useState([])
  const [level, setLevel] = useState('')
  const [subjects, setSubjects] = useState([])
  const [data, setData] = useState({ text: '', subQuestions: [] })
  const [resetFields, setResetFields] = useState(false)
  console.log('Selected question type:', questionType)

  const handleQuestionTypeSelection = (type) => {
    setQuestionType(type)
    const defaultData = {
      'Bow Tie': {
        center: { label: '', answers: [{ answer: '', correct: false }] },
        left: { label: '', answers: [{ answer: '', correct: false }] },
        right: { label: '', answers: [{ answer: '', correct: false }] }
      }
    }

    setData(defaultData[type] || { text: '', subQuestions: [] })
    setResetFields(true)
  }

  const handleTextChange = (e) => setQuestionText(e.target.value)

  const handleLevelSelection = (levelData) => setLevel(levelData)

  const handleAddSubject = (subject) => setSubjects(subject)

  const handleRemoveSubject = (subjectToRemove) =>
    setSubjects(subjects.filter((subject) => subject !== subjectToRemove))

  const formatFormData = () => {
    const formData = new FormData()
    formData.append('question[type]', questionType)
    formData.append('question[level]', level)
    formData.append('question[text]', questionText)

    const appendData = (dataToAppend) =>
      formData.append('question[data]', JSON.stringify(dataToAppend))

    const filterValidData = (data) =>
      Array.isArray(data) ? data.filter((item) => item.answer.trim() !== '') : []

    const handlers = {
      Matching: () => appendData(data),
      Categorization: () => appendData(data),
      Essay: () =>
        appendData({
          html: data
            .split('\n')
            .map((line, index) => `<p key=${index}>${line}</p>`)
            .join(''),
        }),
      'Drag and Drop': () => appendData(filterValidData(data)),
      'Bow Tie': () => data && appendData(data),
      'Multiple Choice': () => appendData(filterValidData(data)),
      'Select All That Apply': () => appendData(filterValidData(data)),
      'Stimulus Case Study': () => appendData(data),
      'File Upload': () =>
        appendData({
          html: data
            .split('\n')
            .map((line, index) => `<p key=${index}>${line}</p>`)
            .join('')
        })
    }

    if (handlers[questionType]) {
      handlers[questionType]()
    }

    images.forEach((image) => {
      formData.append('question[images][]', image.file)
      formData.append('question[alt_text][]', image.altText)
    })

    subjects.forEach((subject) =>
      formData.append('question[subjects][]', subject)
    )

    return formData
  }

  const handleSubmit = async (e) => {
    e.preventDefault()

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        body: formatFormData(),
      })
      if (response.ok) {
        alert('Question saved successfully!')
        resetForm()
      } else {
        const errorData = await response.json()
        alert(`Failed to save the question: ${errorData.errors?.join(', ')}`)
      }
    } catch (error) {
      console.error('Error saving the question:', error)
      alert('An error occurred while saving the question.')
    }
  }

  const resetForm = () => {
    setQuestionType('')
    setQuestionText('')
    setImages([])
    setLevel('')
    setSubjects([])
    setData(null)
    setResetFields(true)
  }

  const isSubmitDisabled = () => {
    if (!questionText?.trim() || images.some((image) => !image.isValid)) return true

    const validateQuestionType = (type, questionData) => {
      switch (type) {
        case 'Essay':
        case 'File Upload': {
          if (typeof data === 'object' || data === '') {
            return true
          }
          break
        }
        case 'Bow Tie': {
          const { center, left, right } = questionData || {}
          if (
            !center?.label?.trim() ||
            !left?.label?.trim() ||
            !right?.label?.trim() ||
            !center?.answers ||
            !left?.answers ||
            !right?.answers
          ) {
            return true
          }

          const oneCenterAnswerSelected = center.answers.filter(
            (answer) => answer.correct === true && answer.answer.trim()
          )
          const oneOrMoreLeftAnswersSelected = left.answers.filter(
            (answer) => answer.correct === true && answer.answer.trim()
          )
          const oneOrMoreRightAnswersSelected = right.answers.filter(
            (answer) => answer.correct === true && answer.answer.trim()
          )

          if (
            oneCenterAnswerSelected.length !== 1 ||
            oneOrMoreLeftAnswersSelected.length < 1 ||
            oneOrMoreRightAnswersSelected.length < 1
          ) {
            return true
          }
          break
        }
        case 'Categorization': {
          if (!questionData || !Array.isArray(questionData)) return true
          const isInvalid = questionData.some(
            (item) =>
              !item.answer.trim() ||
              !item.correct ||
              !Array.isArray(item.correct) ||
              item.correct.some((match) => !match.trim())
          )
          return isInvalid
        }
        case 'Matching': {
          if (!questionData || !Array.isArray(questionData)) return true
          const isInvalid = questionData.some(
            (pair) => !pair.answer.trim() || !pair.correct.trim()
          )
          return isInvalid
        }
        case 'Drag and Drop': {
          if (
            !questionData ||
            !Array.isArray(questionData) ||
            !questionData.some((item) => item.correct && item.answer.trim())
          ) {
            return true
          }
          break
        }
        case 'Multiple Choice': {
          if (!Array.isArray(questionData)) return true
          const correctCount = questionData.filter((item) => item.correct).length
          if (correctCount !== 1) return true
          break
        }
        case 'Select All That Apply': {
          if (!Array.isArray(questionData)) return true
          const correctCount = questionData.filter((item) => item.correct).length
          if (correctCount < 1) return true
          break
        }
        default:
          return false
      }
      return false
    }

    if (questionType !== 'Stimulus Case Study') {
      return validateQuestionType(questionType, data)
    }

    if (questionType === 'Stimulus Case Study') {
      if (!data.text?.trim() || !Array.isArray(data.subQuestions) || data.subQuestions.length === 0) {
        return true
      }

      const invalidSubQuestions = data.subQuestions.some((sq) => {
        if (!sq.type || !sq.text?.trim()) {
          return true
        }
        return validateQuestionType(sq.type, sq.data)
      })

      return invalidSubQuestions
    }

    return false
  }

  return (
    <QuestionFormUI
      question={question}
      questionType={questionType}
      questionText={questionText}
      images={images}
      level={level}
      subjects={subjects}
      data={data}
      resetFields={resetFields}
      subjectOptions={subjectOptions}
      isSubmitDisabled={isSubmitDisabled()}
      onQuestionTypeSelection={handleQuestionTypeSelection}
      onTextChange={handleTextChange}
      onDataChange={setData}
      onImagesChange={setImages}
      onLevelSelection={handleLevelSelection}
      onAddSubject={handleAddSubject}
      onRemoveSubject={handleRemoveSubject}
      onSubmit={handleSubmit}
    />
  )
}

export default CreateQuestionForm

import React, { useState, useEffect } from 'react'
import { Form, Button } from 'react-bootstrap'
import QuestionText from './QuestionText'

const Categorization = ({ handleTextChange, onDataChange, questionText, questionType, resetFields }) => {
  const [categories, setCategories] = useState([{ answer: '', correct: [''] }])

  useEffect(() => {
    if (resetFields) {
      setCategories([{ answer: '', correct: [''] }])
      onDataChange([{ answer: '', correct: [''] }])
    }
  }, [resetFields])

  const addCategory = () => {
    const updatedCategories = [...categories, { answer: '', correct: [''] }]
    setCategories(updatedCategories)
    onDataChange(updatedCategories)
  }

  const removeCategory = (indexToRemove) => {
    const updatedCategories = categories.filter((_, index) => index !== indexToRemove)
    setCategories(updatedCategories)
    onDataChange(updatedCategories)
  }

  const updateCategory = (index, field, value, subIndex = null) => {
    const updatedCategories = categories.map((category, i) => {
      if (i === index) {
        if (field === 'correct') {
          const updatedCorrect = [...category.correct]
          updatedCorrect[subIndex] = value
          return { ...category, correct: updatedCorrect }
        }
        return { ...category, [field]: value }
      }
      return category
    })

    setCategories(updatedCategories)
    onDataChange(updatedCategories)
  }

  const removeCorrectValue = (index, subIndex) => {
    const updatedCategories = categories.map((category, i) => {
      if (i === index) {
        const updatedCorrect = category.correct.filter((_, j) => j !== subIndex)
        return { ...category, correct: updatedCorrect.length > 0 ? updatedCorrect : [''] }
      }
      return category
    })

    setCategories(updatedCategories)
    onDataChange(updatedCategories)
  }

  const addCorrectValue = (index) => {
    const updatedCategories = categories.map((category, i) =>
      i === index ? { ...category, correct: [...category.correct, ''] } : category
    )
    setCategories(updatedCategories)
    onDataChange(updatedCategories)
  }

  return (
    <>
      <h3>{questionType} Question</h3>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />
      <h6>Categorization</h6>
      {categories.map((category, index) => (
        <div key={index} className='mb-3'>
          <div className='d-flex align-items-center mb-2'>
            <Form.Control
              placeholder='Category'
              value={category.answer}
              onChange={(e) => updateCategory(index, 'answer', e.target.value)}
              className='me-2'
            />
            <Button
              variant='danger'
              size='sm'
              onClick={() => removeCategory(index)}
              disabled={categories.length === 1}
            >
              Remove Category
            </Button>
          </div>
          <div>
            {category.correct.map((value, subIndex) => (
              <div key={subIndex} className='d-flex mb-2 align-items-center'>
                <Form.Control
                  placeholder='Correct Match'
                  value={value}
                  onChange={(e) =>
                    updateCategory(index, 'correct', e.target.value, subIndex)
                  }
                  className='me-2'
                />
                <Button
                  variant='danger'
                  size='sm'
                  onClick={() => removeCorrectValue(index, subIndex)}
                  disabled={category.correct.length === 1}
                >
                  Remove
                </Button>
              </div>
            ))}
            <Button
              variant='secondary'
              size='sm'
              onClick={() => addCorrectValue(index)}
            >
              Add Correct Value
            </Button>
          </div>
        </div>
      ))}
      <Button variant='secondary' onClick={addCategory}>
        Add Category
      </Button>
    </>
  )
}

export default Categorization

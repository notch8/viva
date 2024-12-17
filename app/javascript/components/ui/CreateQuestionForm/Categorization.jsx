import React, { useState, useEffect } from 'react'
import { Form, Button } from 'react-bootstrap'
import QuestionText from './QuestionText'

const Categorization = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [categories, setCategories] = useState([{ answer: '', correct: [''] }])
  const [errors, setErrors] = useState({})

  useEffect(() => {
    if (resetFields) {
      setCategories([{ answer: '', correct: [''] }])
      onDataChange([{ answer: '', correct: [''] }])
      setErrors({})
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

  const updateCategory = (index, field, value) => {
    const updatedCategories = categories.map((cat, i) =>
      i === index
        ? { ...cat, [field]: field === 'correct' ? value.split(',') : value }
        : cat
    )
    setCategories(updatedCategories)
    onDataChange(updatedCategories)
  }

  return (
    <>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />
      <h6>Categorization</h6>
      {categories.map((cat, index) => (
        <div key={index} className='mb-3'>
          <Form.Control
            placeholder='Category Item'
            value={cat.answer}
            onChange={(e) => updateCategory(index, 'answer', e.target.value)}
            className='mb-2'
          />
          <Form.Control
            placeholder='Corresponding Items (comma-separated)'
            value={cat.correct.join(', ')}
            onChange={(e) => updateCategory(index, 'correct', e.target.value)}
            className='mb-2'
          />
          <Button variant='danger' size='sm' onClick={() => removeCategory(index)}>
            Remove
          </Button>
        </div>
      ))}
      <Button variant='secondary' onClick={addCategory}>
        Add Category
      </Button>
    </>
  )
}

export default Categorization

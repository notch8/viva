import React, { useState, useEffect } from 'react'
import { Form, Button } from 'react-bootstrap'
import QuestionText from './QuestionText'

const Matching = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [pairs, setPairs] = useState([
    { answer: '', correct: '' },
    { answer: '', correct: '' },
    { answer: '', correct: '' },
    { answer: '', correct: '' },
  ])

  useEffect(() => {
    if (resetFields) {
      const initialPairs = [
        { answer: '', correct: '' },
        { answer: '', correct: '' },
        { answer: '', correct: '' },
        { answer: '', correct: '' },
      ]
      setPairs(initialPairs)
      onDataChange(initialPairs)
    }
  }, [resetFields])

  const addPair = () => {
    const updatedPairs = [...pairs, { answer: '', correct: '' }]
    setPairs(updatedPairs)
    onDataChange(updatedPairs)
  }

  const removePair = (indexToRemove) => {
    const updatedPairs = pairs.filter((_, index) => index !== indexToRemove)
    setPairs(updatedPairs)
    onDataChange(updatedPairs)
  }

  const updatePair = (index, field, value) => {
    const updatedPairs = pairs.map((pair, i) =>
      i === index ? { ...pair, [field]: value } : pair
    )
    setPairs(updatedPairs)
    onDataChange(updatedPairs)
  }

  return (
    <>
      <QuestionText questionText={questionText} handleTextChange={handleTextChange} />
      <h6>Matching Pairs</h6>
      {pairs.map((pair, index) => (
        <div key={index} className='mb-3'>
          <h6 className='mb-2'>Match Set {String.fromCharCode(65 + index)}</h6>
          <div className='d-flex align-items-center'>
            <Form.Control
              placeholder='Answer'
              value={pair.answer}
              onChange={(e) => updatePair(index, 'answer', e.target.value)}
              className='me-2'
            />
            <Form.Control
              placeholder='Correct Match'
              value={pair.correct}
              onChange={(e) => updatePair(index, 'correct', e.target.value)}
              className='me-2'
            />
            <Button
              variant='danger'
              size='sm'
              onClick={() => removePair(index)}
              disabled={pairs.length === 1}
            >
              Remove
            </Button>
          </div>
        </div>
      ))}
      <Button variant='secondary' onClick={addPair} className='mt-3'>
        Add Match Set
      </Button>
    </>
  )
}

export default Matching

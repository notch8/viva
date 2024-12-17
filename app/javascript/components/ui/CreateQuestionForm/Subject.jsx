import React, { useState } from 'react'
import {
  Alert, Button, Form, InputGroup
} from 'react-bootstrap'
import { Plus, X } from '@phosphor-icons/react'
import { useForm } from '@inertiajs/inertia-react'

const Subject = ({ subjects, handleAddSubject, handleRemoveSubject }) => {
  const [subject, setSubject] = useState('')
  const { clearErrors, setError, errors } = useForm({ subject: '' })

  const submitSubject = () => {
    const trimmedSubject = subject.trim()
    if (trimmedSubject.toLowerCase() && !subjects.includes(trimmedSubject.toLowerCase())) {
      handleAddSubject(trimmedSubject)
      setSubject('') // Clear input after adding
    } else {
      setError('subject', 'Subject already exists.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
      setSubject('')
    }
  }

  return (
    <div className='bg-light-2 p-2 mb-2 rounded'>
      <h6 className='fw-bold'>Subjects</h6>
      {subjects.map((subject, index) => (
        <div
          className='m-1 btn bg-white text-lowercase'
          key={index}
        >
          {subject}
          {' '}
          <button
            type='button'
            className='ms-2'
            aria-label='Remove'
            onClick={() => handleRemoveSubject(subject)}
          >
            <X size={20} />
          </button>
        </div>
      ))}
      <InputGroup className='mb-3 text-uppercase'>
        <Form.Group controlId='add-subject'>
          <Form.Control
            type='text'
            aria-label='Upload a Subject here'
            placeholder='Add a Subject' // Placeholder text here
            onChange={(e) => setSubject(e.target.value)}
            value={subject}
            className='rounded-0 py-3 form-control'
          />
        </Form.Group>
        <Button
          className='d-flex align-items-center fs-6 justify-content-center'
          variant='light-4'
          id='add-subject'
          size='lg'
          type='submit'
          onClick={submitSubject}
          disabled={!subject.trim()} // Disable button for empty or whitespace-only input
        >
          <Plus size={20} weight='bold' />
        </Button>
      </InputGroup>
      {errors.subject && <Alert variant='danger' dismissible>{errors.subject}</Alert>}
    </div>
  )
}

export default Subject

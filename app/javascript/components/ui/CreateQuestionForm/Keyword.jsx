import React, { useState } from 'react'
import {
  Alert, Button, Form, InputGroup
} from 'react-bootstrap'
import { Plus, X } from '@phosphor-icons/react'
import { useForm } from '@inertiajs/inertia-react'

const Keyword = ({ keywords, handleAddKeyword, handleRemoveKeyword }) => {
  const [keyword, setKeyword] = useState('')
  const { clearErrors, setError, errors } = useForm({ keyword: '' })

  const submitKeyword = () => {
    const trimmedKeyword = keyword.trim()
    if (trimmedKeyword.toLowerCase() && !keywords.includes(trimmedKeyword.toLowerCase())) {
      handleAddKeyword(trimmedKeyword)
      setKeyword('') // Clear input after adding
    } else {
      setError('keyword', 'Keyword already exists.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
      setKeyword('')
    }
  }

  return (
    <div className='bg-light-2 p-2 mb-2 rounded'>
      <h6 className='fw-bold'>Keywords</h6>
      {keywords.map((keyword, index) => (
        <div
          className='m-1 btn bg-white text-lowercase'
          key={index}
        >
          {keyword}
          {' '}
          <button
            type='button'
            className='ms-2'
            aria-label='Remove'
            onClick={() => handleRemoveKeyword(keyword)}
          >
            <X size={20} />
          </button>
        </div>
      ))}
      <InputGroup className='mb-3 text-uppercase'>
        <Form.Group controlId='add-keyword'>
          <Form.Control
            type='text'
            aria-label='Upload a Keyword here'
            placeholder='Add a Keyword' // Placeholder text here
            onChange={(e) => setKeyword(e.target.value)}
            value={keyword}
            className='rounded-0 py-3 form-control'
          />
        </Form.Group>
        <Button
          className='d-flex align-items-center fs-6 justify-content-center'
          variant='light-4'
          id='add-keyword'
          size='lg'
          type='submit'
          onClick={submitKeyword}
          disabled={!keyword.trim()} // Disable button for empty or whitespace-only input
        >
          <Plus size={20} weight='bold' />
        </Button>
      </InputGroup>
      {errors.keyword && <Alert variant='danger' dismissible>{errors.keyword}</Alert>}
    </div>
  )
}

export default Keyword

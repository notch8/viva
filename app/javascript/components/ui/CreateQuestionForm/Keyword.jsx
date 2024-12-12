import React, { useState } from 'react'
import { Form, InputGroup, Button } from 'react-bootstrap'
import { Plus, X } from '@phosphor-icons/react'

const Keyword = ({ keywords, handleAddKeyword, handleRemoveKeyword }) => {
  const [keyword, setKeyword] = useState('')

  const submitKeyword = () => {
    const trimmedKeyword = keyword.trim()
    if (trimmedKeyword && !keywords.includes(trimmedKeyword)) {
      handleAddKeyword(trimmedKeyword)
      setKeyword('') // Clear input after adding
    }
  }

  return (
    <div className='bg-light-2 p-2 rounded'>
      <h6 className='fw-bold'>Keywords</h6>
      {keywords.map((keyword, index) => (
        <div
          className='m-1 btn bg-white text-lowercase'
          key={index}
        >
          {keyword}
          {' '}
          <button
            type="button"
            className="ms-2"
            aria-label="Remove"
            onClick={() => handleRemoveKeyword(keyword)}
          >
            <X size={20} />
          </button>
        </div>
      ))}
      <InputGroup className='mb-3 text-uppercase'>
        <InputGroup.Text className='strait py-3'>
          Add a Keyword
        </InputGroup.Text>
        <Form.Group controlId='add-keyword'>
          <Form.Control
            type='text'
            aria-label='Upload a Keyword here'
            onChange={(e) => setKeyword(e.target.value)}
            value={keyword}
            className='rounded-0 py-3'
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
    </div>
  )
}

export default Keyword

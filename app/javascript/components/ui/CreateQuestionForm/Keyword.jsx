import React, { useState } from 'react'
import { Form, InputGroup, Button } from 'react-bootstrap'
import { Plus, X } from '@phosphor-icons/react'

const Keyword = () => {
  const [keywords, setKeywords] = useState([])
  const [keyword, setKeyword] = useState('')

  const submit = (e) => {
    console.log('submit', keyword);
    e.preventDefault()
    setKeywords(keywords.concat(keyword))
    e.target.reset()
    setKeyword('')
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
          <X size={20} />
        </div>
      ))}
      <Form onSubmit={submit} className='text-uppercase'>
        <InputGroup className='mb-3'>
          <InputGroup.Text className='strait py-3'>
            Add a Keyword
          </InputGroup.Text>
          <Form.Group controlId='upload-csv'>
            <Form.Control
              type='text'
              aria-label='Upload a Keyword here'
              onChange={(e) => setKeyword(e.target.value)}
              className='rounded-0 py-3'
            />
          </Form.Group>
          <Button
            className='d-flex align-items-center fs-6 justify-content-center'
            variant='light-4'
            id='upload-csv'
            size='lg'
            type='submit'
          >
            <Plus size={20} weight='bold' />
          </Button>
        </InputGroup>
      </Form>
    </div>
  )
}

export default Keyword

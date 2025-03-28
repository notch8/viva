import React from 'react'
import { Form, InputGroup, Button } from 'react-bootstrap'
import { UploadSimple } from '@phosphor-icons/react'

const UploadForm = ({ submit, setData, processing }) => {
  return (
    <Form onSubmit={submit} className='upload-form text-uppercase'>
      <InputGroup className='mb-3'>
        <Form.Label
          className='strait py-3 input-group-text mb-0'
          htmlFor='upload-csv'
        >
          Select a CSV or ZIP to Upload
        </Form.Label>
        <Form.Group controlId='upload-csv'>
          <Form.Control
            type='file'
            aria-label='Upload a CSV here'
            onChange={e => setData('csv', e.target.files)}
            className='rounded-0 py-3'
            multiple={false}
            accept='.csv, .zip'
          />
        </Form.Group>
        <Button
          className='d-flex align-items-center fs-6 justify-content-center'
          variant='light-4'
          id='upload-csv'
          size='lg'
          type='submit'
          disabled={processing}
        >
          <UploadSimple size={20} weight='bold' />
        </Button>
      </InputGroup>
    </Form>
  )
}

export default UploadForm

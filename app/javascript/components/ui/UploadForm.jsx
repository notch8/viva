import React from 'react'
import { Form, InputGroup, Button } from 'react-bootstrap'
import { UploadSimple } from '@phosphor-icons/react'

const UploadForm = ({ submit, setData, processing }) => {
  return (
        <Form onSubmit={submit} className='csv-upload-form text-uppercase'>
          <InputGroup className="mb-3">
            <InputGroup.Text className='strait py-3'>
              Select a CSV to Upload
            </InputGroup.Text>
            <Form.Group controlId="upload-csv">
              <Form.Control
                type="file"
                aria-label="Upload a CSV here"
                onChange={e => setData('csv', e.target.files)}
                className='rounded-0 py-3'
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

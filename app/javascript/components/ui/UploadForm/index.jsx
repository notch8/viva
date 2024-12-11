import React, { useState, useRef } from 'react'
import { Form, InputGroup, Button } from 'react-bootstrap'
import { UploadSimple } from '@phosphor-icons/react'

const UploadForm = ({ submit, setData, processing }) => {
  const [selectedFile, setSelectedFile] = useState(null) // Track the selected file
  const fileInputRef = useRef(null) // Ref for the file input field

  const handleFileChange = (e) => {
    const file = e.target.files[0] // Single file selection
    if (file) {
      setSelectedFile(file)
      setData('csv', e.target.files)
    }
  }

  const handleRemoveFile = () => {
    setSelectedFile(null) // Clear the selected file state
    fileInputRef.current.value = '' // Reset the file input field
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    // Pass the form submission responsibility to the parent
    submit(e, () => {
      // Reset form only if the parent indicates successful submission
      setSelectedFile(null)
      fileInputRef.current.value = '' // Clear the file input
    })
  }

  return (
    <Form onSubmit={handleSubmit} className='csv-upload-form text-uppercase'>
      <InputGroup className='mb-3'>
        <InputGroup.Text className='strait py-3'>
          Select a CSV or ZIP to Upload
        </InputGroup.Text>
        <Form.Group controlId='upload-csv'>
          <Form.Control
            type='file'
            ref={fileInputRef} // Attach the ref to the file input
            aria-label='Upload a CSV here'
            onChange={handleFileChange}
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
          disabled={processing || !selectedFile} // Disable if no file is selected
        >
          <UploadSimple size={20} weight='bold' />
        </Button>
      </InputGroup>
      {selectedFile && (
        <div className='mt-3 d-flex align-items-center'>
          <span className='me-3'>{selectedFile.name}</span>
          <Button
            variant='danger'
            size='sm'
            onClick={handleRemoveFile} // Remove file on click
          >
            Remove
          </Button>
        </div>
      )}
    </Form>
  )
}

export default UploadForm

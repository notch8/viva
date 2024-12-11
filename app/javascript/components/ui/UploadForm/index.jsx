import React, { useState, useRef } from 'react'
import { Form, InputGroup, Button } from 'react-bootstrap'
import { UploadSimple } from '@phosphor-icons/react'

const UploadForm = ({ submit, setData, processing }) => {
  const [selectedFile, setSelectedFile] = useState(null) // Track the selected file
  const [fileError, setFileError] = useState('') // Track validation error message
  const fileInputRef = useRef(null) // Ref for the file input field

  const handleFileChange = (e) => {
    const file = e.target.files[0] // Single file selection
    const validExtensions = ['csv', 'zip']
    if (file) {
      const extension = file.name.split('.').pop().toLowerCase()
      if (!validExtensions.includes(extension)) {
        setFileError('Invalid file type. Only CSV or ZIP files are allowed.')
        setSelectedFile({
          file,
          isValid: false, // Flag as invalid
        })
      } else {
        setFileError('') // Clear error if valid
        setSelectedFile({
          file,
          isValid: true, // Flag as valid
        })
        setData('csv', e.target.files)
      }
    }
  }

  const handleRemoveFile = () => {
    setSelectedFile(null) // Clear the selected file state
    setFileError('') // Clear any validation error
    fileInputRef.current.value = '' // Reset the file input field
  }

  const handleSubmit = (e) => {
    e.preventDefault()
    // Pass the form submission responsibility to the parent
    if (selectedFile && selectedFile.isValid) {
      submit(e, () => {
        // Reset form only if the parent indicates successful submission
        setSelectedFile(null)
        fileInputRef.current.value = '' // Clear the file input
      })
    }
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
          disabled={processing || !selectedFile || !selectedFile.isValid} // Disable if no valid file
        >
          <UploadSimple size={20} weight='bold' />
        </Button>
      </InputGroup>
      {selectedFile && (
        <div className='mt-3 d-flex align-items-center'>
          <span className={`me-3 ${!selectedFile.isValid ? 'text-danger' : ''}`}>
            {selectedFile.file.name} {!selectedFile.isValid && '(Invalid)'}
          </span>
          <Button
            variant='danger'
            size='sm'
            onClick={handleRemoveFile} // Remove file on click
          >
            Remove
          </Button>
        </div>
      )}
      {fileError && <p className="text-danger mt-2">{fileError}</p>}
    </Form>
  )
}

export default UploadForm

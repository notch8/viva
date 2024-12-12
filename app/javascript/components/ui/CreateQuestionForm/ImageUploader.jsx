import React, { useRef } from 'react'
import { Form, InputGroup } from 'react-bootstrap'

const ImageUploader = ({ images, imageErrors, handleImageChange, handleRemoveImage }) => {
  const fileInputRef = useRef(null) // Ref for the file input field

  const handleRemoveImageWrapper = (index) => {
    handleRemoveImage(index)
    if (images.length === 1) {
      fileInputRef.current.value = null // Reset file input
    }
  }

  return (
    <div className='image-uploader'>
      <InputGroup className='my-4 text-uppercase csv-upload-form'>
        <InputGroup.Text className='strait py-3' htmlFor='file-upload'>
          Upload Image
        </InputGroup.Text>
        <Form.Group>
          <Form.Control
            type='file'
            id='file-upload'
            aria-label='Upload an image here'
            onChange={handleImageChange}
            className='rounded-0 py-3'
            ref={fileInputRef} // Attach ref for resetting
          />
        </Form.Group>
      </InputGroup>

      {imageErrors.length > 0 && (
        <div className='mt-2'>
          {imageErrors.map((error, index) => (
            <p key={index} className='text-danger'>{error}</p>
          ))}
        </div>
      )}

      <div className='mt-3'>
        {images.map((image, index) => (
          <div key={index} className='d-flex align-items-center mt-2'>
            <img
              src={image.preview}
              alt='Preview'
              style={{ width: '50px', height: '50px', objectFit: 'cover', marginRight: '10px' }}
            />
            <span className={`me-3 ${!image.isValid ? 'text-danger' : ''}`}>
              {image.file.name} {!image.isValid && '(Invalid)'}
            </span>
            <button
              type='button'
              className='btn btn-danger btn-sm ms-3'
              onClick={() => handleRemoveImageWrapper(index)}
            >
              Remove
            </button>
          </div>
        ))}
      </div>
    </div>
  )
}

export default ImageUploader

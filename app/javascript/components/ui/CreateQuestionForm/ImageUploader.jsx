import React, { useRef } from 'react'
import { Alert, Form, InputGroup } from 'react-bootstrap'
import { useForm } from '@inertiajs/inertia-react'

const ImageUploader = ({ images, setImages }) => {
  const fileInputRef = useRef(null)
  const { clearErrors, setError, errors } = useForm({ image: '', altText: '' })

  const handleRemoveImage = (index) => {
    setImages((prevImages) => {
      const image = prevImages[index]

      // If it's an existing image from the server, mark for deletion
      if (image.isExisting) {
        return prevImages.map((img, i) =>
          i === index
            ? { ...img, markedForDeletion: true }
            : img
        )
      }

      // If it's a new upload, remove it completely
      URL.revokeObjectURL(image.preview)
      return prevImages.filter((_, i) => i !== index)
    })

    if (images.length === 1 && fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  const handleChange = (e) => {
    const validExtensions = ['jpg', 'jpeg', 'png']
    const files = Array.from(e.target.files)
    const newImages = []

    files.forEach((file) => {
      const extension = file.name.split('.').pop().toLowerCase()
      if (validExtensions.includes(extension)) {
        newImages.push({
          file,
          preview: URL.createObjectURL(file),
          isValid: true,
          altText: ''
        })
      } else {
        setError('image', 'Please select a JPG, JPEG, or PNG to upload.')
        setTimeout(() => {
          clearErrors()
        }, 3000)
      }
    })

    setImages((prevImages) => [...prevImages, ...newImages])
    if (fileInputRef.current) {
      fileInputRef.current.value = '' // Reset the file input
    }
  }

  const handleAltTextChange = (index, altText) => {
    setImages((prevImages) => {
      const updatedImages = [...prevImages]
      updatedImages[index].altText = altText
      if (altText.trim()) {
        clearErrors('altText')
      }
      return updatedImages
    })
  }

  const validateAltText = (index) => {
    const image = images[index]
    if (!image.altText.trim()) {
      setError('altText', 'Alt text is required for all images')
      return false
    }
    return true
  }

  return (
    <div className='image-uploader'>
      <InputGroup className='my-4 text-uppercase upload-form'>
        <Form.Label
          className='strait py-2 input-group-text'
          htmlFor='file-upload'
        >
          Upload Image
        </Form.Label>
        <Form.Group className='flex-grow-1'>
          <Form.Control
            type='file'
            id='file-upload'
            aria-label='Upload an image here'
            onChange={handleChange}
            className='rounded-0 py-2'
            accept='image/jpeg, image/jpg, image/png'
            ref={fileInputRef}
          />
        </Form.Group>
      </InputGroup>

      {errors.image && (
        <Alert variant='danger' dismissible>
          {errors.image}
        </Alert>
      )}
      {errors.altText && (
        <Alert variant='danger' dismissible>
          {errors.altText}
        </Alert>
      )}

      {images
        .map((image, arrayIndex) => ({ image, arrayIndex }))
        .filter(({ image }) => !image.markedForDeletion)
        .map(({ image, arrayIndex }) => (
          <div key={arrayIndex} className='image-preview-container mb-3'>
            <div className='d-flex flex-column flex-md-row align-items-start align-items-md-center gap-2 w-100'>
              <div className='d-flex align-items-center gap-2 mb-2 mb-md-0'>
                <img
                  src={image.preview}
                  alt='Preview'
                  className='preview-image'
                  style={{ width: '40px', height: '40px', objectFit: 'cover' }}
                />
                <span
                  className={`filename ${!image.isValid ? 'text-danger' : ''}`}
                >
                  {image.file ? image.file.name : image.filename}{' '}
                  {!image.isValid && '(Invalid)'}
                </span>
              </div>

              <div className='d-flex flex-grow-1 gap-2 w-100'>
                <Form.Control
                  type='text'
                  placeholder='Enter alt text (required)'
                  name={'question[alt_text][]'}
                  value={image.altText}
                  onChange={(e) => handleAltTextChange(arrayIndex, e.target.value)}
                  className='flex-grow-1'
                  required
                  onBlur={() => validateAltText(arrayIndex)}
                />
                <button
                  type='button'
                  className='btn btn-danger btn-sm'
                  onClick={() => handleRemoveImage(arrayIndex)}
                >
                  Remove
                </button>
              </div>
            </div>
          </div>
        ))}
    </div>
  )
}

export default ImageUploader

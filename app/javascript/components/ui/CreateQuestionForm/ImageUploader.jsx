import React, { useRef } from 'react'
import { Alert, Form, InputGroup } from 'react-bootstrap'
import { useForm } from '@inertiajs/inertia-react'

const ImageUploader = ({ images, setImages }) => {
  const fileInputRef = useRef(null)
  const { clearErrors, setError, errors } = useForm({ image: '' })

  const handleRemoveImage = (index) => {
    setImages((prevImages) => {
      URL.revokeObjectURL(prevImages[index].preview)
      return prevImages.filter((_, i) => i !== index)
    })
    if (images.length === 1 && fileInputRef.current) {
      fileInputRef.current.value = '' // Reset file input if last image is removed
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
      return updatedImages
    })
  }

  return (
    <div className='image-uploader'>
      <InputGroup className='my-4 text-uppercase upload-form'>
        <InputGroup.Text className='strait py-3' htmlFor='file-upload'>
          Upload Image
        </InputGroup.Text>
        <Form.Group>
          <Form.Control
            type='file'
            id='file-upload'
            aria-label='Upload an image here'
            onChange={handleChange}
            className='rounded-0 py-3'
            accept='image/jpeg, image/jpg, image/png'
            ref={fileInputRef} // Attach ref for resetting
          />
        </Form.Group>
      </InputGroup>

      {errors.image && <Alert variant='danger' dismissible>{errors.image}</Alert>}

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
          <Form.Control
            type='text'
            placeholder='Enter alt text'
            name='question[alt_text]'
            value={image.altText}
            onChange={(e) => handleAltTextChange(index, e.target.value)}
            className='me-2'
          />
          <button
            type='button'
            className='btn btn-danger btn-sm ms-3'
            onClick={() => handleRemoveImage(index)}
          >
            Remove
          </button>
        </div>
      ))}
    </div>
  )
}

export default ImageUploader
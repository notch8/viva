import React from 'react'
import { Container, Form, InputGroup, Button } from 'react-bootstrap'
import { useForm } from '@inertiajs/inertia-react'
import { UploadSimple } from '@phosphor-icons/react'
import Layout from '../App'

const Uploads = () => {
  const { setData, post, processing, errors, clearErrors, recentlySuccessful, data, setError } = useForm({
    csv: ''
  })

  const submit = (e) => {
    clearErrors()
    e.preventDefault()
    if (data.csv.length === 0) {
      setError('csv', 'Please select a CSV to upload.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
    } else if (data.csv.slice(-3) !== 'csv') {
      setError('csv', 'Please select a file with a CSV extension.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
    } else {
      post('/uploads/create')
    }
  }
  console.log(errors)

  return (
    <Layout>
      <Container className='bg-light-1 rounded p-5'>
        <h2 className='h5 fw-bold'>Upload Questions</h2>
        <p>Upload a CSV here in the following format:</p>
        <p>Please make sure that your CSV matches the headers above in order to make a successful import.</p>
        <Form onSubmit={submit} className='csv-upload-form text-uppercase'>
          <InputGroup className="mb-3">
            <InputGroup.Text className='strait py-3'>
              Select a CSV to Upload
            </InputGroup.Text>
            <Form.Group controlId="upload-csv">
              <Form.Control
                type="file"
                aria-label="Upload a CSV here"
                onChange={e => setData('csv', e.target.value)}
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
        {recentlySuccessful &&
          <div className='alert alert-success'>
            Your CSV has been uploaded successfully!
          </div>
        }
        {errors.csv &&
          <div className='alert alert-danger'>
            <span>{errors.csv}</span>
          </div>
        }
      </Container>
    </Layout>
  )
}

export default Uploads

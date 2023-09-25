import React from 'react'
import { Container, Button } from 'react-bootstrap'
import { useForm } from '@inertiajs/inertia-react'
import UploadForm from '../../ui/UploadForm/UploadForm'
import Layout from '../../App'

const Uploads = (props) => {
  let responseErrors = props.errors
  const { setData, post, processing, clearErrors, recentlySuccessful, data, setError, errors } = useForm({
    csv: ''
  })

  const submit = (e) => {
    clearErrors()
    let fileName = data.csv && data.csv[0].name
    e.preventDefault()
    if (fileName.length === 0) {
      setError('csv', 'Please select a CSV to upload.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
    } else if (fileName.slice(-3) !== 'csv') {
      setError('csv', 'Please select a file with a CSV extension.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
    } else {
      post('/uploads/create')
    }
  }

  return (
    <Layout>
      <Container className='bg-light-1 rounded p-5'>
        <h2 className='h5 fw-bold'>Upload Questions</h2>
        <span className='d-block'>Upload a CSV here using the following format:</span>
        <Button className='my-4'>Download CSV Example Format</Button>
        <p>Please make sure that your CSV matches the headers in the example above in order to make a successful import.</p>
        <p>If the format of your CSV is incorrect, the errors will be displayed below the form. Note that the error displayed will be the first error that is found in your CSV row, as the CSV will not continue to process the row after hitting an error.</p>
        <UploadForm submit={submit} setData={setData} processing={processing} />
        {recentlySuccessful &&
          <div className='alert alert-success'>
            Your CSV has been uploaded successfully!
          </div>
        }
        {/* TODO: Update how errors are displayed */}
        {(errors.csv || responseErrors?.length > 0) &&
          <div className='alert alert-danger'>
            {errors.csv ? (
              <span>{errors.csv}</span>
            ) : (
              <>
                <p>The following errors occured during your import. Please correct them and try again.</p>
                {responseErrors.map((error, index) => (
                  // TODO: update this when error handing for headers are added
                  <p key={index} className='small'>
                    <span><b>Row with import ID {error.row.IMPORT_ID}:</b> {error.errors.base}</span>
                  </p>
                ))}
              </>
            )}
          </div>
        }
      </Container>
    </Layout>
  )
}

export default Uploads

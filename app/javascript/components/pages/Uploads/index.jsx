import React, { useState } from 'react'
import {
  Container, Button, Alert, Dropdown, ButtonGroup, SplitButton, Form
} from 'react-bootstrap'
import { useForm } from '@inertiajs/inertia-react'
import UploadForm from '../../ui/UploadForm/UploadForm'
import Layout from '../../App'
import CustomDropdown from '../../ui/CustomDropdown'
import { QUESTION_TYPE_NAMES } from '../../../constants/questionTypes'

const Uploads = (props) => {
  let responseErrors = props.errors
  const typeNamesFromPublicFiles = ['traditional', 'bow_tie', 'drag_and_drop', 'sata', 'matching']
  const { setData, post, processing, clearErrors, recentlySuccessful, data, setError, errors } = useForm({
    csv: ''
  })

  const [selectedType, setSelectedType] = useState('Bow Tie')

  const handleTypeSelect = (type) => {
    setSelectedType(type)
  }

  const submit = (e) => {
    clearErrors()
    let fileName = data.csv && data.csv[0].name
    e.preventDefault()
    if (fileName.length === 0) {
      setError('csv', 'Please select a CSV or ZIP to upload.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
    } else if (fileName.slice(-3) !== 'csv' && fileName.slice(-3) !== 'zip') {
      setError('csv', 'Please select a file with a CSV or ZIP extension.')
      setTimeout(() => {
        clearErrors()
      }, 3000)
    } else {
      post('/uploads')
    }
  }

  return (
    <Layout>
      <Container className='bg-light-1 rounded p-5'>
        {/* Upload Questions Section */}
        <h2 className='h5 fw-bold'>Upload Questions</h2>
        <span className='d-block'>Upload a CSV here using the following format:</span>
        <ButtonGroup className='my-4'>
          <Button
            id='download-csv-example'
            href='/example-csv-all-questions.csv'>
                Download CSV Example Format
          </Button>
          <CustomDropdown dropdownSelector='.question-type-csvs-button-group'>
            <SplitButton
              className='question-type-csvs-button-group'
              as={ButtonGroup}
              id='question-type-csvs-dropdown'
              title='Download CSV for Specific Question Type'
              align={{ lg: 'start' }}
              variant='secondary'>
              {typeNamesFromPublicFiles.map((typeName) => (
                <Dropdown.Item key={typeName} href={`/valid_${typeName}_question.csv`}>Download {typeName} CSV</Dropdown.Item>
              ))}
            </SplitButton>
          </CustomDropdown>
        </ButtonGroup>
        <p>Please make sure that your CSV matches the headers in the example above in order to make a successful import.</p>
        <p>If the format of your CSV is incorrect, the errors will be displayed below the form. Note that the error displayed will be the first error that is found in your CSV, as the CSV will not continue to process the row after hitting an error.</p>
        <UploadForm submit={submit} setData={setData} processing={processing} />
        {recentlySuccessful &&
          <div className='alert alert-success'>
            Your file has been uploaded successfully!
          </div>
        }
        {(errors.csv || (responseErrors && Object.keys(responseErrors).length > 0)) &&
          <Alert variant='danger' dismissible>
            {/* NOTE: there are 2 types of errors here, frontend, presubmit errors which are stored periodically in errors.csv, and responseErrors which only appear after the form is submitted */}
            {/* presubmit errors */}
            {errors?.csv && <span>{errors?.csv}</span>}
            {(responseErrors && Object.keys(responseErrors).length > 0) &&
              <>
                <p>The following errors occurred during your import. Please correct them and try again.</p>
                {/* errors on the csv level (checks for headers) */}
                {responseErrors?.csv?.missing &&
                  <>
                    <p className='small'>
                      The CSV had missing headers. Please add the following headers to import successfully:</p>
                    {responseErrors?.csv?.missing?.map((missingHeader, index) => (
                      <small key={index}>
                        <span><b>{missingHeader}</b></span>{index < responseErrors?.csv?.missing?.length - 1 && <span>, </span>}
                      </small>
                    ))}
                  </>
                }
                {/* errors on the row level */}
                {responseErrors?.rows && responseErrors.rows.map((row, index) => (
                  <p key={index} className='small'>
                    <span><b>Row with import ID {row.import_id}:</b> {row.base ? [row.base].flat().join('; '): 'Please check that all data is entered correctly in each cell'}</span>
                  </p>
                ))}
              </>
            }
          </Alert>
        }

        {/* Create a Question Section */}
        <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
        <Form>
          <Form.Group controlId='questionType'>
            <Form.Label>Select Question Type</Form.Label>
            <CustomDropdown dropdownSelector='.question-type-dropdown'>
              <Dropdown onSelect={handleTypeSelect} className='question-type-dropdown'>
                <Dropdown.Toggle variant='secondary'>{selectedType}</Dropdown.Toggle>
                <Dropdown.Menu>
                  {QUESTION_TYPE_NAMES.map(({ key, value }) => (
                    <Dropdown.Item key={key} eventKey={value}>
                      {value}
                    </Dropdown.Item>
                  ))}
                </Dropdown.Menu>
              </Dropdown>
            </CustomDropdown>
          </Form.Group>
        </Form>
      </Container>
    </Layout>
  )
}

export default Uploads

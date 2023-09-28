import React, {useState} from 'react'
import {
  Container, Row, Col, Button, CloseButton, Alert, ProgressBar, Form
} from 'react-bootstrap'

const SearchFilters = (props) => {
  const { selectedSubjects, selectedKeywords, selectedTypes, selectedLevels, submit, handleFilters, useForm, exportURL, errors } = props
  const filterArray = [selectedSubjects, selectedKeywords, selectedTypes, selectedLevels]

  const { get, processing, clearErrors, recentlySuccessful, progress, setData, reset } = useForm({
    selected_keywords: selectedKeywords,
    selected_subjects: selectedSubjects,
    selected_types: selectedTypes,
    selected_levels: selectedLevels,
    export: null
  })

  const arrayHasItems = (array) => array.length > 0
  const hasFilters =
    arrayHasItems(selectedSubjects) ||
    arrayHasItems(selectedKeywords) ||
    arrayHasItems(selectedTypes) ||
    arrayHasItems(selectedLevels)

  const removeFilterAndSearch = (event, item, filter) => {
    handleFilters({ target: { value: item } }, filter === selectedSubjects ? 'subjects' : filter === selectedKeywords ? 'keywords' : filter === selectedTypes ? 'types' : 'levels')
    submit(event)
  }

  // this may need to be async as the exportURL will come as part of a response
  const handleExport = (e) => {
    clearErrors()
    e.preventDefault()
    get('/');
    if (exportURL) {
      console.log('here')
      const downloadLink = document.createElement('a');
      downloadLink.href = exportURL;
      downloadLink.target = '_blank'; // Open in a new tab
      downloadLink.download = 'questions.csv'
      downloadLink.click();
    }
    reset('export')
  }

  console.log({exportURL})

  return (
    hasFilters &&
    <>
      <Container className='bg-light-1 rounded p-0 search-filters'>
        <Row>
          <Col md={3} className='d-flex justify-content-center align-items-center text-center p-2 border-end'>
            <h2 className='h5 fw-bold'>Selected Filters</h2>
          </Col>
          <Col md={9} className='ps-md-0'>
            <Container>
              <Row className='py-2'>
                {filterArray.map((filter, index) => (
                  arrayHasItems(filter) && (
                    <Col key={index} sm={6}>
                      <h3 className='fw-bold h6'>
                        {filter === selectedSubjects ? 'Subjects' :
                          filter === selectedKeywords ? 'Keywords' :
                            filter === selectedTypes ? 'Types' :
                              'Levels'}
                      </h3>
                      {filter.map((item, itemIndex) => (
                        <div key={itemIndex} className='m-1 btn bg-white text-lowercase d-inline-flex align-items-center'>
                          <label>{item}</label>
                          <CloseButton
                            aria-label={`Remove filter for ${item}`}
                            onClick={(event) => removeFilterAndSearch(event, item, filter)}
                            className='ms-2'
                          />
                        </div>
                      ))}
                    </Col>
                  )
                ))}
              </Row>
            </Container>
            <Col className='d-flex justify-content-center justify-content-md-end align-items-end border-top bg-light-2 p-2'>
              <Form onSubmit={handleExport}>
                <Button
                  onClick={(() => setData('export', true))}
                  type='submit'
                  disabled={processing}>
                    Export All Questions
                </Button>
              </Form>
            </Col>
          </Col>
        </Row>
      </Container>
      {(processing && progress) &&
        <ProgressBar now={progress.percentage} dismissible variant='info'>
          Your export is being processed.
        </ProgressBar>
      }
      {recentlySuccessful &&
        <Alert dismissible variant='success'>
          Your export completed successfully.
        </Alert>
      }
      {errors &&
      // TODO: more error handling here depending on what errors are returned
        <Alert dismissible variant='danger'>
          An error occurred while processing your export.
        </Alert>
      }
    </>
  )
}

export default SearchFilters

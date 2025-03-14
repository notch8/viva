import React from 'react'
import {
  Container, Row, Col, CloseButton, Alert, Button
} from 'react-bootstrap'
import { Inertia } from '@inertiajs/inertia'

const SearchFilters = (props) => {
  const { filteredQuestions, selectedSubjects, selectedKeywords, selectedTypes, selectedLevels, submit, handleFilters, errors } = props
  const filterArray = [selectedSubjects, selectedKeywords, selectedTypes, selectedLevels]

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

  const handleBookmarkBatch = () => {
    const filteredIds = filteredQuestions.map(question => question.id).join(',')
    Inertia.post('/bookmarks/create_batch', { filtered_ids: filteredIds }, {
      onSuccess: () => {
        console.log('Bookmarks added successfully')
      },
      onError: () => {
        console.error('Error adding bookmarks')
      }
    })
  }

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
              <Button
                className='p-2'
                onClick={handleBookmarkBatch}
              >
                Bookmark Filtered
              </Button>
            </Col>
          </Col>
        </Row>
      </Container>
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

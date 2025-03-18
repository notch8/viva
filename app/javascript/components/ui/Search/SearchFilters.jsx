import React from 'react'
import {
  Container, Row, Col, CloseButton, Alert, Button
} from 'react-bootstrap'

const SearchFilters = ({
  selectedSubjects,
  selectedKeywords,
  selectedTypes,
  selectedLevels,
  removeFilterAndSearch,
  onBookmarkBatch,
  errors
}) => {

  // Create an array of filter objects with their display names
  const filters = [
    { name: 'Subjects', items: selectedSubjects },
    { name: 'Keywords', items: selectedKeywords },
    { name: 'Types', items: selectedTypes },
    { name: 'Levels', items: selectedLevels }
  ]

  const hasItems = array => Array.isArray(array) && array.length > 0

  const hasFilters = hasItems(selectedSubjects) ||
    hasItems(selectedKeywords) ||
    hasItems(selectedTypes) ||
    hasItems(selectedLevels)

  // If there are no filters, don't render the component
  if (!hasFilters) return null

  return (
    <>
      <Container className='bg-light-1 rounded p-0 search-filters'>
        <Row>
          <Col md={3} className='d-flex justify-content-center align-items-center text-center p-2 border-end'>
            <h2 className='h5 fw-bold'>Selected Filters</h2>
          </Col>
          <Col md={9} className='ps-md-0'>
            <Container>
              <Row className='py-2'>
                {filters.map((filter, index) => (
                  hasItems(filter.items) && (
                    <Col key={index} sm={6}>
                      <h3 className='fw-bold h6'>{filter.name}</h3>
                      {filter.items.map((item, itemIndex) => (
                        <div key={itemIndex} className='m-1 btn bg-white text-lowercase d-inline-flex align-items-center'>
                          <label>{item}</label>
                          <CloseButton
                            aria-label={`Remove filter for ${item}`}
                            onClick={() => removeFilterAndSearch(item, filter.name)}
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
                onClick={onBookmarkBatch}
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

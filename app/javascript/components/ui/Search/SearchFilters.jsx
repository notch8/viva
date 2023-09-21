import React from 'react'
import {
  Container, Row, Col, Button, CloseButton
} from 'react-bootstrap'

const SearchFilters = (props) => {
  // TODO: set up levels
  const { selectedCategories, selectedKeywords, selectedTypes, submit, handleFilters } = props
  const filterArray = [selectedCategories, selectedKeywords, selectedTypes]

  const arrayHasItems = (array) => array.length > 0
  const hasFilters =
    arrayHasItems(selectedCategories) ||
    arrayHasItems(selectedKeywords) ||
    arrayHasItems(selectedTypes)

  const removeFilterAndSearch = (event, item, filter) => {
    handleFilters({ target: { value: item } }, filter === selectedCategories ? 'categories' : filter === selectedKeywords ? 'keywords' : filter === selectedTypes ? 'types' : 'levels')
    submit(event)
  }

  return (
    hasFilters &&
      <Container className='bg-light-1 rounded p-0 search-filters'>
        <Row>
          <Col sm={3} className='d-flex justify-content-center align-items-center text-center p-2 border-end'>
            <h2 className='h5 fw-bold'>Selected Filters</h2>
          </Col>
          <Col sm={9}>
            <Container>
              <Row className='py-2'>
                {filterArray.map((filter, index) => (
                  arrayHasItems(filter) && (
                    <Col key={index} sm={6}>
                      <h3 className='fw-bold h6'>
                        {filter === selectedCategories ? 'Categories' : filter === selectedKeywords ? 'Keywords' : 'Types'}
                      </h3>
                      {filter.map((item, itemIndex) => (
                        <div key={itemIndex} className='m-1 btn bg-white text-lowercase d-inline-flex align-items-center' variant='secondary'>
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
            <Col className='d-flex justify-content-end align-items-end border-top bg-light-2 p-2'>
              <Button>Export All Questions</Button>
            </Col>
          </Col>
        </Row>
      </Container>
  )
}

export default SearchFilters

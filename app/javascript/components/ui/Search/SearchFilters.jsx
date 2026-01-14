import React from 'react'
import {
  Container, Row, Col, CloseButton, Alert, Button
} from 'react-bootstrap'

const SearchFilters = ({
  selectedSubjects,
  selectedKeywords,
  selectedTypes,
  selectedLevels,
  selectedUsers,
  users,
  removeFilterAndSearch,
  onBookmarkBatch,
  errors
}) => {
  const getUserEmail = (userId) => {
    if (!users || !Array.isArray(users)) return userId
    const user = users.find(u => u.id === parseInt(userId, 10) || u.id === userId)
    return user ? user.email : userId
  }

  // Create an array of filter objects with their display names
  const filters = [
    { name: 'Subjects', items: selectedSubjects },
    { name: 'Keywords', items: selectedKeywords },
    { name: 'Types', items: selectedTypes },
    { name: 'Levels', items: selectedLevels }
  ]

  if (selectedUsers && Array.isArray(selectedUsers) && selectedUsers.length > 0) {
    filters.push({
      name: 'Users',
      items: selectedUsers.map(userId => ({
        id: userId,
        display: getUserEmail(userId)
      }))
    })
  }

  const hasItems = array => Array.isArray(array) && array.length > 0

  const hasFilters = hasItems(selectedSubjects) ||
    hasItems(selectedKeywords) ||
    hasItems(selectedTypes) ||
    hasItems(selectedLevels) ||
    hasItems(selectedUsers)

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
                      {filter.items.map((item, itemIndex) => {
                        const displayValue = filter.name === 'Users' ? item.display : item
                        const filterValue = filter.name === 'Users' ? item.id : item

                        return (
                          <div key={itemIndex} className='m-1 btn bg-white text-lowercase d-inline-flex align-items-center'>
                            <label>{displayValue}</label>
                            <CloseButton
                              aria-label={`Remove filter for ${displayValue}`}
                              onClick={() => removeFilterAndSearch(filterValue, filter.name)}
                              className='ms-2'
                            />
                          </div>
                        )
                      })}
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

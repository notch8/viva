import React from 'react'
import { Container, Row, Col, Button } from 'react-bootstrap'

const SearchFilters = (props) => {
  return (
    <Container className='bg-light-1 rounded d-flex p-0'>
      <Col sm={4} className='justify-content-center align-items-center text-center p-2'>
        <h2 className='h5 fw-bold'>Selected Filters</h2></Col>
      <Col sm={8} className='p-2'>
        <Col>FIlters here</Col>
        <Col className='d-flex justify-content-end align-items-end'>
          <Button>Export All Questions</Button>
        </Col>
      </Col>
    </Container>
  )
}

export default SearchFilters

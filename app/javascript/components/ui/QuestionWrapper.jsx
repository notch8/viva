import React, { useState } from 'react'
import { Collapse, Button, Container, Row, Col } from 'react-bootstrap'
import { Plus, Minus } from "@phosphor-icons/react";

const QuestionWrapper = (props) => {
  const [open, setOpen] = useState(false)
  const { question } = props
  return (
    <Container className="bg-light-1 rounded container p-4 mt-4">
      <Row>
        <Col md={7} className='p-2'>
          <h6 className="fw-bold">Question</h6>
          <p>{question.text}</p>
          <Collapse in={open}>
            <div id='question-wrapper'>
              <p class="fw-bold">Answers</p>
              <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>
              <p>Suspendisse vel libero sed nisi fermentum tempor.</p>
              <p>Curabitur dolor magna, rhoncus malesuada sapien ac, laoreet rhoncus dolor.</p>
              <p>Nulla auctor massa ac gravida sagittis.</p>
            </div>
          </Collapse>
        </Col>
        <Col md={4} className='px-0'>
          <div className='bg-light-2 p-2 rounded'>
            <h6 className="fw-bold">Keywords</h6>
            {question.keywords.map((keyword) => {
              return (
                <div
                  className='m-1 btn bg-white text-lowercase'
                  variant='secondary'
                >
                  {keyword}
                </div>
              )
            })}
            <div className='d-flex mx-1 text-center mt-5'>
              <Col className='bg-white rounded-start p-2'>
                <h6 className="fw-bold">Level</h6>
                <span className='strait small'>{question.level}</span>
              </Col>
              <Col className='bg-light-3 rounded-end p-2'>
                <h6 className="fw-bold">Type</h6>
                <span className='strait small'>{question.type.substring(10)}</span>
              </Col>
            </div>
          </div>
        </Col>
        <Col sm={1} className='d-flex align-items-center'>
          <Button
            onClick={() => setOpen(!open)}
            aria-controls='question-wrapper'
            aria-expanded={open}
            className='mx-2 mt-2 rounded-circle btn btn-secondary d-flex px-1 py-1 border'
            variant='secondary'
            >
            { open ? <Minus /> : <Plus /> }
          </Button>
        </Col>
      </Row>
    </Container>
  )
}

export default QuestionWrapper

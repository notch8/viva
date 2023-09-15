import React, { useState } from 'react'
import { Collapse, Button, Container, Row, Col } from 'react-bootstrap'
import { Plus, Minus } from "@phosphor-icons/react";
import QuestionMetadata from './QuestionMetadata'

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
          <QuestionMetadata question={question} />
        </Col>
        <Col sm={1} className='d-flex align-items-center justify-content-center'>
          <Button
            onClick={() => setOpen(!open)}
            aria-controls='question-wrapper'
            aria-expanded={open}
            className='mx-2 mt-2 rounded-circle d-flex px-1 py-1 bg-light-4 border-0'
            >
            { open ? <Minus size={20} weight="bold"  /> : <Plus size={20} weight="bold" /> }
          </Button>
        </Col>
      </Row>
    </Container>
  )
}

export default QuestionWrapper

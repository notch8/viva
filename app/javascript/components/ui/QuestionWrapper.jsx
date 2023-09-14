import React, { useState } from 'react'
import { Collapse, Button, Container, Row, Col } from 'react-bootstrap'
import { Plus, Minus } from "@phosphor-icons/react";

const QuestionWrapper = (props) => {
  const [open, setOpen] = useState(false)
  const { question } = props
  return (
    <Container className="bg-light-1 rounded container p-4 mt-4">
      <Row>
        <Col sm={6}>
          <p class="fw-bold">Question</p>
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
        <Col sm={5}>
          <div>Keywords</div>
        </Col>
        <Col sm={1}>
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

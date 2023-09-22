import React from 'react'
import { Col } from 'react-bootstrap'

const QuestionMetadata = ({ question }) => {
  return (
    <div className='bg-light-2 p-2 rounded'>
      <h6 className='fw-bold'>Keywords</h6>
      {question.keyword_names.map((keyword, index) => {
        return (
          <div
            className='m-1 btn bg-white text-lowercase'
            key={index}
          >
            {keyword}
          </div>
        )
      })}
      <div className='d-flex mx-1 text-center mt-5'>
        <Col className='bg-white rounded-start p-2'>
          <h6 className='fw-bold'>Level</h6>
          <span className='strait small'>{question.level}</span>
        </Col>
        <Col className='bg-light-3 rounded-end p-2'>
          <h6 className='fw-bold'>Type</h6>
          <span className='strait small'>{question.type.substring(10)}</span>
        </Col>
      </div>
    </div>
  )
}

export default QuestionMetadata

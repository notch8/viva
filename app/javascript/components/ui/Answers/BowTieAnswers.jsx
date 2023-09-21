import React from 'react'
import { Col } from 'react-bootstrap'
import { ArcherContainer, ArcherElement } from 'react-archer'
import IncorrectAnswers from '../IncorrectAnswers/ThreeColumnTable'

const BowTieAnswers = ({ answers }) => {
  const { center, left, right } = answers
  const centerCorrectAnswers = center.answers.filter(answer => answer.correct)
  const leftCorrectAnswers = left.answers.filter(answer => answer.correct)
  const rightCorrectAnswers = right.answers.filter(answer => answer.correct)
  const leftIncorrectAnswers = {
    label: left.label,
    answers: left.answers.filter(answer => !answer.correct)
  }
  const centerIncorrectAnswers = {
    label: center.label,
    answers: center.answers.filter(answer => !answer.correct)
  }
  const rightIncorrectAnswers = {
    label: right.label,
    answers: right.answers.filter(answer => !answer.correct)
  }

  return (
    <>
      <ArcherContainer
        strokeColor='black'
        strokeWidth='1'
        arrowLength='0px'
        lineStyle='angle'
        endMarker={false}
      >
        <div className='bowtie-answers row text-center'>
          <Col className='d-flex flex-column justify-content-between'>
            {leftCorrectAnswers && leftCorrectAnswers.map((leftAnswer, index) => (
              <ArcherElement
                key={`left-answer-${index}`}
                id={`left-answer-${index}`}
                relations={[{
                  targetId: 'center-answer',
                  offset: '2',
                  targetAnchor: 'left',
                  sourceAnchor: 'right',
                }]}
              >
                <div className='left-answer bg-light-4 p-2 m-2 rounded' key={index}>
                  {leftAnswer.answer}
                </div>
              </ArcherElement>
            ))}
          </Col>
          <Col className='d-flex align-items-center'>
            {centerCorrectAnswers && centerCorrectAnswers.map((centerAnswer, index) => (
              <ArcherElement id='center-answer' key={`center-answer-${index}`}>
                <div className='center-answer p-2 m-2 rounded bg-primary text-white' key={index}>
                  {centerAnswer.answer}
                </div>
              </ArcherElement>
            ))}
          </Col>
          <Col className='d-flex flex-column justify-content-between'>
            {rightCorrectAnswers && rightCorrectAnswers.map((rightAnswer, index) => (
              <ArcherElement
                key={`right-answer-${index}`}
                id={`right-answer-${index}`}
                relations={[{
                  targetId: 'center-answer',
                  targetAnchor: 'right',
                  sourceAnchor: 'left',
                }]}
              >
                <div className='right-answer bg-light-4 p-2 m-2 rounded' key={index}>
                  {rightAnswer.answer}
                </div>
              </ArcherElement>
            ))}
          </Col>
        </div>
      </ArcherContainer>
      <IncorrectAnswers
        incorrectAnswers={[leftIncorrectAnswers, centerIncorrectAnswers, rightIncorrectAnswers]}
      />
    </>
  )
}

export default BowTieAnswers

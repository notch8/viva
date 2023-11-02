import React from 'react'

const Question = ({ text, title = 'Question' }) => {
  return (
    <div className='question'>
      <h2 className='h6 fw-bold'>{title}</h2>
      <p>{text}</p>
    </div>
  )
}

export default Question

import React from 'react'

const Question = ({ text }) => {
  return (
    <div class='question'>
      <h2 className='h6 fw-bold'>Question</h2>
      <p>{text}</p>
    </div>
  )
}

export default Question

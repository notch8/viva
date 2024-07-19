import React from 'react'

const Question = ({ text, title = 'Question', images }) => {
  return (
    <div className='question'>
      <h2 className='h6 fw-bold'>{title}</h2>
      {images && images.map((image, index) => {
        return (
          <img key={index} src={image.url} alt={image.alt_text} className='w-75 my-4'/>
        )
      })}
      <p>{text}</p>
    </div>
  )
}

export default Question

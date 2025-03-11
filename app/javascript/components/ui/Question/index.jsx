import React from 'react'

const Question = ({ text, title = 'Question', images }) => {
  return (
    <div className='question'>
      <h2 className='h6 fw-bold'>{title}</h2>
      {images && images.map((image, index) => {
        return (
          <div key={index} className='image-container'>
            <img src={image.url} alt={image.alt_text} className='w-75 my-4'/>
            {image.alt_text && (
              <p className='text-muted small mt-2'>Alt text: {image.alt_text}</p>
            )}
          </div>
        )
      })}
      <p>{text}</p>
    </div>
  )
}

export default Question

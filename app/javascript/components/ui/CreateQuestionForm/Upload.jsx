import React from 'react'
import QuestionText from './QuestionText'
import ReactQuill from 'react-quill'
import 'react-quill/dist/quill.snow.css'

const Upload = ({ handleTextChange, onDataChange, questionType, questionText, data }) => {
  const handleDataChange = (content) => {
    onDataChange(content)
  }

  return (
    <>
      <h3>{questionType} Question</h3>
      <QuestionText
        questionText={questionText}
        handleTextChange={handleTextChange}
        formLabel='Enter Short Description'
        placeHolder='Enter your short description here'
        inputType='input'
        controlId='questionDescription'
      />
      <div className='mb-4'>
        <label className='h6 fw-bold'>Enter Question Text</label>
        <p>*Required Field</p>
        <ReactQuill
          value={data || ''}
          onChange={handleDataChange}
          theme='snow'
          placeholder='Enter your question text here'
          style={{ height: '250px', marginBottom: '50px' }}
        />
      </div>
    </>
  )
}

export default Upload

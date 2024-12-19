import React, { useState } from 'react'
import { Form, Button } from 'react-bootstrap'
import Bowtie from './Bowtie'
import Categorization from './Categorization'
import DragAndDrop from './DragAndDrop'
import Essay from './Essay'
import Matching from './Matching'
import MultipleChoice from './MultipleChoice'
import SelectAllThatApply from './SelectAllThatApply'
import QuestionTypeDropdown from './QuestionTypeDropdown'
import LevelDropdown from './LevelDropdown'
import Keyword from './Keyword'
import Subject from './Subject'
import ImageUploader from './ImageUploader'

const CreateQuestionForm = () => {
  const [questionType, setQuestionType] = useState('')
  const [questionText, setQuestionText] = useState('')
  const [images, setImages] = useState([])
  const [level, setLevel] = useState('')
  const [keywords, setKeywords] = useState([])
  const [subjects, setSubjects] = useState([])
  const [data, setData] = useState(null)
  const [resetFields, setResetFields] = useState(false)

  const COMPONENT_MAP = {
    'Bow Tie': Bowtie,
    'Categorization': Categorization,
    'Drag and Drop': DragAndDrop,
    'Essay': Essay,
    'Matching': Matching,
    'Multiple Choice': MultipleChoice,
    'Select All That Apply': SelectAllThatApply
  }

  const QuestionComponent = COMPONENT_MAP[questionType] || null

  const handleQuestionTypeSelection = (type) => {
    setQuestionType(type)
    setData(null)
    setResetFields(true)
  }

  const handleTextChange = (e) => setQuestionText(e.target.value)

  const handleAddKeyword = (keyword) => setKeywords([...keywords, keyword])
  const handleRemoveKeyword = (keywordToRemove) =>
    setKeywords(keywords.filter((keyword) => keyword !== keywordToRemove))

  const handleLevelSelection = (levelData) => setLevel(levelData)

  const handleAddSubject = (subject) => setSubjects([...subjects, subject])
  const handleRemoveSubject = (subjectToRemove) =>
    setSubjects(subjects.filter((subject) => subject !== subjectToRemove))

  const formatFormData = () => {
    const formData = new FormData();
    formData.append('question[type]', questionType);
    formData.append('question[level]', level);
    formData.append('question[text]', questionText);
  
    // Handle data based on question type
    if (questionType === 'Matching' || questionType === 'Categorization') {
      formData.append('question[data]', JSON.stringify(data));
    } else if (questionType === 'Essay') {
      const formattedData = {
        html: questionText.split('\n').map((line, index) => `<p key=${index}>${line}</p>`).join(''),
      };
      formData.append('question[data]', JSON.stringify(formattedData));
    } else if (questionType === 'Drag and Drop' && Array.isArray(data)) {
      const validData = data.filter((item) => item.answer.trim() !== '');
      formData.append('question[data]', JSON.stringify(validData));
    } else if (questionType === 'Bow Tie' && data) {
      const jsonData = JSON.stringify(data);
      formData.append('question[data]', jsonData);
    } else if (questionType === 'Multiple Choice' && Array.isArray(data)) {
      const validData = data.filter((item) => item.answer.trim() !== '');
      formData.append('question[data]', JSON.stringify(validData));
    } else if (questionType === 'Select All That Apply' && Array.isArray(data)) {
      const validData = data.filter((item) => item.answer.trim() !== '');
      formData.append('question[data]', JSON.stringify(validData));
    }
  
    images.forEach(({ file }) => formData.append('question[images][]', file));
    keywords.forEach((keyword) => formData.append('question[keywords][]', keyword));
    subjects.forEach((subject) => formData.append('question[subjects][]', subject));
  
    return formData;
  };
  

  const handleSubmit = async (e) => {
    e.preventDefault()

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        body: formatFormData()
      })
      if (response.ok) {
        alert('Question saved successfully!')
        resetForm()
      } else {
        const errorData = await response.json()
        alert(`Failed to save the question: ${errorData.errors?.join(', ')}`)
      }
    } catch (error) {
      console.error('Error saving the question:', error)
      alert('An error occurred while saving the question.')
    }
  }

  const resetForm = () => {
    setQuestionType('')
    setQuestionText('')
    setImages([])
    setLevel('')
    setKeywords([])
    setSubjects([])
    setData(null)
    setResetFields(true)
  }

  const isSubmitDisabled = () => {
    if (!questionText || images.some((image) => !image.isValid)) return true;
  
    if (questionType === 'Matching' || questionType === 'Categorization') {
      if (!data || !Array.isArray(data)) return true;
      const isInvalid = data.some(
        (item) =>
          !item.answer.trim() || // Ensure category/answer has text
          !item.correct || // Ensure 'correct' exists
          !Array.isArray(item.correct) || // Ensure 'correct' is an array
          item.correct.some((match) => !match.trim()) // Ensure all correct matches are non-empty
      );
      if (isInvalid) return true;
    }
  
    if (questionType === 'Drag and Drop') {
      if (!data || !Array.isArray(data) || !data.some((item) => item.correct && item.answer.trim())) {
        return true;
      }
    }
  
    if (questionType === 'Multiple Choice') {
      if (!data || !Array.isArray(data)) return true;
      const correctCount = data.filter((item) => item.correct).length;
      if (correctCount !== 1) return true; // Must have exactly 1 correct answer
    }
  
    if (questionType === 'Select All That Apply') {
      if (!data || !Array.isArray(data)) return true;
      const correctCount = data.filter((item) => item.correct).length;
      if (correctCount < 1) return true; // Must have at least 1 correct answer
    }
  
    return false;
  };

  return (
    <div className='create-question-form'>
      <h2 className='h5 fw-bold mt-5'>Create a Question</h2>
      <QuestionTypeDropdown handleQuestionTypeSelection={handleQuestionTypeSelection} />

      {QuestionComponent && (
        <div className='question-body bg-white mt-4 p-4'>
          <Form onSubmit={handleSubmit} className='question-form mx-4'>
            <div className='d-flex flex-wrap'>
              <div className='flex-fill'>
                <QuestionComponent
                  questionText={questionText}
                  handleTextChange={handleTextChange}
                  onDataChange={setData}
                  resetFields={resetFields}
                />
                <ImageUploader
                  images={images}
                  setImages={setImages}
                />
              </div>
              <div className='tag-section m-4'>
                <Keyword
                  keywords={keywords}
                  handleAddKeyword={handleAddKeyword}
                  handleRemoveKeyword={handleRemoveKeyword}
                />
                <Subject
                  subjects={subjects}
                  handleAddSubject={handleAddSubject}
                  handleRemoveSubject={handleRemoveSubject}
                />
                <LevelDropdown handleLevelSelection={handleLevelSelection} />
              </div>
            </div>
            
            <Button
              type='submit'
              className='btn btn-primary mt-3'
              disabled={isSubmitDisabled()}
            >
              Submit
            </Button>
          </Form>
        </div>
      )}
    </div>
  )
}

export default CreateQuestionForm

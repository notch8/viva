import React, { useState } from 'react';
import { Form, Button } from 'react-bootstrap';
import Bowtie from './Bowtie';
import Essay from './Essay';
import DragAndDrop from './DragAndDrop';
import QuestionTypeDropdown from './QuestionTypeDropdown';
import LevelDropdown from './LevelDropdown';
import Keyword from './Keyword';
import Subject from './Subject';
import ImageUploader from './ImageUploader';

const CreateQuestionForm = () => {
  const [questionType, setQuestionType] = useState('');
  const [questionText, setQuestionText] = useState('');
  const [images, setImages] = useState([]);
  const [imageErrors, setImageErrors] = useState([]);
  const [level, setLevel] = useState('');
  const [keywords, setKeywords] = useState([]);
  const [subjects, setSubjects] = useState([]);
  const [data, setData] = useState(null);
  const [resetFields, setResetFields] = useState(false);

  const COMPONENT_MAP = {
    'Essay': Essay,
    'Bow Tie': Bowtie,
    'Drag and Drop': DragAndDrop,
  };
  const QuestionComponent = COMPONENT_MAP[questionType] || null;

  const handleQuestionTypeSelection = (type) => {
    setQuestionType(type);
    setData(null);
    setResetFields(true);
  };

  const handleTextChange = (e) => setQuestionText(e.target.value);

  const handleImageChange = (e) => {
    const validExtensions = ['jpg', 'jpeg', 'png'];
    const files = Array.from(e.target.files);
    const newImages = [];
    const newErrors = [];

    files.forEach((file) => {
      const extension = file.name.split('.').pop().toLowerCase();
      if (validExtensions.includes(extension)) {
        newImages.push({
          file,
          preview: URL.createObjectURL(file),
          isValid: true,
        });
      } else {
        newErrors.push(`"${file.name}" is not a valid file type. Only JPG, JPEG, and PNG are allowed.`);
      }
    });

    setImages((prevImages) => [...prevImages, ...newImages]);
    setImageErrors((prevErrors) => [...prevErrors, ...newErrors]);
  };

  const handleRemoveImage = (index) => {
    setImages((prevImages) => {
      URL.revokeObjectURL(prevImages[index].preview);
      return prevImages.filter((_, i) => i !== index);
    });
    setImageErrors((prevErrors) => prevErrors.filter((_, i) => i !== index));
  };

  const handleAddKeyword = (keyword) => setKeywords([...keywords, keyword]);
  const handleRemoveKeyword = (keywordToRemove) =>
    setKeywords(keywords.filter((keyword) => keyword !== keywordToRemove));

  const handleLevelSelection = (levelData) => setLevel(levelData);

  const handleAddSubject = (subject) => setSubjects([...subjects, subject]);
  const handleRemoveSubject = (subjectToRemove) =>
    setSubjects(subjects.filter((subject) => subject !== subjectToRemove));

  const handleSubmit = async (e) => {
    e.preventDefault();

    const formData = new FormData();
    formData.append('question[type]', questionType);
    formData.append('question[level]', level);
    formData.append('question[text]', questionText);

    // Handle data based on question type
    if (questionType === 'Essay') {
      const formattedData = {
        html: questionText.split('\n').map((line, index) => `<p key=${index}>${line}</p>`).join('')
      };
      formData.append('question[data]', JSON.stringify(formattedData));
    } else if (questionType === 'Drag and Drop' && Array.isArray(data)) {
      // Remove any empty answers
      const validData = data.filter(item => item.answer.trim() !== '');
      formData.append('question[data]', JSON.stringify(validData));
    }

    images.filter((image) => image.isValid).forEach(({ file }) =>
      formData.append('question[images][]', file)
    );

    keywords.forEach((keyword) => formData.append('question[keywords][]', keyword));
    subjects.forEach((subject) => formData.append('question[subjects][]', subject));

    try {
      const response = await fetch('/api/questions', {
        method: 'POST',
        body: formData,
      });
      
      if (response.ok) {
        alert('Question saved successfully!');
        resetForm();
      } else {
        const errorData = await response.json();
        alert(`Failed to save the question: ${errorData.errors?.join(', ')}`);
      }
    } catch (error) {
      console.error('Error saving the question:', error);
      alert('An error occurred while saving the question.');
    }
  };

  const resetForm = () => {
    setQuestionType('');
    setQuestionText('');
    setImages([]);
    setImageErrors([]);
    setLevel('');
    setKeywords([]);
    setSubjects([]);
    setData(null);
    setResetFields(true);
  };

  const isSubmitDisabled = () => {
    if (!questionText || images.some((image) => !image.isValid)) return true;

    if (questionType === 'Drag and Drop') {
      if (!data || !Array.isArray(data) || !data.some((item) => item.correct && item.answer.trim())) {
        return true;
      }
    }

    return false;
  };

  return (
    <>
      <h2 className="h5 fw-bold mt-5">Create a Question</h2>
      <QuestionTypeDropdown handleQuestionTypeSelection={handleQuestionTypeSelection} />

      {QuestionComponent && (
        <div className="bg-white mt-4 p-4 d-flex flex-wrap">
          <Form onSubmit={handleSubmit} className="mx-4 flex-fill">
            <QuestionComponent
              questionText={questionText}
              handleTextChange={handleTextChange}
              onDataChange={setData}
              resetFields={resetFields}
            />
            <ImageUploader
              images={images}
              imageErrors={imageErrors}
              handleImageChange={handleImageChange}
              handleRemoveImage={handleRemoveImage}
            />
            <Button
              type="submit"
              className="btn btn-primary mt-3"
              disabled={isSubmitDisabled()}
            >
              Submit
            </Button>
          </Form>
          <div className="m-4">
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
      )}
    </>
  );
};

export default CreateQuestionForm;
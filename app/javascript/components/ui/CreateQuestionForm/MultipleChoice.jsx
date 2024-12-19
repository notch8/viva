import React, { useState, useEffect } from 'react';
import { Button } from 'react-bootstrap';

const MultipleChoice = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [answers, setAnswers] = useState([
    { answer: '', correct: false },
    { answer: '', correct: false },
    { answer: '', correct: false },
    { answer: '', correct: false }
  ]);

  useEffect(() => {
    if (resetFields) {
      setAnswers([
        { answer: '', correct: false },
        { answer: '', correct: false },
        { answer: '', correct: false },
        { answer: '', correct: false }
      ]);
    }
  }, [resetFields]);

  const updateAnswer = (index, field, value) => {
    const updatedAnswers = [...answers];
    updatedAnswers[index][field] = value;

    // Ensure only one correct answer is selected
    if (field === 'correct' && value) {
      updatedAnswers.forEach((answer, i) => {
        if (i !== index) answer.correct = false;
      });
    }

    setAnswers(updatedAnswers);
    onDataChange(updatedAnswers);
  };

  const addAnswer = () => {
    setAnswers([...answers, { answer: '', correct: false }]);
  };

  const removeAnswer = (index) => {
    const updatedAnswers = answers.filter((_, i) => i !== index);
    setAnswers(updatedAnswers);
    onDataChange(updatedAnswers);
  };

  return (
    <div>
      <div className="mb-3">
        <label className="h6">Question</label>
        <textarea
          className="form-control"
          rows="3"
          placeholder="Enter your question"
          value={questionText}
          onChange={handleTextChange}
        ></textarea>
      </div>
      {answers.map((answer, index) => (
        <div key={index} className="d-flex align-items-center mb-2">
          <input
            type="text"
            className="form-control me-2"
            placeholder={`Answer ${index + 1}`}
            value={answer.answer}
            onChange={(e) => updateAnswer(index, 'answer', e.target.value)}
          />
          <input
            type="radio"
            name="correct"
            checked={answer.correct}
            onChange={(e) => updateAnswer(index, 'correct', e.target.checked)}
          />
          <Button variant="danger" size="sm" className="ms-2" onClick={() => removeAnswer(index)}>
            Remove
          </Button>
        </div>
      ))}
      <Button variant="secondary" size="sm" onClick={addAnswer}>
        Add Answer
      </Button>
    </div>
  );
};

export default MultipleChoice;

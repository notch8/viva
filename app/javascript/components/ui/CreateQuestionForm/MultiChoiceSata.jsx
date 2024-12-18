import React, { useState, useEffect } from 'react';
import { Button } from 'react-bootstrap';
import AnswerField from './AnswerField';

const MultiChoiceSata = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [answers, setAnswers] = useState([{ answer: '', correct: false }]);

  useEffect(() => {
    if (resetFields) {
      setAnswers([{ answer: '', correct: false }]);
    }
  }, [resetFields]);

  const updateAnswer = (index, field, value) => {
    const updatedAnswers = [...answers];
    updatedAnswers[index][field] = value;
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
      <AnswerField
        answers={answers}
        updateAnswer={updateAnswer}
        removeAnswer={removeAnswer}
        title="Answers"
      />
      <Button variant="secondary" size="sm" onClick={addAnswer}>
        Add Answer
      </Button>
    </div>
  );
};

export default MultiChoiceSata;

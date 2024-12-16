import React, { useState, useEffect } from 'react';
import { Form, Button } from 'react-bootstrap';

const Matching = ({ questionText, handleTextChange, onDataChange, resetFields }) => {
  const [pairs, setPairs] = useState([{ answer: '', correct: '' }]);
  const [errors, setErrors] = useState({});

  useEffect(() => {
    if (resetFields) {
      setPairs([{ answer: '', correct: '' }]);
      onDataChange([{ answer: '', correct: '' }]);
      setErrors({});
    }
  }, [resetFields]);

  const addPair = () => {
    const updatedPairs = [...pairs, { answer: '', correct: '' }];
    setPairs(updatedPairs);
    onDataChange(updatedPairs);
  };

  const removePair = (indexToRemove) => {
    const updatedPairs = pairs.filter((_, index) => index !== indexToRemove);
    setPairs(updatedPairs);
    onDataChange(updatedPairs);

    // Reset errors
    const updatedErrors = { ...errors };
    delete updatedErrors[indexToRemove];
    setErrors(updatedErrors);
  };

  const updatePair = (index, field, value) => {
    const updatedPairs = pairs.map((pair, i) =>
      i === index ? { ...pair, [field]: value } : pair
    );
    setPairs(updatedPairs);
    onDataChange(updatedPairs);

    // Reset errors for this pair
    setErrors({ ...errors, [index]: { ...errors[index], [field]: !value.trim() } });
  };

  return (
    <>
      <Form.Group>
        <Form.Label>Question</Form.Label>
        <Form.Control
          as="textarea"
          rows={3}
          value={questionText}
          onChange={handleTextChange}
        />
      </Form.Group>

      <h6>Matching Pairs</h6>
      {pairs.map((pair, index) => (
        <div key={index} className="d-flex mb-2 align-items-center">
          <Form.Control
            placeholder="Answer"
            value={pair.answer}
            onChange={(e) => updatePair(index, 'answer', e.target.value)}
            isInvalid={errors[index]?.answer}
            className="me-2"
          />
          <Form.Control
            placeholder="Correct Match"
            value={pair.correct}
            onChange={(e) => updatePair(index, 'correct', e.target.value)}
            isInvalid={errors[index]?.correct}
            className="me-2"
          />
          <Button
            variant="danger"
            size="sm"
            onClick={() => removePair(index)}
            className="me-2"
          >
            Remove
          </Button>
        </div>
      ))}
      <Button variant="secondary" onClick={addPair}>
        Add Pair
      </Button>
    </>
  );
};

export default Matching;

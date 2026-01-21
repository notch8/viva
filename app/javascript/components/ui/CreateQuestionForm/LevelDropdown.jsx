import React, { useState, useEffect } from 'react'
import { Dropdown, Form } from 'react-bootstrap'
import CustomDropdown from '../CustomDropdown'
import { LEVELS } from '../../../constants/levels.js'

const LevelDropdown = ({
  handleLevelSelection,
  selectedLevel: initialLevel = ''
}) => {
  // Find the key (display name) for the initial level value
  const getKeyFromValue = (value) => {
    if (!value) return 'Level'
    const level = LEVELS.find(({ value: v }) => v === value)
    return level ? level.key : 'Level'
  }

  const [selectedLevel, setSelectedLevel] = useState(
    getKeyFromValue(initialLevel)
  )

  useEffect(() => {
    setSelectedLevel(getKeyFromValue(initialLevel))
  }, [initialLevel])

  const levelDropdown = (level) => {
    const levelData = LEVELS.find(({ key }) => key === level).value
    handleLevelSelection(levelData)
    setSelectedLevel(level)
  }

  return (
    <Form.Group className='my-4'>
      <Form.Label className='h6 fw-bold' htmlFor='level'>
        Select Level
      </Form.Label>
      <CustomDropdown dropdownSelector='.question-type-dropdown'>
        <Dropdown onSelect={levelDropdown} className='question-type-dropdown'>
          <Dropdown.Toggle variant='secondary' id='level'>
            {selectedLevel}
          </Dropdown.Toggle>
          <Dropdown.Menu>
            {LEVELS.map(({ key }) => (
              <Dropdown.Item key={key} eventKey={key}>
                {key}
              </Dropdown.Item>
            ))}
          </Dropdown.Menu>
        </Dropdown>
      </CustomDropdown>
    </Form.Group>
  )
}

export default LevelDropdown

import React, { useState } from 'react'
import { Dropdown, Form } from 'react-bootstrap'
import CustomDropdown from '../CustomDropdown'
import { LEVELS } from '../../../constants/levels.js'

const LevelDropdown = ({ handleLevelSelection }) => {
  const [selectedLevel, setSelectedLevel] = useState('Level')


  const levelDropdown = (level) => {    
    handleLevelSelection(level)
    setSelectedLevel(level)
  }

  return (
    <Form.Group controlId='level'>
      <CustomDropdown dropdownSelector='.question-type-dropdown'>
        <Dropdown onSelect={levelDropdown} className='question-type-dropdown'>
          <Dropdown.Toggle variant='secondary'>{selectedLevel}</Dropdown.Toggle>
          <Dropdown.Menu>
            { LEVELS.map(({ key, value }) => (
              <Dropdown.Item key={key} eventKey={value}>
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

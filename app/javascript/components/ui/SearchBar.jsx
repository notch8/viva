import React, { useEffect } from 'react'
import { InputGroup, DropdownButton, Dropdown, Button, Container, Form } from 'react-bootstrap'
import { MagnifyingGlass } from '@phosphor-icons/react'

const SearchBar = (props) => {

  // Function to set the width of the dropdown menu to match the button
  useEffect(() => {
    const setDropdownWidth = () => {
      const dropdownButtons = document.querySelectorAll('.dropdown-toggle')
      dropdownButtons.forEach((dropdownButton) => {
        const dropdownMenu = dropdownButton.nextSibling;
        if (dropdownMenu) {
          const buttonWidth = dropdownButton.offsetWidth;
          dropdownMenu.style.minWidth = `${buttonWidth}px`
        }
      })
    }
    setDropdownWidth();
    window.addEventListener('resize', setDropdownWidth);
    return () => {
      window.removeEventListener('resize', setDropdownWidth)
    }
  }, [])

  return (
    <Form>
      <Container className='p-0 mt-2 search-bar'>
          <InputGroup className='mb-3'>
            {Object.keys(props).map((key, index) => (
              <DropdownButton
                key={index}
                variant='outline-light-4 text-black fs-6 d-flex align-items-center justify-content-between'
                title={key}
                id={`input-group-dropdown-${index}`}
                size='lg'
                autoClose="outside"
              >
                {props[key].map((item, itemIndex) => (
                  <Form.Check type='checkbox' id={item} className='p-2' key={itemIndex}>
                    <Form.Check.Input type='checkbox' id={item} className='mx-0'/>
                    <Form.Check.Label className='ps-2'>{props[key] === 'types' ? item.substring(10) : item}</Form.Check.Label>
                  </Form.Check>
                ))}
              </DropdownButton>
            ))}
            <Button
              className='d-flex align-items-center fs-6 justify-content-center'
              id='button-addon2'
              size='lg'
            >
              <span className='me-1'>Search</span>
              <MagnifyingGlass size={20} weight='bold'/>
            </Button>
          </InputGroup>
      </Container>
    </Form>
  )
}

export default SearchBar

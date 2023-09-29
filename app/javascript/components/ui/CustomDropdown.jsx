import React, { useEffect } from 'react'

const CustomDropdown = ({ children, dropdownSelector }) => {
  useEffect(() => {
    const setWidth = () => {
      const dropdownButtons = document.querySelectorAll(dropdownSelector)
      dropdownButtons.forEach((dropdownButton) => {
        let dropdownMenu = dropdownButton.nextSibling
        if (!dropdownMenu) {
          dropdownMenu = dropdownButton.querySelector('.dropdown-menu')
        }
        if (dropdownMenu) {
          const buttonWidth = dropdownButton.offsetWidth
          dropdownMenu.style.minWidth = `${buttonWidth}px`
        }
      })
    }

    setWidth()

    window.addEventListener('resize', setWidth)

    return () => {
      window.removeEventListener('resize', setWidth)
    }
  }, [])

  return <>{children}</>
}

export default CustomDropdown
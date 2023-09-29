export const setDropdownWidth = () => {
  const setWidth = () => {
    const dropdownButtons = document.querySelectorAll('.dropdown-toggle')
    dropdownButtons.forEach((dropdownButton) => {
      const dropdownMenu = dropdownButton.nextSibling
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
}
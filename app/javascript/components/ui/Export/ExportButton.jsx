import React from 'react'
import {Button} from 'react-bootstrap'
import './Export.css'

const ExportButton = ({ format, label, questionTypes, hasBookmarks }) => {
  const getIconClass = (format) => {
    switch (format) {
    case 'blackboard':
      return 'bi-clipboard2-fill'
    case 'd2l':
      return 'bi-sun-fill'
    case 'canvas':
      return 'bi-grid-3x3-gap-fill'
    case 'moodle':
      return 'bi-mortarboard-fill'
    case 'md':
      return 'bi-markdown-fill'
    case 'txt':
      return 'bi-file-text-fill'
    default:
      return 'bi-clipboard2-fill'
    }
  }

  const isTextFormat = format === 'md' || format === 'txt'

  return (
    <div className='export-button-container'>
      <Button
        variant='outline-primary'
        className='export-button'
        href={`/bookmarks/export?format=${format}`}
        disabled={!hasBookmarks}
        data-cy={`export-button-${format}`}
        data-format={format}
      >
        <i className={`bi ${getIconClass(format)}`}></i>
        <span>{label}</span>
      </Button>
      <div className='supported-types'>
        {isTextFormat ? (
          <div>All Question Types Supported</div>
        ) : (
          questionTypes.map((type, index) => (
            <div key={index}>{type}</div>
          ))
        )}
      </div>
    </div>
  )
}

export default ExportButton

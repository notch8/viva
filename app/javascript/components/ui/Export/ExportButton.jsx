import React from 'react'
import {Button, OverlayTrigger, Tooltip} from 'react-bootstrap'
import './Export.css'

const ExportButton = ({ format, label, questionTypes, hasBookmarks }) => {
  const getTooltipText = (questionTypes) => {
    if (questionTypes.length === 0) {
      return 'Supports all question types in plain text format'
    }

    return `Supports: ${questionTypes.join(', ')}`
  }

  const getIconClass = (format) => {
    switch (format) {
      case 'blackboard':
        return 'bi-clipboard2-fill'
      case 'brightspace':
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

  return (
    <div className='col-md-6 d-flex justify-content-center'>
      <OverlayTrigger
        placement='top'
        overlay={<Tooltip>{getTooltipText(questionTypes)}</Tooltip>}
      >
        <Button
          variant='outline-primary'
          className='export-button'
          href={`/bookmarks/export?format=${format}`}
          disabled={!hasBookmarks}
          data-cy={`export-button-${format}`}
          data-format={format}
        >
          <i className={`bi ${getIconClass(format)} fs-1 mb-3`}></i>
          <span className='text-uppercase'>{label}</span>
        </Button>
      </OverlayTrigger>
    </div>
  )
}

export default ExportButton

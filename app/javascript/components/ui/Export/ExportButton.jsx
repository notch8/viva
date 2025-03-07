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
        >
          <i className='bi bi-clipboard2-fill fs-1 mb-3'></i>
          <span className='text-uppercase'>{label}</span>
        </Button>
      </OverlayTrigger>
    </div>
  )
}

export default ExportButton

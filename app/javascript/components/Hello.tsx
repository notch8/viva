import React from 'react'
import type { FC } from 'react'

interface Props {
    name: string
}

const Hello: FC<Props> = ({name}) => {
  return (
    <div>Hello again {name}!</div>
  )
}

export default Hello
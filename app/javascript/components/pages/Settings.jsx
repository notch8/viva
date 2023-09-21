import React from 'react'
import { Container, Tab, Nav } from 'react-bootstrap'
import Layout from '../App'
import SettingsForm from '../ui/Settings/SettingsForm'
import PasswordForm from '../ui/Settings/PasswordForm'

const Settings = ({ currentUser }) => {

  return (
    <Layout>
      <Container className='bg-light-1 rounded container p-0 mt-4 settings'>
        <Tab.Container className='flex-column flex-sm-row' defaultActiveKey='first'>
          <Nav variant='pills'>
            <Nav.Item className='flex-sm-fill text-sm-center first'>
              <Nav.Link className='py-3' eventKey='first'>User Profile</Nav.Link>
            </Nav.Item>
            <Nav.Item className='flex-sm-fill text-sm-center last'>
              <Nav.Link className='py-3' eventKey='second'>Password</Nav.Link>
            </Nav.Item>
          </Nav>
          <Tab.Content className='px-3 px-sm-5 py-4'>
            <Tab.Pane eventKey='first'>
              <SettingsForm currentUser={currentUser} />
            </Tab.Pane>
            <Tab.Pane eventKey='second'>
              <PasswordForm />
            </Tab.Pane>
          </Tab.Content>
        </Tab.Container>
      </Container>
    </Layout>
  )
}

export default Settings

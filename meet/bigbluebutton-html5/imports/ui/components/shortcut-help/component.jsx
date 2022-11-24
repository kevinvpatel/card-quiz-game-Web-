import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl } from 'react-intl';
import browserInfo from '/imports/utils/browserInfo';
import deviceInfo from '/imports/utils/deviceInfo';
import Modal from '/imports/ui/components/common/modal/simple/component';
import _ from 'lodash';
import Styled from './styles';
import StyledSettings from '../settings/styles';
import withShortcutHelper from './service';
import { isChatEnabled } from '/imports/ui/services/features';

const intlMessages = defineMessages({
  title: {
    id: 'app.shortcut-help.title',
    description: 'modal title label',
  },
  closeLabel: {
    id: 'app.shortcut-help.closeLabel',
    description: 'label for close button',
  },
  closeDesc: {
    id: 'app.shortcut-help.closeDesc',
    description: 'description for close button',
  },
  accessKeyNotAvailable: {
    id: 'app.shortcut-help.accessKeyNotAvailable',
    description: 'message shown in place of access key table if not supported',
  },
  comboLabel: {
    id: 'app.shortcut-help.comboLabel',
    description: 'heading for key combo column',
  },
  functionLabel: {
    id: 'app.shortcut-help.functionLabel',
    description: 'heading for shortcut function column',
  },
  openoptions: {
    id: 'app.shortcut-help.openOptions',
    description: 'describes the open options shortcut',
  },
  toggleuserlist: {
    id: 'app.shortcut-help.toggleUserList',
    description: 'describes the toggle userlist shortcut',
  },
  togglemute: {
    id: 'app.shortcut-help.toggleMute',
    description: 'describes the toggle mute shortcut',
  },
  togglepublicchat: {
    id: 'app.shortcut-help.togglePublicChat',
    description: 'describes the toggle public chat shortcut',
  },
  hideprivatechat: {
    id: 'app.shortcut-help.hidePrivateChat',
    description: 'describes the hide public chat shortcut',
  },
  closeprivatechat: {
    id: 'app.shortcut-help.closePrivateChat',
    description: 'describes the close private chat shortcut',
  },
  openactions: {
    id: 'app.shortcut-help.openActions',
    description: 'describes the open actions shortcut',
  },
  opendebugwindow: {
    id: 'app.shortcut-help.openDebugWindow',
    description: 'describes the open debug window shortcut',
  },
  openstatus: {
    id: 'app.shortcut-help.openStatus',
    description: 'describes the open status shortcut',
  },
  joinaudio: {
    id: 'app.audio.joinAudio',
    description: 'describes the join audio shortcut',
  },
  leaveaudio: {
    id: 'app.audio.leaveAudio',
    description: 'describes the leave audio shortcut',
  },
  raisehand: {
    id: 'app.shortcut-help.raiseHand',
    description: 'describes the toggle raise hand shortcut',
  },
  togglePan: {
    id: 'app.shortcut-help.togglePan',
    description: 'describes the toggle pan shortcut',
  },
  toggleFullscreen: {
    id: 'app.shortcut-help.toggleFullscreen',
    description: 'describes the toggle full-screen shortcut',
  },
  nextSlideDesc: {
    id: 'app.shortcut-help.nextSlideDesc',
    description: 'describes the next slide shortcut',
  },
  previousSlideDesc: {
    id: 'app.shortcut-help.previousSlideDesc',
    description: 'describes the previous slide shortcut',
  },
  togglePanKey: {
    id: 'app.shortcut-help.togglePanKey',
    description: 'describes the toggle pan shortcut key',
  },
  toggleFullscreenKey: {
    id: 'app.shortcut-help.toggleFullscreenKey',
    description: 'describes the toggle full-screen shortcut key',
  },
  nextSlideKey: {
    id: 'app.shortcut-help.nextSlideKey',
    description: 'describes the next slide shortcut key',
  },
  previousSlideKey: {
    id: 'app.shortcut-help.previousSlideKey',
    description: 'describes the previous slide shortcut key',
  },
  select: {
    id: 'app.shortcut-help.select',
    description: 'describes the selection tool shortcut key',
  },
  pencil: {
    id: 'app.shortcut-help.pencil',
    description: 'describes the pencil tool shortcut key',
  },
  eraser: {
    id: 'app.shortcut-help.eraser',
    description: 'describes the eraser tool shortcut key',
  },
  rectangle: {
    id: 'app.shortcut-help.rectangle',
    description: 'describes the rectangle shape tool shortcut key',
  },
  elipse: {
    id: 'app.shortcut-help.elipse',
    description: 'describes the elipse shape tool shortcut key',
  },
  triangle: {
    id: 'app.shortcut-help.triangle',
    description: 'describes the triangle shape tool shortcut key',
  },
  line: {
    id: 'app.shortcut-help.line',
    description: 'describes the line shape tool shortcut key',
  },
  arrow: {
    id: 'app.shortcut-help.arrow',
    description: 'describes the arrow shape tool shortcut key',
  },
  text: {
    id: 'app.shortcut-help.text',
    description: 'describes the text tool shortcut key',
  },
  note: {
    id: 'app.shortcut-help.note',
    description: 'describes the sticky note shortcut key',
  },
  general: {
    id: 'app.shortcut-help.general',
    description: 'general tab heading',
  },
  presentation: {
    id: 'app.shortcut-help.presentation',
    description: 'presentation tab heading',
    "app.shortcut-help.whiteboard": "Whiteboard",
  },
  whiteboard: {
    id: 'app.shortcut-help.whiteboard',
    description: 'whiteboard tab heading',
  }
});

const renderItem = (func, key) => {
  return (
    <tr key={_.uniqueId('hotkey-item-')}>
      <Styled.DescCell>{func}</Styled.DescCell>
      <Styled.KeyCell>{key}</Styled.KeyCell>
    </tr>
  );
}

const ShortcutHelpComponent = (props) => {
  const { intl, shortcuts } = props;
  const { browserName } = browserInfo;
  const { isIos, isMacos } = deviceInfo;
  const [ selectedTab, setSelectedTab] = React.useState(0);

  let accessMod = null;

  // different browsers use different access modifier keys
  // on different systems when using accessKey property.
  // Overview how different browsers behave: https://www.w3schools.com/jsref/prop_html_accesskey.asp
  switch (browserName) {
    case 'Chrome':
    case 'Microsoft Edge':
      accessMod = 'Alt';
      break;
    case 'Firefox':
      accessMod = 'Alt + Shift';
      break;
    default:
      break;
  }

  // all Browsers on iOS are using Control + Alt as access modifier
  if (isIos) {
    accessMod = 'Control + Alt';
  }
  // all Browsers on MacOS are using Control + Option as access modifier
  if (isMacos) {
    accessMod = 'Control + Option';
  }

  const generalShortcutItems = shortcuts.map((shortcut) => {
    if (!isChatEnabled() && shortcut.descId.indexOf('Chat') !== -1) return null;
    return renderItem(
      `${intl.formatMessage(intlMessages[`${shortcut.descId.toLowerCase()}`])}`,
      `${accessMod} + ${shortcut.accesskey}`
    );
  });

  const shortcutItems = [];
  shortcutItems.push(renderItem(intl.formatMessage(intlMessages.togglePan), intl.formatMessage(intlMessages.togglePanKey)));
  shortcutItems.push(renderItem(intl.formatMessage(intlMessages.toggleFullscreen), intl.formatMessage(intlMessages.toggleFullscreenKey)));
  shortcutItems.push(renderItem(intl.formatMessage(intlMessages.nextSlideDesc), intl.formatMessage(intlMessages.nextSlideKey)));
  shortcutItems.push(renderItem(intl.formatMessage(intlMessages.previousSlideDesc), intl.formatMessage(intlMessages.previousSlideKey)));

  const whiteboardShortcutItems = [];
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.select), '1'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.pencil), '2'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.eraser), '3'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.rectangle), '4'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.elipse), '5'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.triangle), '6'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.line), '7'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.arrow), '8'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.text), '9'));
  whiteboardShortcutItems.push(renderItem(intl.formatMessage(intlMessages.note), '0'));

  return (
    <Modal
      title={intl.formatMessage(intlMessages.title)}
      dismiss={{
        label: intl.formatMessage(intlMessages.closeLabel),
        description: intl.formatMessage(intlMessages.closeDesc),
      }}
    >
      <Styled.SettingsTabs
        onSelect={(tab) => setSelectedTab(tab)}
        selectedIndex={selectedTab}
        role="presentation"
      >
        <StyledSettings.SettingsTabList>
          <StyledSettings.SettingsTabSelector selectedClassName="is-selected">
            <StyledSettings.SettingsIcon iconName="application" />
            <span id="appicationTab">{intl.formatMessage(intlMessages.general)}</span>
          </StyledSettings.SettingsTabSelector>

          <StyledSettings.SettingsTabSelector selectedClassName="is-selected">
            <StyledSettings.SettingsIcon iconName="presentation" />
            <span id="presentationTab">{intl.formatMessage(intlMessages.presentation)}</span>
          </StyledSettings.SettingsTabSelector>

          <StyledSettings.SettingsTabSelector selectedClassName="is-selected">
            <StyledSettings.SettingsIcon iconName="whiteboard" />
            <span id="whiteboardTab">{intl.formatMessage(intlMessages.whiteboard)}</span>
          </StyledSettings.SettingsTabSelector>
        </StyledSettings.SettingsTabList>

        <StyledSettings.SettingsTabPanel selectedClassName="is-selected">
        {!accessMod ? <p>{intl.formatMessage(intlMessages.accessKeyNotAvailable)}</p>
          : (
            <span>
              <Styled.ShortcutTable>
                <tbody>
                  <tr>           
                    <th>{intl.formatMessage(intlMessages.functionLabel)}</th>
                    <th>{intl.formatMessage(intlMessages.comboLabel)}</th>
                  </tr>
                  {generalShortcutItems}
                </tbody>
              </Styled.ShortcutTable>
            </span>
          )
        }
        </StyledSettings.SettingsTabPanel>
        <StyledSettings.SettingsTabPanel selectedClassName="is-selected">
          <Styled.ShortcutTable>
              <tbody>
                <tr>
                  <th>{intl.formatMessage(intlMessages.functionLabel)}</th>
                  <th>{intl.formatMessage(intlMessages.comboLabel)}</th>
                </tr>
                {shortcutItems}
              </tbody>
            </Styled.ShortcutTable>
        </StyledSettings.SettingsTabPanel>
        <StyledSettings.SettingsTabPanel selectedClassName="is-selected">
          <Styled.ShortcutTable>
              <tbody>
                <tr>
                  <th>{intl.formatMessage(intlMessages.functionLabel)}</th>
                  <th>{intl.formatMessage(intlMessages.comboLabel)}</th>
                </tr>
                {whiteboardShortcutItems}
              </tbody>
            </Styled.ShortcutTable>
        </StyledSettings.SettingsTabPanel>

      </Styled.SettingsTabs>
    </Modal>
  );
};

ShortcutHelpComponent.defaultProps = {
  intl: {},
};

ShortcutHelpComponent.propTypes = {
  intl: PropTypes.object.isRequired,
  shortcuts: PropTypes.arrayOf(PropTypes.shape({
    accesskey: PropTypes.string.isRequired,
    descId: PropTypes.string.isRequired,
  })).isRequired,
};

export default withShortcutHelper(injectIntl(ShortcutHelpComponent));

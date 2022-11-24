import Presentations from '/imports/api/presentations';
import { isVideoBroadcasting } from '/imports/ui/components/screenshare/service';
import { getVideoUrl } from '/imports/ui/components/external-video-player/service';
import Settings from '/imports/ui/services/settings';
import getFromUserSettings from '/imports/ui/services/users-settings';
import { isExternalVideoEnabled, isScreenSharingEnabled } from '/imports/ui/services/features';
import { ACTIONS } from '../layout/enums';
import UserService from '/imports/ui/components/user-list/service';

const LAYOUT_CONFIG = Meteor.settings.public.layout;
const KURENTO_CONFIG = Meteor.settings.public.kurento;
const PRESENTATION_CONFIG = Meteor.settings.public.presentation;

const getPresentationInfo = () => {
  const currentPresentation = Presentations.findOne({
    current: true,
  });

  return {
    current_presentation: (currentPresentation != null),
  };
};

function shouldShowWhiteboard() {
  return true;
}

function shouldShowScreenshare() {
  const { viewScreenshare } = Settings.dataSaving;
  return isScreenSharingEnabled() && (viewScreenshare || UserService.isUserPresenter()) && isVideoBroadcasting();
}

function shouldShowExternalVideo() {
  return isExternalVideoEnabled() && getVideoUrl();
}

function shouldShowOverlay() {
  return getFromUserSettings('bbb_enable_video', KURENTO_CONFIG.enableVideo);
}

const setPresentationIsOpen = (layoutContextDispatch, value) => {
  layoutContextDispatch({
    type: ACTIONS.SET_PRESENTATION_IS_OPEN,
    value,
  });
};

export default {
  getPresentationInfo,
  shouldShowWhiteboard,
  shouldShowScreenshare,
  shouldShowExternalVideo,
  shouldShowOverlay,
  isVideoBroadcasting,
  setPresentationIsOpen,
};

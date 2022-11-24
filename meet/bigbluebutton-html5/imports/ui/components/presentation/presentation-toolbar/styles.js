import styled from 'styled-components';
import QuickPollDropdownContainer from '/imports/ui/components/actions-bar/quick-poll-dropdown/container';
import {
  colorOffWhite,
  colorBlueLightest,
  toolbarButtonColor,
  colorDanger,
  colorWhite,
  colorGrayDark,
} from '/imports/ui/stylesheets/styled-components/palette';
import {
  whiteboardToolbarMargin,
  whiteboardToolbarPaddingSm,
  whiteboardToolbarPadding,
  borderSize,
  smPaddingY,
  borderSizeLarge,
  smPaddingX,
} from '/imports/ui/stylesheets/styled-components/general';
import Button from '/imports/ui/components/common/button/component';

const PresentationToolbarWrapper = styled.div`
  position: absolute;
  align-self: center;
  z-index: 1;
  background-color: ${colorOffWhite};
  border-top: 1px solid ${colorBlueLightest};
  min-width: fit-content;
  width: 100%;
  bottom: 0px;
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;

  select {
    &:-moz-focusring {
      outline: none;
    }
    border: 0;
    background-color: ${colorOffWhite};
    cursor: pointer;
    margin: 0 ${whiteboardToolbarMargin} 0 0;
    padding: ${whiteboardToolbarPadding};
    padding-left: ${whiteboardToolbarPaddingSm};

    [dir="rtl"] & {
      margin: 0 0 0 ${whiteboardToolbarMargin};
      padding: ${whiteboardToolbarPadding};
      padding-right: ${whiteboardToolbarPaddingSm};
    }

    & > option {
      color: ${toolbarButtonColor};
      background-color: ${colorOffWhite};
    }
  }

  i {
    color: ${toolbarButtonColor};
    display: flex;
    justify-content: center;
    align-items: center;
  }
`;

const QuickPollButton = styled(QuickPollDropdownContainer)`
  position: relative;
  color: ${toolbarButtonColor};
  background-color: ${colorOffWhite};
  border-radius: 0;
  box-shadow: none !important;
  border: 0;

  &:focus {
    background-color: ${colorOffWhite};
  }
`;

const PresentationSlideControls = styled.div`
  justify-content: center;
  padding-left: ${whiteboardToolbarPadding};
  padding-right: ${whiteboardToolbarPadding};
  display: flex;
  flex-direction: row;
  align-items: center;

  & > button {
    padding: ${whiteboardToolbarPadding};
  }
`;

const PrevSlideButton = styled(Button)`

  i {
    padding-left: 20%;
  }

  & > i {
    font-size: 1rem;

    [dir="rtl"] & {
      -webkit-transform: scale(-1, 1);
      -moz-transform: scale(-1, 1);
      -ms-transform: scale(-1, 1);
      -o-transform: scale(-1, 1);
      transform: scale(-1, 1);
    }
  }

`;

const NextSlideButton = styled(Button)`
  
  i {
    padding-left: 60%;
  }

  & > i {
    font-size: 1rem;
    
    [dir="rtl"] & {
      -webkit-transform: scale(-1, 1);
      -moz-transform: scale(-1, 1);
      -ms-transform: scale(-1, 1);
      -o-transform: scale(-1, 1);
      transform: scale(-1, 1);
    }
  }
`;

const SkipSlideSelect = styled.select`
  padding: 0 ${smPaddingY};
  margin: ${borderSize};
  margin-left: ${whiteboardToolbarMargin};

  [dir="rtl"] & {
    margin: ${borderSize};
    margin-right: ${whiteboardToolbarMargin};
  }

  &:-moz-focusring {
    outline: none;
  }
  
  &:hover {
    outline: transparent;
    outline-style: dotted;
    outline-width: ${borderSize};
  }

  &:focus {
    outline: transparent;
    outline-width: ${borderSize};
    outline-style: solid;
  }
`;

const PresentationZoomControls = styled.div`
  justify-content: flex-end;
  padding: 0 ${whiteboardToolbarPadding} 0 0;

  [dir="rtl"] & {
    padding: 0 0 0 ${whiteboardToolbarPadding};
  }

  display: flex;
  flex-direction: row;
  align-items: center;

  button {
    padding: ${whiteboardToolbarPadding};
  }

  i {
    font-size: 1.2rem;
  }
`;

const FitToWidthButton = styled(Button)`
  border: none !important;

  & > i {
    font-size: 1.2rem;

    [dir="rtl"] & {
      -webkit-transform: scale(-1, 1);
      -moz-transform: scale(-1, 1);
      -ms-transform: scale(-1, 1);
      -o-transform: scale(-1, 1);
      transform: scale(-1, 1);
    }
  }

  margin-left: ${whiteboardToolbarMargin};
  margin-right: ${whiteboardToolbarMargin};

  position: relative;
  color: ${toolbarButtonColor};
  background-color: ${colorOffWhite};
  border-radius: 0;
  box-shadow: none !important;
  border: 0;

  &:focus {
    background-color: ${colorOffWhite};
    border: 0;
  }
`;

const MultiUserTool = styled.span`
  background-color: ${colorDanger};
  border-radius: 50%;
  width: 1rem;
  height: 1rem;
  position: relative;
  z-index: 2;
  right: 1rem;
  bottom: 0.5rem;
  color: ${colorWhite};
  display: flex;
  justify-content: center;
  align-items: center;
  box-shadow: 1px 1px ${borderSizeLarge} ${colorGrayDark};
  font-size: ${smPaddingX};
`;

const MUTPlaceholder = styled.div`
  width: 1rem;
  height: 1rem;
  position: relative;
  right: 1rem;
  bottom: 0.5rem;
`;

const WBAccessButton = styled(Button)`
  border: none !important;

  & > i {
    font-size: 1.2rem;

    [dir="rtl"] & {
      -webkit-transform: scale(-1, 1);
      -moz-transform: scale(-1, 1);
      -ms-transform: scale(-1, 1);
      -o-transform: scale(-1, 1);
      transform: scale(-1, 1);
    }
  }

  position: relative;
  color: ${toolbarButtonColor};
  background-color: ${colorOffWhite};
  border-radius: 0;
  box-shadow: none !important;
  border: 0;

  &:focus {
    background-color: ${colorOffWhite};
    border: 0;
  }
`;

export default {
  PresentationToolbarWrapper,
  QuickPollButton,
  PresentationSlideControls,
  PrevSlideButton,
  NextSlideButton,
  SkipSlideSelect,
  PresentationZoomControls,
  FitToWidthButton,
  MultiUserTool,
  WBAccessButton,
  MUTPlaceholder,
};

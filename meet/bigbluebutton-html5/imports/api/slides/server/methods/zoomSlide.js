import Presentations from '/imports/api/presentations';
import { Slides } from '/imports/api/slides';
import { Meteor } from 'meteor/meteor';
import RedisPubSub from '/imports/startup/server/redis';
import { extractCredentials } from '/imports/api/common/server/helpers';
import { check } from 'meteor/check';
import Logger from '/imports/startup/server/logger';

export default function zoomSlide(slideNumber, podId, zoom, x, y) {
  const REDIS_CONFIG = Meteor.settings.private.redis;
  const CHANNEL = REDIS_CONFIG.channels.toAkkaApps;
  const EVENT_NAME = 'ResizeAndMovePagePubMsg';

  try {
    const { meetingId, requesterUserId } = extractCredentials(this.userId);

    check(meetingId, String);
    check(requesterUserId, String);

    const selector = {
      meetingId,
      podId,
      current: true,
    };
    const Presentation = Presentations.findOne(selector);

    if (!Presentation) {
      throw new Meteor.Error('presentation-not-found', 'You need a presentation to be able to switch slides');
    }

    const Slide = Slides.findOne({
      meetingId,
      podId,
      presentationId: Presentation.id,
      num: slideNumber,
    });

    if (!Slide) {
      throw new Meteor.Error('slide-not-found', `Slide number ${slideNumber} not found in the current presentation`);
    }

    const payload = {
      podId,
      presentationId: Presentation.id,
      pageId: Slide.id,
      xCamera: x,
      yCamera: y,
      zoom,
    };

    RedisPubSub.publishUserMessage(CHANNEL, EVENT_NAME, meetingId, requesterUserId, payload);
  } catch (err) {
    Logger.error(`Exception while invoking method zoomSlide ${err.stack}`);
  }
}

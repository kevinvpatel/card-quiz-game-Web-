import {
  EFFECT_TYPES,
  BLUR_FILENAME,
  createVirtualBackgroundStream,
} from '/imports/ui/services/virtual-background/service';
import MediaStreamUtils from '/imports/utils/media-stream-utils';
import { EventEmitter2 } from 'eventemitter2';

export default class BBBVideoStream extends EventEmitter2 {
  static isVirtualBackground(type) {
    return type === EFFECT_TYPES.IMAGE_TYPE;
  }

  static trackStreamTermination(stream, handler) {
    // Dirty, but effective way of checking whether the browser supports the 'inactive'
    // event. If the oninactive interface is null, it can be overridden === supported.
    // If undefined, it's not; so we fallback to the track 'ended' event.
    // The track ended listener should probably be reviewed once we create
    // thin wrapper classes for MediaStreamTracks as well, because we'll want a single
    // media stream holding multiple tracks in the future
    if (stream.oninactive === null) {
      stream.addEventListener('inactive', handler, { once: true });
    } else {
      const track = MediaStreamUtils.getVideoTracks(stream)[0];
      if (track) {
        track.addEventListener('ended', handler, { once: true });
        // Extra safeguard: Firefox doesn't fire the 'ended' when it should
        // but it invokes the callback (?), so hook up to both
        track.onended = handler;
      }
    }
  }

  constructor(mediaStream) {
    super();
    this.mediaStream = mediaStream;
    this.originalStream = mediaStream;
    this.effect = null;
    this.virtualBgEnabled = false;
    this.virtualBgService = null;
    this.virtualBgType = EFFECT_TYPES.NONE_TYPE;
    this.virtualBgName = BLUR_FILENAME;
    this._trackOriginalStreamTermination();
  }

  set mediaStream(mediaStream) {
    if (!this.mediaStream
      || mediaStream == null
      || mediaStream.id !== this.mediaStream.id) {
      const oldStream = this.mediaStream;
      this._mediaStream = mediaStream;
      this.emit('streamSwapped', {
        oldStream,
        newStream: this.mediaStream,
      });
    }
  }

  get mediaStream() {
    return this._mediaStream;
  }

  set virtualBgService(service) {
    this._virtualBgService = service;
  }

  get virtualBgService() {
    return this._virtualBgService;
  }

  _trackOriginalStreamTermination() {
    const notify = () => {
      this.emit('inactive');
    };

    BBBVideoStream.trackStreamTermination(this.originalStream, notify);
  }

  _changeVirtualBackground(type, name, customParams) {
    try {
      this.virtualBgService.changeBackgroundImage({
        type,
        name,
        isVirtualBackground: BBBVideoStream.isVirtualBackground(type),
        customParams,
      });
      this.virtualBgType = type;
      this.virtualBgName = name;
      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    }
  }

  startVirtualBackground(type, name = '', customParams) {
    if (this.virtualBgService) return this._changeVirtualBackground(type, name, customParams);

    return createVirtualBackgroundStream(
      type,
      name,
      BBBVideoStream.isVirtualBackground(type),
      this.mediaStream,
      customParams,
    ).then(({ service, effect }) => {
      this.virtualBgService = service;
      this.virtualBgType = type;
      this.virtualBgName = name;
      this.originalStream = this.mediaStream;
      this.mediaStream = effect;
      this.isVirtualBackgroundEnabled = true;
    });
  }

  stopVirtualBackground() {
    if (this.virtualBgService != null) {
      this.virtualBgService.stopEffect();
      this.virtualBgService = null;
    }

    this.virtualBgType = EFFECT_TYPES.NONE_TYPE;
    this.virtualBgName = undefined;
    this.mediaStream = this.originalStream;
    this.isVirtualBackgroundEnabled = false;
  }

  stop() {
    if (this.isVirtualBackgroundEnabled) {
      this.stopVirtualBackground();
    }

    MediaStreamUtils.stopMediaStreamTracks(this.mediaStream);
    this.originalStream = null;
    this.mediaStream = null;
  }
}

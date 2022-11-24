/**
 * BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
 *
 * Copyright (c) 2017 BigBlueButton Inc. and by respective authors (see below).
 *
 * This program is free software; you can redistribute it and/or modify it under the
 * terms of the GNU Lesser General Public License as published by the Free Software
 * Foundation; either version 3.0 of the License, or (at your option) any later
 * version.
 *
 * BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY
 * WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
 * PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License along
 * with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
 *
 */

package org.bigbluebutton.core.record.events

class TldrawCameraChangedRecordEvent extends AbstractPresentationRecordEvent {
  import TldrawCameraChangedRecordEvent._

  setEvent("TldrawCameraChangedEvent")

  def setPresentationName(name: String) {
    eventMap.put(PRES_NAME, name)
  }

  def setId(id: String) {
    eventMap.put(ID, id)
  }

  def setXCamera(xCamera: Double) {
    eventMap.put(X_CAMERA, xCamera.toString)
  }

  def setYCamera(yCamera: Double) {
    eventMap.put(Y_CAMERA, yCamera.toString)
  }

  def setZoom(zoom: Double) {
    eventMap.put(ZOOM, zoom.toString)
  }
}

object TldrawCameraChangedRecordEvent {
  protected final val PRES_NAME = "presentationName"
  protected final val ID = "id"
  protected final val X_CAMERA = "xCamera"
  protected final val Y_CAMERA = "yCamera"
  protected final val ZOOM = "zoom"
}

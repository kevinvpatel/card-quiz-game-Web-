import * as React from "react";
import _ from "lodash";
import Cursors from "./cursors/container";
import { TldrawApp, Tldraw } from "@tldraw/tldraw";
import {
  ColorStyle,
  DashStyle,
  SizeStyle,
  TDShapeType,
} from "@tldraw/tldraw";
import { Utils } from "@tldraw/core";

function usePrevious(value) {
  const ref = React.useRef();
  React.useEffect(() => {
    ref.current = value;
  }, [value]);
  return ref.current;
}

const findRemoved = (A, B) => {
  return A.filter((a) => {
    return !B.includes(a);
  });
};

export default function Whiteboard(props) {
  const {
    isPresenter,
    removeShapes,
    initDefaultPages,
    persistShape,
    shapes,
    currentUser,
    curPres,
    whiteboardId,
    podId,
    zoomSlide,
    skipToSlide,
    slidePosition,
    curPageId,
    svgUri,
    presentationWidth,
    presentationHeight,
    isViewersCursorLocked,
    setIsZoomed,
    zoomChanger,
    isZoomed,
    isMultiUserActive,
    isRTL,
  } = props;

  const { pages, pageStates } = initDefaultPages(curPres?.pages.length || 1);
  const rDocument = React.useRef({
    name: "test",
    version: TldrawApp.version,
    id: whiteboardId,
    pages,
    pageStates,
    bindings: {},
    assets: {},
  });
  const [tldrawAPI, setTLDrawAPI] = React.useState(null);
  const [cameraFitSlide, setCameraFitSlide] = React.useState({point: [0, 0], zoom: 0});
  const prevShapes = usePrevious(shapes);

  const calculateCameraFitSlide = () => {
    let zoom =
      Math.min(
        (presentationWidth) / slidePosition.width,
        (presentationHeight) / slidePosition.height
      );

    zoom = Utils.clamp(zoom, 0.1, 5);

    let point = [0, 0];
    if ((presentationWidth / presentationHeight) >
        (slidePosition.width / slidePosition.height))
    {
      point[0] = (presentationWidth - (slidePosition.width * zoom)) / 2 / zoom
    } else {
      point[1] = (presentationHeight - (slidePosition.height * zoom)) / 2 / zoom
    }

    isPresenter && zoomChanger(zoom);
    return {point, zoom}
  }

  const doc = React.useMemo(() => {
    const currentDoc = rDocument.current;

    let next = { ...currentDoc };

    let pageBindings = null;
    let history = null;
    let stack = null;
    let changed = false;

    if (next.pageStates[curPageId] && !_.isEqual(prevShapes, shapes)) {
      // mergeDocument loses bindings and history, save it
      pageBindings = tldrawAPI?.getPage(curPageId)?.bindings;
      history = tldrawAPI?.history
      stack = tldrawAPI?.stack

      next.pages[curPageId].shapes = shapes;

      changed = true;
    }

    if (next.pages[curPageId] && !next.pages[curPageId].shapes["slide-background-shape"]) {
      next.assets[`slide-background-asset-${curPageId}`] = {
        id: `slide-background-asset-${curPageId}`,
        size: [slidePosition?.width || 0, slidePosition?.height || 0],
        src: svgUri,
        type: "image",
      };

      next.pages[curPageId].shapes["slide-background-shape"] = {
        assetId: `slide-background-asset-${curPageId}`,
        childIndex: 0.5,
        id: "slide-background-shape",
        name: "Image",
        type: TDShapeType.Image,
        parentId: `${curPageId}`,
        point: [0, 0],
        isLocked: true,
        size: [slidePosition?.width || 0, slidePosition?.height || 0],
        style: {
          dash: DashStyle.Draw,
          size: SizeStyle.Medium,
          color: ColorStyle.Blue,
        },
      };

      changed = true;
    }

    if (changed) {
      if (pageBindings) next.pages[curPageId].bindings = pageBindings;
      tldrawAPI?.mergeDocument(next);
      if (tldrawAPI && history) tldrawAPI.history = history;
      if (tldrawAPI && stack) tldrawAPI.stack = stack;
    }

    // move poll result text to bottom right
    if (next.pages[curPageId]) {
      const pollResults = Object.entries(next.pages[curPageId].shapes)
                                .filter(([id, shape]) => shape.name.includes("poll-result"))
      for (const [id, shape] of pollResults) {
        if (_.isEqual(shape.point, [0, 0])) {
          const shapeBounds = tldrawAPI?.getShapeBounds(id);
          if (shapeBounds) {
            shape.point = [
              slidePosition.width - shapeBounds.width,
              slidePosition.height - shapeBounds.height
            ]
            shape.size = [shapeBounds.width, shapeBounds.height]
            isPresenter && persistShape(shape, whiteboardId);
          }
        }
      };
    }

    return currentDoc;
  }, [shapes, tldrawAPI, curPageId, slidePosition]);

  // when presentationSizes change, update tldraw camera
  // to fit slide on center if zoomed out
  React.useEffect(() => {
    if (curPageId && slidePosition) {
      const camera = calculateCameraFitSlide();
      setCameraFitSlide(camera);
      if (!isZoomed) {
        tldrawAPI?.setCamera(camera.point, camera.zoom);
      }
    }
  }, [presentationWidth, presentationHeight, curPageId, document?.documentElement?.dir]);

  // change tldraw page when presentation page changes
  React.useEffect(() => {
    if (tldrawAPI && curPageId) {
      const previousPageZoom = tldrawAPI.getPageState()?.camera?.zoom;
      tldrawAPI.changePage(curPageId);
      //change zoom of the new page to follow the previous one
      if (!isZoomed && cameraFitSlide.zoom !== 0) {
        tldrawAPI?.setCamera(cameraFitSlide.point, cameraFitSlide.zoom, "zoomed");
      } else {
        previousPageZoom &&
        slidePosition &&
        tldrawAPI.setCamera([slidePosition.xCamera, slidePosition.yCamera], previousPageZoom, "zoomed");
      }
    }
  }, [curPageId]);

  // change tldraw camera when slidePosition changes
  React.useEffect(() => {
    if (tldrawAPI && !isPresenter && curPageId && slidePosition) {
      if (slidePosition.zoom === 0 && slidePosition.xCamera === 0 && slidePosition.yCamera === 0) {
        tldrawAPI?.setCamera(cameraFitSlide.point, cameraFitSlide.zoom);
        setIsZoomed(false);
      } else {
        tldrawAPI?.setCamera([slidePosition.xCamera, slidePosition.yCamera], slidePosition.zoom);
        setIsZoomed(true);
      }
    }
  }, [curPageId, slidePosition]);

  const hasWBAccess = props?.hasMultiUserAccess(props.whiteboardId, props.currentUser.userId);

  React.useEffect(() => {
    if (hasWBAccess || isPresenter) {
      const tdTools = document.getElementById("TD-Tools"); 
      if (tdTools) {
        // removes tldraw native help menu button
        tdTools.parentElement?.nextSibling?.remove();
      }
      // removes image tool from the tldraw toolbar
      document.getElementById("TD-PrimaryTools-Image").style.display = 'none';
    }
  });

  const onMount = (app) => {
    app.setSetting('language', document.getElementsByTagName('html')[0]?.lang || 'en');
    app.setSetting('dockPosition', isRTL ? 'left' : 'right');
    setTLDrawAPI(app);
    props.setTldrawAPI(app);
    // disable for non presenter that doesn't have multi user access
    if (!hasWBAccess && !isPresenter) {
      app.onPan = () => {};
      app.setSelectedIds = () => {};
      app.setHoveredId = () => {};
    } else {
      // disable hover highlight for background slide shape
      app.setHoveredId = (id) => {
        if (id?.includes('slide-background')) return null;
        app.patchState(
          {
            document: {
              pageStates: {
                [app.getPage()?.id]: {
                  hoveredId: id,
                },
              },
            },
          },
          `set_hovered_id`
        );
      };
    }

    if (curPageId) {
      app.changePage(curPageId);
      if (slidePosition.zoom === 0) {
        // first load, center the view to fit slide
        const cameraFitSlide = calculateCameraFitSlide();
        app.setCamera(cameraFitSlide.point, cameraFitSlide.zoom);
        setCameraFitSlide(cameraFitSlide);
      } else {
        app.setCamera([slidePosition.xCamera, slidePosition.yCamera], slidePosition.zoom);
        setIsZoomed(true);
      }
    }
  };

  const onPatch = (e, t, reason) => {
    if (reason && isPresenter && (reason.includes("zoomed") || reason.includes("panned"))) {
      if (cameraFitSlide.zoom === 0) {
        //can happen when the slide finish uploading
        const cameraFitSlide = calculateCameraFitSlide();
        tldrawAPI?.setCamera(cameraFitSlide.point, cameraFitSlide.zoom);
        setIsZoomed(false);
        setCameraFitSlide(cameraFitSlide);
        return;
      }
      const camera = tldrawAPI.getPageState()?.camera;
      //don't allow zoom out more than fit
      if (camera.zoom <= cameraFitSlide.zoom) {
        tldrawAPI?.setCamera(cameraFitSlide.point, cameraFitSlide.zoom);
        setIsZoomed(false);
        zoomSlide(parseInt(curPageId), podId, 0, 0, 0);
      } else {
        zoomSlide(parseInt(curPageId), podId, camera.zoom, camera.point[0], camera.point[1]);
        setIsZoomed(true);
      }
    }
    //don't allow non-presenters to pan&zoom
    if (slidePosition && reason && !isPresenter && (reason.includes("zoomed") || reason.includes("panned"))) {
      if (slidePosition.zoom === 0 && slidePosition.xCamera === 0 && slidePosition.yCamera === 0) {
        tldrawAPI?.setCamera(cameraFitSlide.point, cameraFitSlide.zoom);
        setIsZoomed(false);
      } else {
        tldrawAPI?.setCamera([slidePosition.xCamera, slidePosition.yCamera], slidePosition.zoom);
        setIsZoomed(true);
      }
    }
  };

  const editableWB = (
    <Tldraw
      key={`wb-${document?.documentElement?.dir}-${document.getElementById('Navbar')?.style?.width}`}
      document={doc}
      // disable the ability to drag and drop files onto the whiteboard
      // until we handle saving of assets in akka.
      disableAssets={true}
      // Disable automatic focus. Users were losing focus on shared notes
      // and chat on presentation mount.
      autofocus={false}
      onMount={onMount}
      showPages={false}
      showZoom={false}
      showUI={curPres ? (isPresenter || hasWBAccess) : true}
      showMenu={curPres ? false : true}
      showMultiplayerMenu={false}
      readOnly={false}
      onPatch={onPatch}
      onUndo={(e, s) => {
        e?.selectedIds?.map(id => {
          const shape = e.getShape(id);
          persistShape(shape, whiteboardId);
          const children = shape.children;
          children && children.forEach(c => {
            const childShape = e.getShape(c);
            const shapeBounds = e.getShapeBounds(c);
            childShape.size = [shapeBounds.width, shapeBounds.height];
            persistShape(childShape, whiteboardId)
          });
        })
        const pageShapes = e.state.document.pages[e.getPage()?.id]?.shapes;
        let shapesIdsToRemove = findRemoved(Object.keys(shapes), Object.keys(pageShapes))
        if (shapesIdsToRemove.length) {
          // add a little delay, wee need to make sure children are updated first
          setTimeout(() => removeShapes(shapesIdsToRemove, whiteboardId), 200);
        }
      }}

      onRedo={(e, s) => {
        e?.selectedIds?.map(id => {
          const shape = e.getShape(id);
          persistShape(shape, whiteboardId);
          const children = shape.children;
          children && children.forEach(c => {
            const childShape = e.getShape(c);
            const shapeBounds = e.getShapeBounds(c);
            childShape.size = [shapeBounds.width, shapeBounds.height];
            persistShape(childShape, whiteboardId)
          });
        });
        const pageShapes = e.state.document.pages[e.getPage()?.id]?.shapes;
        let shapesIdsToRemove = findRemoved(Object.keys(shapes), Object.keys(pageShapes))
        if (shapesIdsToRemove.length) {
          // add a little delay, wee need to make sure children are updated first
          setTimeout(() => removeShapes(shapesIdsToRemove, whiteboardId), 200);
        }
      }}

      onChangePage={(app, s, b, a) => {
        if (app.getPage()?.id !== curPageId) {
          skipToSlide(Number.parseInt(app.getPage()?.id), podId)
        }
      }}
      onCommand={(e, s, g) => {
        if (s?.id.includes('move_to_page')) {
          let groupShapes = [];
          let nonGroupShapes = [];
          let movedShapes = {};
          e.selectedIds.forEach(id => {
            const shape = e.getShape(id);
            if (shape.type === 'group')
              groupShapes.push(id);
            else
              nonGroupShapes.push(id);
            movedShapes[id] = e.getShape(id);
          });
          //remove shapes on origin page
          let idsToRemove = nonGroupShapes.concat(groupShapes);
          removeShapes(idsToRemove, whiteboardId);
          //persist shapes for destination page
          const newWhiteboardId = curPres.pages.find(page => page.num === Number.parseInt(e.getPage()?.id)).id;
          let idsToInsert = groupShapes.concat(nonGroupShapes);
          idsToInsert.forEach(id => {
            persistShape(movedShapes[id], newWhiteboardId);
            const children = movedShapes[id].children;
            children && children.forEach(c => {
              persistShape(e.getShape(c), newWhiteboardId)
            });
          });
          return;
        }

        if (s?.id.includes('ungroup')) {
          e?.selectedIds?.map(id => {
            persistShape(e.getShape(id), whiteboardId);
          })

          // check for deleted shapes
          const pageShapes = e.state.document.pages[e.getPage()?.id]?.shapes;
          let shapesIdsToRemove = findRemoved(Object.keys(shapes), Object.keys(pageShapes))
          if (shapesIdsToRemove.length) {
            // add a little delay, wee need to make sure children are updated first
            setTimeout(() => removeShapes(shapesIdsToRemove, whiteboardId), 200);
          }
          return;
        }

        const conditions = [
          "session:complete", "style", "updated_shapes", "duplicate", "stretch", 
          "align", "move", "delete", "create", "flip", "toggle", "group", "translate",
          "transform_single", "arrow", "edit", "erase", "rotate",   
        ]
        if (conditions.some(el => s?.id?.startsWith(el))) {
          e.selectedIds.forEach(id => {
            const shape = e.getShape(id);
            const shapeBounds = e.getShapeBounds(id);
            shape.size = [shapeBounds.width, shapeBounds.height];
            persistShape(shape, whiteboardId);
            //checks to find any bindings assosiated with the selected shapes.
            //If any, they need to be updated as well.
            const pageBindings = e.bindings;
            const boundShapes = {};
            if (pageBindings) {
              Object.entries(pageBindings).map(([k,b]) => {
                if (b.toId.includes(id)) {
                  boundShapes[b.fromId] = e.getShape(b.fromId);
                }
              })
            }
            //persist shape(s) that was updated by the client and any shapes bound to it.
            Object.entries(boundShapes).map(([k,bs]) => {
              const shapeBounds = e.getShapeBounds(k);
              bs.size = [shapeBounds.width, shapeBounds.height];
              persistShape(bs, whiteboardId)
            })
            const children = e.getShape(id).children;
            //also persist children of the selected shape (grouped shapes)
            children && children.forEach(c => {
              const shape = e.getShape(c);
              const shapeBounds = e.getShapeBounds(c);
              shape.size = [shapeBounds.width, shapeBounds.height];
              persistShape(shape, whiteboardId)
              // also persist shapes that are bound to the children
              if (pageBindings) {
                Object.entries(pageBindings).map(([k,b]) => {
                  if (!(b.fromId in boundShapes) && b.toId.includes(c)) {
                    const shape = e.getShape(b.fromId);
                    persistShape(shape, whiteboardId)
                    boundShapes[b.fromId] = shape;
                  }
                })
              }
            })
          });
          // draw shapes
          Object.entries(e.state.document.pages[e.getPage()?.id]?.shapes)
            .filter(([k, s]) => s?.type === 'draw')
            .forEach(([k, s]) => {
              if (!prevShapes[k] && !k.includes('slide-background')) {
                const shapeBounds = e.getShapeBounds(k);
                s.size = [shapeBounds.width, shapeBounds.height];
                persistShape(s, whiteboardId);
              }
          });

          // check for deleted shapes
          const pageShapes = e.state.document.pages[e.getPage()?.id]?.shapes;
          let shapesIdsToRemove = findRemoved(Object.keys(shapes), Object.keys(pageShapes))
          let groups = [];
          let nonGroups = [];
          // if we have groups, we need to make sure they are removed lastly
          shapesIdsToRemove.forEach(shape => {
            if (shapes[shape].type === 'group') {
              groups.push(shape);
            } else {
              nonGroups.push(shape);
            }
          });
          if (shapesIdsToRemove.length) {
            shapesIdsToRemove = nonGroups.concat(groups);
            removeShapes(shapesIdsToRemove, whiteboardId);
          }
        }
      }}
    />
  );

  const readOnlyWB = (
    <Tldraw
      key={`wb-readOnly`}
      document={doc}
      onMount={onMount}
      // disable the ability to drag and drop files onto the whiteboard
      // until we handle saving of assets in akka.
      disableAssets={true}
      // Disable automatic focus. Users were losing focus on shared notes
      // and chat on presentation mount.
      autofocus={false}
      showPages={false}
      showZoom={false}
      showUI={false}
      showMenu={false}
      showMultiplayerMenu={false}
      readOnly={true}
      onPatch={onPatch}
    />
  );

  return (
    <>
      <Cursors
        tldrawAPI={tldrawAPI}
        currentUser={currentUser}
        hasMultiUserAccess={props?.hasMultiUserAccess}
        whiteboardId={whiteboardId}
        isViewersCursorLocked={isViewersCursorLocked}
        isMultiUserActive={isMultiUserActive}
      >
        {hasWBAccess || isPresenter ? editableWB : readOnlyWB}
      </Cursors>
    </>
  );
}

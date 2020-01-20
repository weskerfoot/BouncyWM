import x11/xlib, x11/xutil, x11/x, x11/keysym
import strformat, os, options, tables, random

type XDirection = enum left, right
type YDirection = enum up, down

type Window = ref object of RootObj
  x : cint
  y : cint
  width : cint
  height : cint
  speed : cint
  win : TWindow
  xDirection : XDirection
  yDirection : YDirection

var root : TWindow
var windowState : Table[TWindow, Window] = initTable[TWindow, Window]()

var invalidWindows : seq[TWindow]

proc getWindowName(display : PDisplay, window : TWindow) : Option[string] =
  var name : cstring
  if display.XFetchName(window, name.addr) == BadWindow:
    return none(string)
  some($name)

proc gcWindows(display : PDisplay) =
  for xid, window in windowState.pairs:
    discard display.getWindowName(xid)
  for xid in invalidWindows:
    windowState.del(xid)
  invalidWindows = @[]

proc ignoreBadWindows(display : PDisplay, ev : PXErrorEvent) : cint {.cdecl.} =
  # resourceID maps to the Window's XID
  invalidWindows.add(ev.resourceID)
  0

proc getDisplay : PDisplay =
  result = XOpenDisplay(nil)
  if result == nil:
    quit("Failed to open display")

iterator getChildren(display : PDisplay, rootHeight : int, rootWidth : int) : Window =
  var currentWindow : PWindow
  var rootReturn : TWindow
  var parentReturn : TWindow
  var childrenReturn : PWindow
  var nChildrenReturn : cuint

  discard XQueryTree(display,
                     root,
                     rootReturn.addr,
                     parentReturn.addr,
                     childrenReturn.addr,
                     nChildrenReturn.addr)


  for i in 0..(nChildrenReturn.int - 1):
    var attr : TXWindowAttributes

    currentWindow = cast[PWindow](
      cast[uint](childrenReturn) + cast[uint](i * currentWindow[].sizeof)
    )

    if display.XGetWindowAttributes(currentWindow[], attr.addr) == BadWindow:
      windowState.del(currentWindow[])
      continue

    yield Window(
      x: rand(0..rootWidth).cint,
      y: rand(0..rootHeight).cint,
      xDirection: right,
      yDirection: down,
      width: attr.width,
      height: attr.height,
      win: currentWindow[],
      speed: rand(1..3).cint
    )

  discard XFree(childrenReturn)

when isMainModule:
  # Seed the RNG
  randomize()

  var start : TXButtonEvent
  var ev : TXEvent
  var attr : TXWindowAttributes

  let display = getDisplay()

  root = DefaultRootWindow(display)
  start.subWindow = None

  discard XSetErrorHandler(ignoreBadWindows)

  while true:
    discard display.XGetWindowAttributes(root, attr.addr)
    let rootWidth = attr.width
    let rootHeight = attr.height
    sleep(10)

    for window in getChildren(display, rootHeight, rootWidth):
      # go through each window, add it to the state
      discard windowState.hasKeyOrPut(window.win, window)

    display.gcWindows()

    # Go through each window and move them, update the state, etc
    for window in windowState.values:
      if window.xDirection == right:
        if window.x >= (rootWidth - window.width):
          windowState[window.win].xDirection = left
          windowState[window.win].x -= window.speed
        else:
          windowState[window.win].x += window.speed
      else:
        if window.x <= 0:
          windowState[window.win].xDirection = right
          windowState[window.win].x += window.speed
        else:
          windowState[window.win].x -= window.speed

      if window.yDirection == up:
        if window.y <= 0:
          windowState[window.win].yDirection = down
          windowState[window.win].y += window.speed
        else:
          windowState[window.win].y -= window.speed
      else:
        if window.y >= (rootHeight - window.height):
          windowState[window.win].yDirection = up
          windowState[window.win].y -= window.speed
        else:
          windowState[window.win].y += window.speed

      discard display.XMoveWindow(window.win, windowState[window.win].x, windowState[window.win].y)
    discard display.XSync(0)

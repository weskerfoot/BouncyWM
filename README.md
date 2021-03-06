## BouncyWM

### What is this?

My solution to [https://jvns.ca/blog/2019/11/25/challenge--make-a-bouncy-window-manager/](https://jvns.ca/blog/2019/11/25/challenge--make-a-bouncy-window-manager/) in Nim.

### How to build it?
Install nim and nimble and run `nimble build`. You must have XLib development headers on your system (and obviously an X server).

### How to run it?
* Install [Xephyr](https://en.wikipedia.org/wiki/Xephyr)
* Make sure you have a running X server

Then run these commands to launch Xephyr. You could also directly execute nimwin from your `~/.xinitrc`, but that would be difficult to use.
```
Xephyr -ac -screen 1280x1024 -br -reset -terminate 2> /dev/null :1 &
env DISPLAY=:1 ./nimwin
```

### How to launch a window?
If you want to run xterm, for example, just run `xterm -display :1`


![Screenshot of htop and vim bouncing](screenshots/example.gif)

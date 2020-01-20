## BouncyWM

### What is this?

My solution to [https://jvns.ca/blog/2019/11/25/challenge--make-a-bouncy-window-manager/](https://jvns.ca/blog/2019/11/25/challenge--make-a-bouncy-window-manager/) in Nim.

### How to build it?
Install nim and nimble and run `nimble build`. You must have XLib development headers on your system (and obviously an X server).

### How to run it?
```
Xephyr -ac -screen 1280x1024 -br -reset -terminate 2> /dev/null :1 &
env DISPLAY=:1 ./nimwin
```

### How to launch a window?
If you want to run xterm, for example, just run `xterm -display :1`

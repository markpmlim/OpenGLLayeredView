## Creating a custom OpenGL view

Implement a lightweight view for OpenGL rendering that's customized to your application's needs.

<br />
<br />
<br />

## Overview

macOS 10.6 (SnowLeopard) introduced a new **NSOpenGLLayer**which supports OpenGL draw calls in a layer-backed mode. In other words, it is now possible of **NSView** and its sub-classes (including **NSOpenGLView**) to render via OpenGL in layer-backed mode.

Following Apple's recommended guidelines:

(a) Sub-class **NSOpenGLLayer** called OpenGLLayer.

(b) The method **-openGLPixelFormatForDisplayMask:** is overridden to return an instance of **NSOpenGLPixelForma**t.
    Normally, macOS defaults to OpenGL fixed function pipeline. We will request for an OpenGL core profile.

(c) The **makeBackingLayer** method of the custom **NSView** is overriden to return an instance of our NSOpenGLLayer sub-class.

(d) We must override the default method of **NSOpenGLLayer**

```glsl
       drawInOpenGLContext:pixelFormat:forLayerTime:displayTime:
```
    so that our custom draw code can be executed.

Notes: The system creates a **CVDisplayLink** object which will call the **drawInOpenGLContext:...** method asynchronously or synchronously depending on the status of **NSOpenGLLayer**'s asynchronous property.

Comments within some of the source files should help the reader gain a better insight on the overall process. One important to note is the OpenGLRender object can only be instantiated when the system returned an OpenGL 3.2 context.

<br />
<br />

The notes within the documentation folder are from Apple's MacOSX Developer Release Notes.


<br />
<br />
<br />

Compiled with XCode 8.3.2
<br />
Tested under macOS 10.12

<br />
<br />

Weblinks:

https://stackoverflow.com/questions/7610117/layer-backed-openglview-redraws-only-if-window-is-resized

https://stackoverflow.com/questions/9442657/draw-from-a-separate-thread-with-nsopengllayer

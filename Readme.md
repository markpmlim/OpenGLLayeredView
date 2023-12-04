## Creating a custom OpenGL view

Implement a lightweight view for OpenGL rendering that's customized to your application's needs.

<br />
<br />
<br />

## Overview

macOS 10.6 (SnowLeopard) introduced a new "NSOpenGLLayer" which supports OpenGL draw calls in a layer-backed mode. In other words, it is now possible of NSView and its sub-classes (including NSOpenGLView) to render via OpenGL in layer-backed mode.

Following Apple's recommended guidelines:

(a) We sub-class NSOpenGLLayer

(b) The method -openGLPixelFormatForDisplayMask: is overridden to return an instance of NSOpenGLPixelFormat.
    Normally, macOS defaults to OpenGL fixed function pipeline. We will request for an OpenGL core profile.

(c) The makeBackingLayer method of the custom NSView is overriden to return an instance of our NSOpenGLLayer sub-class.

(d) We must override the default method of NSOpenGLLayer

        drawInOpenGLContext:pixelFormat:forLayerTime:displayTime:

    so that our custom draw code can be executed.

The system creates a CVDisplayLink which will can 

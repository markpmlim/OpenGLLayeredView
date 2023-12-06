//
//  OpenGLLayer.m
//  LayeredBackOpenGLView
//
//  Created by mark lim pak mun on 05/12/2023.
//  Copyright © 2023 Incremental Innovations. All rights reserved.
//

#import "OpenGLLayer.h"
#import "LayeredView.h"

@implementation OpenGLLayer

// Called by the View's makeBackingLayer method.
- (instancetype)init
{
    self = [super init];
    if (self != nil) {
        // Layer should render when size changes.
        self.needsDisplayOnBoundsChange = YES;
        // The layer will continuously call canDrawInOpenGLContext:...
        // if its asynchronous property is set to YES. Otherwise, the contents of the layer
        // are updated only in response to receiving a setNeedsDisplay message.
        self.asynchronous = NO;
        self.drawsAsynchronously = YES;
        // Both properties openGLPixelFormat, openGLContext are still nil.
    }
    return self;
}


// Note: the default implementation of the method
//      canDrawInOpenGLContext:pixelFormat:forLayerTime:displayTime:
// always returns YES
// It is called periodically since the "isAsynchronous" property is YES.

// The default implementation of the method openGLContextForPixelFormat: will return an
// OpenGL context using the instance NSOpenGLPixelFormat returned by the method
// openGLPixelFormatForDisplayMask:
// If the context needs to share OpenGL objects with another existing context, the
// method must be overridden. For example, the "share" context of an NSOpenGLLayer may be
// obtained with its associated view property. Call the method initWithFormat:shareContext:
// with the pixelformat parameter and the "share" context.

// This must be called by the system before the renderer object can be instantiated.
- (NSOpenGLPixelFormat *)openGLPixelFormatForDisplayMask:(uint32_t)mask
{
    NSOpenGLPixelFormatAttribute attrs[] = {
        // Specifying "NoRecovery" gives us a context that cannot fall back to the software renderer.
        // This makes the View-based context a compatible with the layer-backed context,
        // enabling us to use the "shareContext" feature to share textures, display lists,
        // and other OpenGL objects between the two.
        NSOpenGLPFANoRecovery,          // Enable automatic use of OpenGL "share" contexts.
        NSOpenGLPFAColorSize, 24,
        NSOpenGLPFAAlphaSize, 8,
        NSOpenGLPFADepthSize, 16,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAScreenMask, mask,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAOpenGLProfile,
        NSOpenGLProfileVersion3_2Core,  // Modern OpenGL
        0
    };
    NSOpenGLPixelFormat* pixelFormat = [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
    // Both properties openGLPixelFormat, openGLContext are still nil.
    // The system will use the returned instance of NSOpenGLPixelFormat
    // to create an OpenGL context.
    return pixelFormat;
}

// This is always called on the main thread. Check with [NSThread isMainThread]
// The system creates a CVDisplayLink which will call this method.
// If the asynchronous property is set to NO, the value of the parameter timeInterval
// can be used to calculate the number of frames/sec.
- (void)drawInOpenGLContext:(NSOpenGLContext *)context
                pixelFormat:(NSOpenGLPixelFormat *)pixelFormat
               forLayerTime:(CFTimeInterval)timeInterval
                displayTime:(const CVTimeStamp *)timeStamp
{
    // Both properties openGLPixelFormat, openGLContext have been instantiated.
    // The view associated with this instance of OpenGLLayer.
    LayeredView *view = (LayeredView *)self.view;
    // The view and its layer have been instantiated.
    // Anyway, the message render will not be sent if the object is NIL.
    // Perform rendering here.
    [view render];
}

@end

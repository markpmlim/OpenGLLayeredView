//
//  LayeredView.m
//  LayeredBackOpenGLView
//
//  Created by mark lim pak mun on 05/12/2023.
//  Copyright © 2023 Incremental Innovations. All rights reserved.
//

#import "LayeredView.h"
#import "OpenGLLayer.h"
#import "OpenGLRenderer.h"

@implementation LayeredView
{
    OpenGLRenderer *_renderer;
}

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self != nil) {
        self.wantsBestResolutionOpenGLSurface = YES;
        self.wantsLayer = YES;
        self.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    }
    return self;
    // The overridden method makeBackingLayer is not called yet.
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
}

- (CALayer *)makeBackingLayer
{
    return [[OpenGLLayer  alloc] init];
}

// When this method is called, the layer's OpenGLContext is nil.
// However, the layer object is not nil
- (void)viewDidChangeBackingProperties
{
    [super viewDidChangeBackingProperties];
    // Need to propagate information about retina resolution
    self.layer.contentsScale = self.window.backingScaleFactor;
}


// First time this method is called, the layer's OpenGLContext is nil.
// However, the layer object is not nil
- (void)setFrameSize:(NSSize)size
{
    [super setFrameSize:size];
    self.layer.contentsScale = self.window.backingScaleFactor;
}

// When this method is called by the drawInOpenGLContext:pixelFormat:forLayerTime:displayTime:
// the layer property of the view and the openGLContext property of the layer
// are no longer NIL.
// However, the OpenGLRenderer object hasn't be initialised yet.
- (void)render
{
    if (_renderer == nil) {
        _renderer = [[OpenGLRenderer alloc] initWithDefaultFBOName:0];
        [self resize];
    }
    [_renderer renderToOpenGLLayer:(OpenGLLayer *)self.layer];
}

// On first call (by the ViewController's viewDidLayout method)
// the OpenGLRenderer object is nil.
// First time this method is called, the layer's OpenGLContext property is nil.
// However, the layer object is not nil
- (void)resize
{
    if (_renderer != nil) {
        NSSize viewSizePoints = self.bounds.size;
        NSSize  viewSizePixels = [self convertSizeToBacking:viewSizePoints];
        [_renderer resize:viewSizePixels];
    }
}


@end

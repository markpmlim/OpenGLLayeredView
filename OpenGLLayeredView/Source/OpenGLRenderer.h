//
//  OpenGLRenderer.m
//  LayeredBackOpenGLView
//
//  Created by mark lim pak mun on 05/12/2023.
//  Copyright © 2023 Incremental Innovations. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl3.h>

@interface OpenGLRenderer : NSObject

- (instancetype)initWithDefaultFBOName:(GLuint)defaultFBOName;

- (void)resize:(NSSize)size;

- (void)renderToOpenGLLayer:(CALayer *)layer;

@end

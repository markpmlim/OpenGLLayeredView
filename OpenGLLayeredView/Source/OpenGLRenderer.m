//
//  OpenGLRenderer.m
//  LayeredBackOpenGLView
//
//  Created by mark lim pak mun on 05/12/2023.
//  Copyright © 2023 Incremental Innovations. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "OpenGLRenderer.h"
#import "OpenGLLayer.h"

@implementation OpenGLRenderer
{
    // Instance variables
    GLuint _defaultFBOName;
    NSSize _viewSize;

    GLuint _glslProgram;
    // This simple demo won't be using these
    GLKMatrix4 modelMatrix;
    GLKMatrix4 viewMatrix;
    GLKMatrix4 projectionMatrix;
    GLKMatrix3 normalMatrix;
    GLint _mvpMatrixLocation;
    GLint _viewportSizeLocation;

    GLuint _quadVAO;
    GLuint _quadVBO;
}

// An OpenGL context must be instantiated before an object
// of this clas can be created.
- (instancetype)initWithDefaultFBOName:(GLuint)defaultFBOName
{
    printf("%s %s\n", glGetString(GL_RENDERER), glGetString(GL_VERSION));
    self = [super self];
    if (self != nil) {
        _defaultFBOName = defaultFBOName;
        [self buildObjects];
        glBindVertexArray(_quadVAO);
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSURL *vertexSourceURL = [mainBundle URLForResource:@"SimpleVertexShader"
                                              withExtension:@"glsl"];
        NSURL *fragmentSourceURL = [mainBundle URLForResource:@"SimpleFragmentShader"
                                                withExtension:@"glsl"];
        _glslProgram = [OpenGLRenderer buildProgramWithVertexSourceURL:vertexSourceURL
                                                 withFragmentSourceURL:fragmentSourceURL];
    }
    return self;
}

- (void)dealloc
{
    glDeleteProgram(_glslProgram);
    glDeleteVertexArrays(1, &_quadVAO);
    glDeleteBuffers(1, &_quadVBO);
}

- (void)buildObjects
{
    typedef struct {
        GLKVector2 position;
        GLKVector2 texCoords;
    } QuadVertex_t;

    QuadVertex_t quadVertices[] = {
        {GLKVector2Make(-1, -1), GLKVector2Make(0, 0)},
        {GLKVector2Make(-1,  1), GLKVector2Make(0, 1)},
        {GLKVector2Make( 1,  1), GLKVector2Make(1, 1)},
        {GLKVector2Make(-1, -1), GLKVector2Make(0, 0)},
        {GLKVector2Make( 1,  1), GLKVector2Make(1, 1)},
        {GLKVector2Make( 1, -1), GLKVector2Make(1, 0)},
    };

    //printf("%lu %lu\n", sizeof(quadVertices), sizeof(QuadVertex_t));
    glGenVertexArrays(1, &_quadVAO);
    glBindVertexArray(_quadVAO);
    glGenBuffers(1, &_quadVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _quadVBO);
    glBufferData(GL_ARRAY_BUFFER,
                 sizeof(quadVertices),
                 quadVertices,
                 GL_STATIC_DRAW);
    glVertexAttribPointer(0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(QuadVertex_t),
                          (const GLvoid *) offsetof(QuadVertex_t, position));
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(1,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(QuadVertex_t),
                          (const GLvoid *) offsetof(QuadVertex_t, texCoords));
    glEnableVertexAttribArray(1);
    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


- (void)draw
{
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glViewport(0, 0,
               (GLsizei)(_viewSize.width), (GLsizei)(_viewSize.height));
    glBindVertexArray(_quadVAO);
    glUseProgram(_glslProgram);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glUseProgram(0);
    glBindVertexArray(0);
}

// The size parameter must be expressed in pixels.
- (void)resize:(NSSize)size
{
    _viewSize = size;
}

- (void)renderToOpenGLLayer:(CALayer *)layer
{
    // Prepare to draw
    NSOpenGLContext *context = ((OpenGLLayer *)layer).openGLContext;
    [context makeCurrentContext];
    CGLLockContext(context.CGLContextObj);

    [self draw];

    [context flushBuffer];
    CGLUnlockContext(context.CGLContextObj);
}

+ (GLuint)buildProgramWithVertexSourceURL:(NSURL*)vertexSourceURL
                    withFragmentSourceURL:(NSURL*)fragmentSourceURL
{

    NSError *error;

    NSString *vertSourceString = [[NSString alloc] initWithContentsOfURL:vertexSourceURL
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];

    NSAssert(vertSourceString, @"Could not load vertex shader source, error: %@.", error);

    NSString *fragSourceString = [[NSString alloc] initWithContentsOfURL:fragmentSourceURL
                                                                encoding:NSUTF8StringEncoding
                                                                   error:&error];

    NSAssert(fragSourceString, @"Could not load fragment shader source, error: %@.", error);

    // Prepend the #version definition to the vertex and fragment shaders.
    float glLanguageVersion;

    sscanf((char *)glGetString(GL_SHADING_LANGUAGE_VERSION), "%f", &glLanguageVersion);

    // `GL_SHADING_LANGUAGE_VERSION` returns the standard version form with decimals, but the
    //  GLSL version preprocessor directive simply uses integers (e.g. 1.10 should be 110 and 1.40
    //  should be 140). You multiply the floating point number by 100 to get a proper version number
    //  for the GLSL preprocessor directive.
    GLuint version = 100 * glLanguageVersion;

    NSString *versionString = [[NSString alloc] initWithFormat:@"#version %d", version];

    vertSourceString = [[NSString alloc] initWithFormat:@"%@\n%@", versionString, vertSourceString];
    fragSourceString = [[NSString alloc] initWithFormat:@"%@\n%@", versionString, fragSourceString];

    GLuint prgName;

    GLint logLength, status;

    // Create a GLSL program object.
    prgName = glCreateProgram();

    /*
     * Specify and compile a vertex shader.
     */

    GLchar *vertexSourceCString = (GLchar*)vertSourceString.UTF8String;
    GLuint vertexShader = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertexShader, 1, (const GLchar **)&(vertexSourceCString), NULL);
    glCompileShader(vertexShader);
    glGetShaderiv(vertexShader, GL_INFO_LOG_LENGTH, &logLength);

    if (logLength > 0) {
        GLchar *log = (GLchar*) malloc(logLength);
        glGetShaderInfoLog(vertexShader, logLength, &logLength, log);
        NSLog(@"Vertex shader compile log:\n%s.\n", log);
        free(log);
    }

    glGetShaderiv(vertexShader, GL_COMPILE_STATUS, &status);

    NSAssert(status, @"Failed to compile the vertex shader:\n%s.\n", vertexSourceCString);

    // Attach the vertex shader to the program.
    glAttachShader(prgName, vertexShader);

    // Delete the vertex shader because it's now attached to the program, which retains
    // a reference to it.
    glDeleteShader(vertexShader);

    /*
     * Specify and compile a fragment shader.
     */

    GLchar *fragSourceCString =  (GLchar*)fragSourceString.UTF8String;
    GLuint fragShader = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragShader, 1, (const GLchar **)&(fragSourceCString), NULL);
    glCompileShader(fragShader);
    glGetShaderiv(fragShader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetShaderInfoLog(fragShader, logLength, &logLength, log);
        NSLog(@"Fragment shader compile log:\n%s.\n", log);
        free(log);
    }

    glGetShaderiv(fragShader, GL_COMPILE_STATUS, &status);

    NSAssert(status, @"Failed to compile the fragment shader:\n%s.", fragSourceCString);

    // Attach the fragment shader to the program.
    glAttachShader(prgName, fragShader);

    // Delete the fragment shader because it's now attached to the program, which retains
    // a reference to it.
    glDeleteShader(fragShader);

    /*
     * Link the program.
     */

    glLinkProgram(prgName);
    glGetProgramiv(prgName, GL_LINK_STATUS, &status);
    NSAssert(status, @"Failed to link program.");
    if (status == 0) {
        glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar*)malloc(logLength);
            glGetProgramInfoLog(prgName, logLength, &logLength, log);
            NSLog(@"Program link log:\n%s.\n", log);
            free(log);
        }
    }

    // If the functions below are called and no VAOs have been bound prior to
    //  creating the shader program would result in a warning.
    // iOS will not complain if VAOs have NOT been bound.
    glValidateProgram(prgName);
    glGetProgramiv(prgName, GL_VALIDATE_STATUS, &status);
    NSAssert(status, @"Failed to validate program.");

    if (status == 0) {
        fprintf(stderr, "Program cannot run with current OpenGL State\n");
        glGetProgramiv(prgName, GL_INFO_LOG_LENGTH, &logLength);
        if (logLength > 0) {
            GLchar *log = (GLchar*)malloc(logLength);
            glGetProgramInfoLog(prgName, logLength, &logLength, log);
            NSLog(@"Program validate log:\n%s\n", log);
            free(log);
        }
    }

    //GetGLError();

    return prgName;
}

@end

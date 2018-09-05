//
//  AlphaCutOffShader.m
//  Homestyler
//
//  Created by Itamar Berger on 11/5/13.
//
//

#import "AlphaCutOffShader.h"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_TEXTURE_SAMPLER,
    NUM_UNIFORMS
};

GLint uniforms[NUM_UNIFORMS];


@implementation AlphaCutOffShader
@synthesize _program;
#pragma mark -  OpenGL ES 2 shader compilation


- (NSString*) vertexShader {
    NSString* vsh =
    @"attribute vec3 position;"
    "attribute vec2 texCoord;"
    "uniform mat4 modelViewProjectionMatrix;"
    "varying vec2 ftexCoord;"
    ""
    "void main()"
    "{"
    " ftexCoord = texCoord;"
    "  gl_Position = modelViewProjectionMatrix * vec4(position, 1.0);"
    "}";
    
    return vsh;
}

- (NSString*) fragmentShader {
    NSString* vsh =
    @"precision highp float;"
    "uniform vec3 diffuseColor;"
    "uniform sampler2D s_texture;"
    "varying vec2 ftexCoord;"
    ""
    "void main()"
    "{"
    " vec4 sample = texture2D(s_texture,ftexCoord);"
    "if(sample.a > 0.6)"
    "gl_FragColor = sample;"
    "else"
    "    discard;"
    "}";
    
    return vsh;
}

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    
    _program = glCreateProgram();
    
    NSString* vsh = [self vertexShader];
    
    NSString *fsh = [self fragmentShader];
    
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:(GLchar*)vsh.UTF8String]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:(GLchar*)fsh.UTF8String]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "texCoord");
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_TEXTURE_SAMPLER] = glGetUniformLocation(_program, "s_texture");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(GLchar *)source
{
    GLint status;
    
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    const GLchar * p_src = source;
    glShaderSource(*shader, 1, &p_src, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (void)dealloc
{
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}


- (void) draw:(Entity*)entity
{
    [entity.effect prepareToDraw];
    
    glUseProgram(_program);
    GLKMatrix4 _cameraModelViewMatrix = GLKMatrix4Multiply(entity.cameraMatrix, entity.modelviewMatrix);
    GLKMatrix4 _modelViewProjectionMatrix = GLKMatrix4Multiply(entity.projectionMatrix, _cameraModelViewMatrix);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, entity.texture.name);
    glUniform1i(uniforms[UNIFORM_TEXTURE_SAMPLER], 0);
    
        
    glDisable(GL_STENCIL_TEST);
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    
    [entity drawObjectWithShadow:NO];
}
@end

//
//  HSFurnitureShader.m
//  Homestyler
//
//
//

#import "HSFurnitureShader.h"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_TEXTURE_SAMPLER,
    UNIFORM_GAMMA_VALUE,
    UNIFORM_BACKGROUND_AVG_COLOR,
    UNIFORM_BACKGROUND_AVG_COLOR_STRENGTH,
    NUM_UNIFORMS
};

GLint uniforms2[NUM_UNIFORMS];


@implementation HSFurnitureShader
@synthesize _program;
#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
    GLuint vertShader, fragShader;
    
    _program = glCreateProgram();
    
    NSString *vshFile =  [[NSBundle mainBundle] pathForResource:@"HSFurnitureShader" ofType:@"vsh"];
    NSString *fshFile =  [[NSBundle mainBundle] pathForResource:@"HSFurnitureShader" ofType:@"fsh"];
    
    NSString *vsh = [NSString stringWithContentsOfFile:vshFile
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    
    NSString *fsh = [NSString stringWithContentsOfFile:fshFile
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    
    // Create and compile vertex shader.
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
    uniforms2[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms2[UNIFORM_TEXTURE_SAMPLER] = glGetUniformLocation(_program, "s_texture");
    uniforms2[UNIFORM_GAMMA_VALUE] = glGetUniformLocation(_program, "gamma");
    uniforms2[UNIFORM_BACKGROUND_AVG_COLOR] = glGetUniformLocation(_program, "additionalColor");
    uniforms2[UNIFORM_BACKGROUND_AVG_COLOR_STRENGTH] = glGetUniformLocation(_program, "strength");
    
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
    glShaderSource(*shader, 1, (const GLchar**)&source, NULL);
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
    GLint status = 0;
    
    glValidateProgram(prog);
    
#if defined(DEBUG)
    GLint logLength = 0;

    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
#endif
    
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


- (void)draw:(Entity*)entity highlighted:(BOOL)highlighted
{
    // Switch to this shader
    glUseProgram(_program);

    float strength = 0.1;
    
    GLKVector3 color = GLKVector3Make(1, 1, 1);
    if (entity.backgroundColor)
    {
        CGFloat red, green, blue, alpha;
        [entity.backgroundColor getRed:&red green:&green blue:&blue alpha:&alpha];
        color = GLKVector3Make(red, green, blue);
    }
    float factor = MAX(color.x, MAX(color.y, color.z));
    if (factor <= 0)
        color = GLKVector3Make(1, 1, 1);
   
    color = GLKVector3DivideScalar(color, factor);
    
    GLKMatrix4 _cameraModelViewMatrix = GLKMatrix4Multiply(entity.cameraMatrix, entity.modelviewMatrix);
    GLKMatrix4 _modelViewProjectionMatrix = GLKMatrix4Multiply(entity.projectionMatrix, _cameraModelViewMatrix);
    
    glUniformMatrix4fv(uniforms2[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
    

    // Setup the texture sampler
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, entity.texture.name);
    glUniform1i(uniforms2[UNIFORM_TEXTURE_SAMPLER], 0);
    
    if (entity.parentEntity) {
        glUniform1f(uniforms2[UNIFORM_GAMMA_VALUE], 1.0 / entity.parentEntity.brightness);
    } else {
        glUniform1f(uniforms2[UNIFORM_GAMMA_VALUE], 1.0 / entity.brightness);
    }
    
    glUniform1f(uniforms2[UNIFORM_BACKGROUND_AVG_COLOR_STRENGTH], strength);
    glUniform3fv(uniforms2[UNIFORM_BACKGROUND_AVG_COLOR], 1, color.v);
    
    glDisable(GL_STENCIL_TEST);
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    
    [entity drawObjectWithShadow:NO];
}
@end

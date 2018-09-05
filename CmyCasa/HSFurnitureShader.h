//
//  HSFurnitureShader.h
//  Homestyler
//
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import  "Entity.h"

@interface HSFurnitureShader : NSObject
- (BOOL)loadShaders;
- (void)draw:(Entity*)entity highlighted:(BOOL)highlighted;
@property (assign) GLuint _program;

@end

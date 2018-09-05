//
//  AlphaCutOffShader.h
//  Homestyler
//
//  Created by Itamar Berger on 11/5/13.
//
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import  "Entity.h"

@interface AlphaCutOffShader : NSObject
- (BOOL)loadShaders;
- (void) draw: (Entity*) entity;
@property (assign) GLuint _program;

@end

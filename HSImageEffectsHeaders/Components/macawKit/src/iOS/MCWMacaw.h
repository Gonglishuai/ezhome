/********************************************************************
 * (C) Copyright 2013 by Autodesk, Inc. All Rights Reserved. By using
 * this code,  you  are  agreeing  to the terms and conditions of the
 * License  Agreement  included  in  the documentation for this code.
 * AUTODESK  MAKES  NO  WARRANTIES,  EXPRESS  OR  IMPLIED,  AS TO THE
 * CORRECTNESS OF THIS CODE OR ANY DERIVATIVE WORKS WHICH INCORPORATE
 * IT.  AUTODESK PROVIDES THE CODE ON AN 'AS-IS' BASIS AND EXPLICITLY
 * DISCLAIMS  ANY  LIABILITY,  INCLUDING CONSEQUENTIAL AND INCIDENTAL
 * DAMAGES  FOR ERRORS, OMISSIONS, AND  OTHER  PROBLEMS IN THE  CODE.
 *
 * Use, duplication,  or disclosure by the U.S. Government is subject
 * to  restrictions  set forth  in FAR 52.227-19 (Commercial Computer
 * Software Restricted Rights) as well as DFAR 252.227-7013(c)(1)(ii)
 * (Rights  in Technical Data and Computer Software),  as applicable.
 *******************************************************************/

#import <Foundation/Foundation.h>
#import "MCWMacawEffect.h"
#import "MCWImageView.h"

static const NSString * kMaxTextureUnits = @"MaxTextureUnits";
static const NSString * kMaxTextureSize = @"MaxTextureUnits";

@interface MCWMacaw : NSObject

@property (nonatomic, assign) BOOL enableBenchmarking;
@property (nonatomic, strong) NSArray * effects;

+ (MCWMacaw *)instance;

- (UIImage *) renderEffect:(MCWMacawEffect *)effect
                   toImage:(UIImage *)inputImage;

- (void) renderEffect:(MCWMacawEffect *)effect
     toMacawImageView:(MCWImageView *)view
            withImage:(UIImage *)inputImage;

- (void) renderEffect:(MCWMacawEffect *)effect
     toMacawImageView:(MCWImageView*)view
     withInputTexture:(GLuint)texture
               ofSize:(CGSize)texSize;

 /*
  The following two functions assume input image bytes are 
  in BGRA8888 format (this is what you get from an AVCatpureSession 
  typically)
 */
- (void) renderEffect:(MCWMacawEffect *)effect
     toMacawImageView:(MCWImageView*)view
       withImageBytes:(GLubyte *)inputImage
         andImageSize:(CGSize)imgSize;

- (void) renderEffects:(NSArray *)effects
     toMacawImageViews:(NSArray *)views
       withImageBytes:(GLubyte *)inputImage
         andImageSize:(CGSize)imgSize;

/*
 Use the constants define above to get the relevant info
 */
- (NSDictionary *) openGLInfo;

/*
 Generates a context using the same share group as the default context in 
 order to facilitate sharing of OGL resources between different contexts.
 */
- (EAGLContext *) newContext;

@end

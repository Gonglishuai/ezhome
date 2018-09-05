//
//  PaintSession.h
//  Homestyler
//
//  Created by Itamar Berger on 9/12/13.
//
//

#import <Foundation/Foundation.h>
#import "UIScribble.h"

@interface UIPaintSession : NSObject
@property (strong, nonatomic) UIColor* color;
@property (strong, nonatomic) UIImage* texture;
@property (nonatomic, readwrite) BOOL isPositive;
@property (strong, nonatomic, readonly) UIImage* result;

- (void)addScribble:(UIScribble*)scribble;
- (id)initWithImage:(UIImage*)image withScreenSize:(CGSize) size;
- (void)addPredefineMask:(UIImage*)mask;
- (BOOL)gotAnythingToUndo;
- (void)undo;
- (BOOL)gotAnythingToRedo;
- (void)redo;
- (void)reset;
- (void)setOpacity:(CGFloat)opacity;
- (void)setBrightness:(NSUInteger)brightness;
- (void)enableAmbientOcclusion:(float)maxDarkenColor kSize:(float)kSize sigma:(float)sigma;
- (void)disableAmbientOcclusion;

+ (UIImage*)gammaCorrectImage:(UIImage*)image withGamma:(float)gamma;

@end

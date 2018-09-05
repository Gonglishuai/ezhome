//
//  UIScribble.h
//  Homestyler
//
//  Created by Itamar Berger on 9/12/13.
//
//

#import <Foundation/Foundation.h>

@interface ScribbleLinePart : NSObject
@property (assign, atomic) CGPoint start;
@property (assign, atomic) CGPoint end;
@property (strong, nonatomic) UIColor* color;
-(ScribbleLinePart*)initWithStart:(CGPoint)start end:(CGPoint)end color:(UIColor*)color;
@end

@interface UIScribble : NSObject
@property (strong, nonatomic) NSMutableArray* line;
@property (assign) BOOL useSimple;
@property (assign) float lineWidth;
-(UIScribble*)initWithMode:(BOOL)useSimple lineWidth:(float)lineWidth;
-(void)addToLine:(ScribbleLinePart*)linePart;
@end


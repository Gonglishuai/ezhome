//
//  UIScribble.m
//  Homestyler
//
//  Created by Itamar Berger on 9/12/13.
//
//

#import "UIScribble.h"

@implementation ScribbleLinePart
-(ScribbleLinePart*)initWithStart:(CGPoint)start end:(CGPoint)end color:(UIColor*)color {
    if (self = [super init]) {
        self.start = start;
        self.end = end;
        self.color = color;
    }
    return self;
}
@end

@implementation UIScribble
-(UIScribble*)initWithMode:(BOOL)useSimple lineWidth:(float)lineWidth{
    if (self = [super init]) {
        self.line = [[NSMutableArray alloc] init];
        self.useSimple = useSimple;
        self.lineWidth = lineWidth;
    }
    return self;
}

-(void)addToLine:(ScribbleLinePart*)linePart {
    [self.line addObject:linePart];
}

@end

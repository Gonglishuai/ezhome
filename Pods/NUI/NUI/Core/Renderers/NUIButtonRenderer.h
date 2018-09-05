//
//  NUIButtonRenderer.h
//  NUIDemo
//
//  Created by Tom Benner on 11/24/12.
//  Copyright (c) 2012 Tom Benner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
#import "NUIGraphics.h"
#import "NUIRenderer.h"
#import "NUISettings.h"

@interface NUIButtonRenderer : NSObject

+ (void)render:(UIButton*)button withClass:(NSString*)className;

+ (void)alterButtonAttributedTitle:(UIButton*)button property:(NSString*)property controlState:(UIControlState)controlState className:(NSString*)className;

@end

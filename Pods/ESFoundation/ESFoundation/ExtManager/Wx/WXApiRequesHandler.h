//
//  WXApiRequesHandler.h
//  Consumer
//
//  Created by 董鑫 on 16/7/23.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApiObject.h"
@interface WXApiRequesHandler : NSObject

+ (BOOL)sendText:(NSString *)text
         InScene:(enum WXScene)scene;
+ (BOOL)sendLinkURL:(NSString *)urlString
            TagName:(NSString *)tagName
              Title:(NSString *)title
        Description:(NSString *)description
         ThumbImage:(UIImage *)thumbImage
            InScene:(enum WXScene)scene;
@end

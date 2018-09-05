//
//  ESSessionConfig.m
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESSessionConfig.h"
#import "NIMKitConfig.h"
#import "UIImage+NIMKit.h"

@implementation ESSessionConfig

- (NSArray *)mediaItems {
    NSArray *defaultMediaItems = @[[NIMMediaItem item:@"onTapMediaItemPicture:"
                                          normalImage:[UIImage nim_imageInKit:@"bk_media_picture_normal"]
                                        selectedImage:[UIImage nim_imageInKit:@"bk_media_picture_nomal_pressed"]
                                                title:@"相册"],
                                   
                                   [NIMMediaItem item:@"onTapMediaItemShoot:"
                                          normalImage:[UIImage nim_imageInKit:@"bk_media_shoot_normal"]
                                        selectedImage:[UIImage nim_imageInKit:@"bk_media_shoot_pressed"]
                                                title:@"拍摄"],
                                   ];
    return defaultMediaItems;
}

- (BOOL)shouldHandleReceipt {
    return YES;
}

- (NSArray<NSNumber *> *)inputBarItemTypes{
    if (self.session.sessionType == NIMSessionTypeP2P && [[NIMSDK sharedSDK].robotManager isValidRobot:self.session.sessionId])
    {
        //和机器人 点对点 聊天
        return @[
                 @(NIMInputBarItemTypeTextAndRecord),
                 ];
    }
    return @[
             @(NIMInputBarItemTypeVoice),
             @(NIMInputBarItemTypeTextAndRecord),
             @(NIMInputBarItemTypeEmoticon),
             @(NIMInputBarItemTypeMore)
             ];
}

- (BOOL)shouldHandleReceiptForMessage:(NIMMessage *)message
{
    //文字，语音，图片，视频，文件，地址位置和自定义消息都支持已读回执，其他的不支持
    NIMMessageType type = message.messageType;
    
    return type == NIMMessageTypeText ||
    type == NIMMessageTypeAudio ||
    type == NIMMessageTypeImage ||
    type == NIMMessageTypeVideo ||
    type == NIMMessageTypeFile ||
    type == NIMMessageTypeLocation ||
    type == NIMMessageTypeCustom;
}

- (NSArray<NIMInputEmoticonCatalog *> *)charlets
{
    return [self loadChartletEmoticonCatalog];
}

- (BOOL)disableProximityMonitor{
    return NO;
}

- (NIMAudioType)recordType
{
    return NIMAudioTypeAMR;
}


- (NSArray *)loadChartletEmoticonCatalog{
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"ESIMEmoticon.bundle"
                                         withExtension:nil];
    NSBundle *bundle = [NSBundle bundleWithURL:url];
    NSArray  *paths   = [bundle pathsForResourcesOfType:nil inDirectory:@""];
    NSMutableArray *res = [[NSMutableArray alloc] init];
    for (NSString *path in paths) {
        BOOL isDirectory = NO;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            NIMInputEmoticonCatalog *catalog = [[NIMInputEmoticonCatalog alloc]init];
            catalog.catalogID = path.lastPathComponent;
            NSArray *resources = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:@"content"]];
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (NSString *path in resources) {
                NSString *name  = path.lastPathComponent.stringByDeletingPathExtension;
                NIMInputEmoticon *icon  = [[NIMInputEmoticon alloc] init];
                icon.emoticonID = [self stringByDeletingPictureResolution:name];
                icon.filename   = path;
                [array addObject:icon];
            }
            catalog.emoticons = array;
            
            NSArray *icons     = [NSBundle pathsForResourcesOfType:nil inDirectory:[path stringByAppendingPathComponent:@"icon"]];
            for (NSString *path in icons) {
                NSString *name  = [self stringByDeletingPictureResolution:path.lastPathComponent.stringByDeletingPathExtension];
                if ([name hasSuffix:@"normal"]) {
                    catalog.icon = path;
                }else if([name hasSuffix:@"highlighted"]){
                    catalog.iconPressed = path;
                }
            }
            [res addObject:catalog];
        }
    }
    return res;
}

- (NSString *)stringByDeletingPictureResolution:(NSString *)text {
    NSString *doubleResolution  = @"@2x";
    NSString *tribleResolution = @"@3x";
    NSString *fileName = text.stringByDeletingPathExtension;
    NSString *res = [text copy];
    if ([fileName hasSuffix:doubleResolution] || [fileName hasSuffix:tribleResolution]) {
        res = [fileName substringToIndex:fileName.length - 3];
        if (text.pathExtension.length) {
            res = [res stringByAppendingPathExtension:text.pathExtension];
        }
    }
    return res;
}

@end

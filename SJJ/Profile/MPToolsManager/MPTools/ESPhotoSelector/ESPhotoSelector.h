//
//  ESPhotoSelector.h
//  Consumer
//
//  Created by zhang dekai on 2018/2/5.
//  Copyright © 2018年 EasyHome. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ESReturnedPhotos)(NSArray<UIImage*> *photos);

/**
 相册，拍照，获取照片 (使用时，注意设为全局变量)
 */
@interface ESPhotoSelector : NSObject

@property (nonatomic, assign) NSInteger maxSelectNumber;//相册选取照片最大数，默认 1 张

@property (nonatomic, copy) ESReturnedPhotos returnedPhotos;//获取到的 photos

/**
 设置调用拍照，相册的当前 UIViewController （）

 @param currentViewController UIViewController
 */
- (void)selectPhoto:(UIViewController *)currentViewController;


@end

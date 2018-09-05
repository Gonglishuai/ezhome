//
//  ESIMGalleryViewController.h
//  Consumer
//
//  Created by 焦旭 on 2017/8/17.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESIMGalleryItem : NSString
@property (nonatomic,copy)  NSString    *thumbPath;
@property (nonatomic,copy)  NSString    *imageURL;
@property (nonatomic,copy)  NSString    *name;
@end

@interface ESIMGalleryViewController : UIViewController
- (instancetype)initWithItem:(ESIMGalleryItem *)item;
@end

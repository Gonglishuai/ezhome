//
//  SHVersionNoteCell.h
//  Consumer
//
//  Created by 牛洋洋 on 2017/4/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SHVersionNoteCellDelagate <NSObject>

- (NSString *)getVersionNoteAtIndex:(NSInteger)index;

@end

@interface SHVersionNoteCell : UITableViewCell

@property (nonatomic, assign) id<SHVersionNoteCellDelagate>cellDelegate;

- (void)updateVersionCellAtIndex:(NSInteger)index;

@end

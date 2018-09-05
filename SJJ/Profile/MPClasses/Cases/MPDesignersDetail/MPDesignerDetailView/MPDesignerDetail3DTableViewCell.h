//
//  MPDesignerDetail3DTableViewCell.h
//  Consumer
//
//  Created by 董鑫 on 16/8/23.
//  Copyright © 2016年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>


@class MP3DCaseModel;

@class ESDesignCaseList;

@protocol MPDesignerDetail3DTableViewCellDelegate <NSObject>
- (ESDesignCaseList *)get3DDesignerDetailModelAtIndex:(NSInteger)index;

@end

@interface MPDesignerDetail3DTableViewCell : UITableViewCell

@property (nonatomic, assign) id<MPDesignerDetail3DTableViewCellDelegate>delegate;
- (void)update3DCellForIndex:(NSInteger)index;
- (void)setModel:(ESDesignCaseList *)model3D;
@end

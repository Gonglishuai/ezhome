//
//  ESPersonalDesignerFirstCell.h
//  Consumer
//
//  Created by Jiao on 2017/7/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESPersonalDesignerFirstCellDelegate <NSObject>

//我的应标
- (void)tapMyBidding;

//我的项目
- (void)tapDesignerMyProject;

//我的资产
- (void)tapMyAssets;

@end

@interface ESPersonalDesignerFirstCell : UITableViewCell
@property (nonatomic, weak) id<ESPersonalDesignerFirstCellDelegate> delegate;
@end

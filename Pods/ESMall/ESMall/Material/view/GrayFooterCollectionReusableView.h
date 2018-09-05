//
//  GrayFooterCollectionReusableView.h
//  Consumer
//
//  Created by jiang on 2017/5/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ESGrayFooterDelegate <NSObject>

- (void)moreButtonDidTapped;

@end

@interface GrayFooterCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *moreButton;

@property (nonatomic, assign) id<ESGrayFooterDelegate>viewDelegate;

@end

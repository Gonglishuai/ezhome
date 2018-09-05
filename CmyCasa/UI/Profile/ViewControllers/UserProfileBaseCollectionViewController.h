//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import <Foundation/Foundation.h>
#import "ProfilePageBaseViewController.h"


@interface UserProfileBaseCollectionViewController : ProfilePageBaseViewController< UICollectionViewDataSource, UICollectionViewDelegate>


@property(nonatomic, strong) UIView * masterMenuHeaderView;

-(void)insertHeaderView:(UIView*)headerView;
@end
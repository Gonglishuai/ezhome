//
//  ProfilePageBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/22/13.
//
//

#import "ProfilePageBaseViewController.h"

#define EMPTY_DATA_DEFAULT_MESSAGE  NSLocalizedString(@"activity_no_data_message_data", @"")

@interface ProfilePageBaseViewController ()

@end

@implementation ProfilePageBaseViewController

-(void)dealloc{
    self.presentingData = nil;
    NSLog(@"dealloc - ProfilePageBaseViewController");
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)removeFooter{
    
}

- (void)removeHeader{

}

- (void)initDisplay:(NSArray *)data {

    self.presentingData = data;
}

- (void)updateDisplay:(BOOL)isLoggedInUserProfile{

    if ((self.presentingData) && (self.presentingData.count>0))
    {
        //refresh ui when data exists
        self.listMessageLabel.hidden = YES;
        [self.loadingIndicator stopAnimating];
    }
    else
    {//when no data show the appropriate copy
        self.listMessageLabel.hidden = NO;
        self.listMessageLabel.text = EMPTY_DATA_DEFAULT_MESSAGE;
        if(self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(getMessageForEmptyData:)])
        {
            self.listMessageLabel.text = [self.dataDelegate getMessageForEmptyData:isLoggedInUserProfile];
        }
    }
}

- (BOOL)scrollToTop
{
    return YES;
}

- (void)startLoadingIndicator {
    
}

- (void)stopLoadingIndicator {
    
}

- (void)setViewDisabled:(BOOL)disabled
{
    [self.view setUserInteractionEnabled:!disabled];
}

-(void)insertHeaderView:(UIView *)headerView{
    
}

-(void)refreshContent{
    
}

#pragma mark ProfilePageCollectionDelegate
-(Class)getCollectionCellClass{
    return nil;
}

-(UIEdgeInsets) getCellEdgeInsets{
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    return edgeInsets;
}

-(CollectionViewRowsSize)getCollectionGridSize{
    CollectionViewRowsSize size;
    size.collumnsCount = 0;
    size.minRowsCount = 0;
    return size;
}

-(NSString *)getMessageForEmptyData:(BOOL)isCurrentUser{
    return nil;
}

-(CGSize)sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeZero;
}

-(CGFloat)minimumLineSpacingForSection{
    return 0;
}

-(ProfileUserType)getViewedProfileUserType{
    return kUserProfileTypePublicUser;
}

@end

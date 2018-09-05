//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//444


#import <Foundation/Foundation.h>
#import "ProfileMasterBaseViewController.h"

@class ProfilePagesMenuViewController_iPhone;


@interface ProfileMasterViewController_iPhone : ProfileMasterBaseViewController<PRofileMasterDelegate,ProfileCountersDelegate>

@property (nonatomic, strong) ProfilePagesMenuViewController_iPhone * menuController ;
@property (weak, nonatomic) IBOutlet UIButton *changePageButton;

- (IBAction)openProfileOptionsMenu:(id)sender;

@end


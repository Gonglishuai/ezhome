//
//  ProfileDesignsViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/23/13.
//
//

#import <UIKit/UIKit.h>
#import "ProfileInstanceBaseViewController.h"

@class ProfilePageBaseViewController;

@interface ProfileDesignsViewController : ProfileInstanceBaseViewController <ProfilePageCollectionDelegate, DesignItemDelegate, LikeDesignDelegate, CommentDesignDelegate>

-(void)populateViewController:(NSArray*)designFromServer isSignInUser:(BOOL)isSignInUser;

@property(nonatomic,assign) id <DesignItemDelegate, ProfileInstanceDataDelegate, ProfileCountersDelegate, LikeDesignDelegate, CommentDesignDelegate> rootDesignDelegate;

@end

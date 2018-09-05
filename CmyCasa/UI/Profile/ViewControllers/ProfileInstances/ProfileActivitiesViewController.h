//
//  ProfileProfessionalsViewController.h
//  Homestyler
//
//  Created by Maayan Zalevas on 12/23/13.
//
//

#import "BaseActivityTableCell.h"
#import "ProfileInstanceBaseViewController.h"

@protocol ProfileCountersDelegate;
@protocol ActivityTableCellDelegate;

///////////////////////////////////////////////////////
//                  INTERFACE                        //
/////////////////////////////////////////////////////// 

@interface ProfileActivitiesViewController : ProfileInstanceBaseViewController <ActivityTableCellDelegate, MFMailComposeViewControllerDelegate>
@property(nonatomic,assign) id<ProfileInstanceDataDelegate, ProfileCountersDelegate, ActivityTableCellDelegate, LikeDesignDelegate, CommentDesignDelegate> rootActivityDelegate;

- (id)initWithRect:(CGRect)rect delegate:(id<ProfileInstanceDataDelegate, ProfileCountersDelegate, ActivityTableCellDelegate, LikeDesignDelegate, CommentDesignDelegate>)delegate;

@end

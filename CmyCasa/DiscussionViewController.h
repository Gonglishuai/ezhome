//
//  DiscussionViewController.h
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"
#import "DesignBaseClass.h"
#import "DesignDiscussionDO.h"
#import "DiscussionsBaseViewController.h"

@interface DiscussionViewController : UIViewController<DiscussionViewControllerDelegate, DisscussionCommentsDelegate>

@property (nonatomic, assign) id<AddCommentDelegate> addCommentDelegate;
- (void)init:(DesignBaseClass*)galleryItem;
- (BOOL)loginRequestEndedwithState:(BOOL) state;
- (IBAction)closePressed:(id)sender;
@end

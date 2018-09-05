//
//  DiscussionsBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/23/13.
//
//

#import <UIKit/UIKit.h>

@class DesignDiscussionDO;


@class CommentCell;

@protocol  DisscussionCommentsDelegate <NSObject>

@optional
-(void)createTempCommentForComment:(CommentDO*)comment;
-(void)publishComment:(CommentDO*)comment;
-(void)moveTableViewForVisibleInput:(CommentCell*)cell;
-(void)moveTableViewForLastIndexPath:(CommentDO*)comment;
-(void)moveTableViewForInitialFrame;
-(void)moveTableViewForWritingCommentFrame;
-(void)createNewComment;
@end

@interface DiscussionsBaseViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,DisscussionCommentsDelegate>


@property (weak, nonatomic) IBOutlet UITableView * tableView;
@property(nonatomic) DesignDiscussionDO * myDiscussion;


-(void)startLoading;
-(void)stopLoading;

@end

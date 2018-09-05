//
//  GalleryImageViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/21/13.
//
//

#import "GalleryImageViewController.h"
#import "GalleryImageDesignInfoCell.h"
#import "CommentCell.h"
#import "NoCommentCell.h"

#import "ProgressPopupBaseViewController.h"

#import "HelpersRO.h"
#import "ImageFetcher.h"

#import "NSString+Contains.h"
#import "UILabel+Size.h"
#import "UIImageView+LoadImage.h"
#import "UIView+ReloadUI.h"

#import <MJRefresh.h>

#import <QuartzCore/QuartzCore.h>

#define TABLEVIEW_DELTA_HEIGHT 95
#define MAX_STARWORDS_LENGTH 200
#define MIN_STARWORDS_LENGTH 1

@interface GalleryImageViewController ()
{
    CommentDO* _prevReplayComment;
    BOOL _isCurrent; // TODO: refactor to unify it with isCurrentVcDisplay
    BOOL _alertDisplayed;
}

//@property (nonatomic) NSInteger heightOfFullTableView;

@property (nonatomic) DesignDiscussionDO * designDiscussion;
@property (nonatomic) CommentDO * pendingLoginComment;
@property (nonatomic) CommentDO * newcomment;

@property (nonatomic, weak) GalleryImageItemInfoCell * itemInfoCell;

@property (nonatomic) int initialScrollViewHeight;
@property (nonatomic) BOOL waitingForCommentsReplyBeforeNewComment;

@end

@implementation GalleryImageViewController

///////////////////////////////////////////////////////

- (void)viewDidLoad
{
    [super viewDidLoad];
   
    //self.heightOfFullTableView=self.tableview.frame.size.height;
    
    self.waitingForCommentsReplyBeforeNewComment=NO;
    
//    [self addObservers];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCommentsFinishedNotification:)
                                                 name:CommentsForDesignReadyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCommentsFinishedWithFailNotification:)
                                                 name:CommentsForDesignFailedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self.view
                                             selector:@selector(reloadUI)
                                                 name:@"NetworkStatusChanged" object:nil];
    

    UIView *space = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.inputBox.leftView = space;
    self.inputBox.leftViewMode = UITextFieldViewModeAlways;
    self.inputBox.placeholder = NSLocalizedString(@"commentTip",@"");

    [self.tableview registerNib:[UINib nibWithNibName:@"DesignDetailEmptyRoomCell" bundle:nil] forCellReuseIdentifier:@"GalleryImageEmptyRoomCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"NoCommentCell" bundle:nil] forCellReuseIdentifier:@"NoCommentCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"CommentPrivateDesignCell" bundle:nil] forCellReuseIdentifier:@"CommentPrivateDesignCell"];
    
    [self setMJRefresh];
    
    if (self.itemDetail.type != eEmptyRoom && [self.itemDetail getTotalCommentsCount] != 0) {
        [self readCommentsAction:self.itemDetail._id];
        self.tableview.bounces = YES;
    }
    
    [self.view reloadUI];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (_isCurrent) {
        [self addObservers];
    }

//    [self.view reloadUI];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self removeObservers];
    [self clearInputBox];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc{
    NSLog(@"dealloc - GalleryImageViewController");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CommentsForDesignReadyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:CommentsForDesignFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self.view name:@"NetworkStatusChanged" object:nil];
}

#pragma mark -
-(void)addObservers{
    // always remove observers to make sure they won't be added multipe times
    [self removeObservers];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self selector:@selector(onKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [center addObserver:self selector:@selector(onKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [center addObserver:self selector:@selector(textFieldEditChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)removeObservers{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

-(void)getCommentsFinishedWithFailNotification:(NSNotification *)notification{

    if (_alertDisplayed || !self.isCurrentVcDisplay)
        return;

    if ([[notification object] isEqualToString:self.itemDetail._id]==FALSE) {
        return;
    }

    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(getCommentsFinishedWithFailNotification:) withObject:notification waitUntilDone:NO];
        return;
    }

    _alertDisplayed = YES;
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                   message:NSLocalizedString(@"erh_unknown_error_msg", @"")
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
    [alert show];
}

-(void)getCommentsFinishedNotification:(NSNotification*)notification{
    
    if ([[notification object] isEqualToString:self.itemDetail._id] == NO) {
        
        return;
    }

    // reload
    if (self.designDiscussion.loadedCount == 1) {
        [self.designDiscussion.comments removeAllObjects];
    }

    BOOL dataLoaded = YES;
    DesignDiscussionDO * commentsDO = [[[AppCore sharedInstance] getCommentsManager] getLoadedCommentsForDesignID:self.itemDetail._id];
    self.designDiscussion.totalCount = commentsDO.totalCount;
    if (self.designDiscussion.comments.count > 0) { // append
        if (commentsDO.comments.count != 0) {
            [self.designDiscussion.comments addObjectsFromArray:commentsDO.comments];
        } else {
            dataLoaded = NO;
        }
    } else {
        self.designDiscussion = commentsDO;
        self.designDiscussion.loadedCount = 1; //Default
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        self.tableview.mj_footer.hidden = NO;

        [self.tableview.mj_header endRefreshing];
        if (dataLoaded && self.designDiscussion.comments.count < self.designDiscussion.totalCount) {
            [self.tableview.mj_footer endRefreshing];
        }

        [self refreshComments];
    });
    
//    [self moveTableViewToIndexPath:self.designDiscussion];

    if (self.waitingForCommentsReplyBeforeNewComment) {
        [self createNewComment];
    }

    [self.view reloadUI];
}

- (void)refreshComments {
    NSRange range = NSMakeRange(1, 1);
    NSIndexSet *sections = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableview reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];

    if ([self.itemInfoCell isKindOfClass:[GalleryImageDesignInfoCell class]]) {
        GalleryImageDesignInfoCell *designInfoCell = (GalleryImageDesignInfoCell *)self.itemInfoCell;
        [designInfoCell refreshCommentsCount];
    }
}

-(void)readCommentsAction:(id)sender
{
    [[[AppCore sharedInstance] getCommentsManager] getCommentsForDesignID:self.itemDetail._id offset:self.designDiscussion.loadedCount];
}

- (void)setCommentsViewForInitialFrame {
    [self resignFirstResponder];
    [self moveTableViewForInitialFrame];
}

#pragma mark - override baseclass

- (void)refreshDesignInfo {
    // might need to resize design info cell due to the update of design tile and/or description
    [self.tableview reloadData];
//    if (self.itemInfoCell == nil)
//        return;
//
//    [self.itemInfoCell resetUI];
//    [self.itemInfoCell initData:self.itemDetail];
}

-(void)loadUI{
        
    if (self.isImageRequested==NO) {
        self.isImageRequested=YES;
    }
    
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_BROWSE_DESIGN
//                withParameters:@{EVENT_PARAM_NAME_DESIGN_ID:(self.itemDetail._id)?self.itemDetail._id:@"",
//                                 EVENT_PARAM_NAME_LOAD_ORIGIN:(self.eventLoadOrigin)?self.eventLoadOrigin:@""
//                                 }];
    
    
    [self.view reloadUI];
}

-(void)setIsCurrent:(BOOL)isCurrent forceUpdate:(BOOL)forceUpdate {
    if (!forceUpdate && _isCurrent == isCurrent)
        return;
    
    _isCurrent = isCurrent;
    if (_isCurrent) {
        [self addObservers];
    } else {
        [self removeObservers];
    }
}

- (void)clearInputBox {
    self.inputBox.text = @"";
    self.inputBox.placeholder = NSLocalizedString(@"commentTip",@"");
}

-(GalleryImageDesignInfoCell *)currentCell {
    NSIndexPath * path= [NSIndexPath indexPathForRow:0 inSection:0];
    if (path == nil)
        return nil;
    
    GalleryImageDesignInfoCell * cell = (GalleryImageDesignInfoCell *)[self.tableview cellForRowAtIndexPath:path];
    return cell;
}

-(UIImage*)getCurrentPresentingImage{
    return self.mainDesignImage.image;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (self.itemDetail.type == eEmptyRoom)
    {
        return 1;
    }

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0)
        return 1;

    // comments section

    if ((self.designDiscussion.dataLoaded && self.designDiscussion.totalCount == 0) || self.itemDetail.commentsCount == 0)
        return 1; // no comments yet

    NSInteger count = [self.designDiscussion.comments count];
    if (!self.itemDetail.isPublicOrPublished) {
        count += 1; // private design can't be commented
    }
    return count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *CellIdentifierInfo= @"CellBase";
    static NSString *CellIdentifier = @"Cell";
    
    if (indexPath.section == 0) {
        //design Info Cell
        NSString * cellID = eEmptyRoom == self.itemDetail.type ? @"GalleryImageEmptyRoomCell" : CellIdentifierInfo;
        self.itemInfoCell = (GalleryImageItemInfoCell*)[self.tableview dequeueReusableCellWithIdentifier:cellID];
        self.itemInfoCell.parentTableHolder = self;
        self.itemInfoCell.delegate = (id<GalleryImageDesignItemDelegate>)self.parentViewController;
        [self.itemInfoCell initData:self.itemDetail];

        return self.itemInfoCell;
    }

    if (indexPath.section == 1 && ((self.designDiscussion.dataLoaded && self.designDiscussion.totalCount == 0) || self.itemDetail.commentsCount == 0)){
        NoCommentCell *cell = [self.tableview dequeueReusableCellWithIdentifier:@"NoCommentCell"];
        if (self.itemDetail.isPublicOrPublished) {
            [cell setTipText:NSLocalizedString(@"commentString", @"No comments yet")];
        } else {
            // private design
            [cell setTipText:NSLocalizedString(@"cannot_comment_private_design", @"Private design can't be commented")];
        }

        return cell;
    }

    if (!self.itemDetail.isPublicOrPublished && indexPath.row == self.designDiscussion.totalCount) {
        UITableViewCell * cell = [self.tableview dequeueReusableCellWithIdentifier:@"CommentPrivateDesignCell"];
        return cell;
    } else {
        NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithCapacity:0];
        NSString * imagePath = @"";
        CommentCell * cell=nil;
        CommentDO * comment=[self.designDiscussion.comments objectAtIndex:indexPath.row];

        //any other reply cell
        cell=(CommentCell*)[self.tableview dequeueReusableCellWithIdentifier:CellIdentifier];
        imagePath=[comment  imageUrl];
        [self loadCommentImage:imagePath forCell:cell withDictionary:dict];
        [cell initWithComment:comment];
        
        if (self.itemDetail.isPublicOrPublished && indexPath.row == self.designDiscussion.comments.count - 1) {
            cell.seperateBarImage.hidden = YES; // hide bottom line for last item
        }
        
        cell.delegate = self;
        
        return  cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return UITableViewAutomaticDimension; // self-sizing with auto layout
    } else if (indexPath.section == 1 && ((self.designDiscussion.dataLoaded && self.designDiscussion.totalCount == 0) || self.itemDetail.commentsCount == 0)) {
        return 200;
    } else if (!self.itemDetail.isPublicOrPublished && indexPath.row == self.designDiscussion.totalCount) {
        return 40;
    } else {
        return UITableViewAutomaticDimension;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return (eEmptyRoom != self.itemDetail.type);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {

    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section != 1)
        return;

    if (self.designDiscussion.comments.count > 0 && [self.itemDetail isPublicOrPublished]) {
        CommentCell * cell = [self.tableview cellForRowAtIndexPath:indexPath];
        [self createTempCommentForComment:cell.mycomment];
        [self performSelector:@selector(scrollToPath:) withObject:indexPath afterDelay:0.4];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0f;
}

-(void)loadCommentImage:(NSString*)image forCell:(CommentCell*)cell withDictionary:(NSMutableDictionary*)dict{

    [cell.userAvatar setImage:[UIImage imageNamed:@"user_avatar"]];

    if ([NSString isNullOrEmpty:image])
        return;

    [cell.userAvatar loadImageFromUrl:image defaultImageName:nil];
}

#pragma mark Discussions Delegate
-(void)createNewCommentPendingToLoadComments{
    self.waitingForCommentsReplyBeforeNewComment=YES;
}

-(void)createNewComment{
    if (self.designDiscussion == nil) {
        [[[AppCore sharedInstance] getCommentsManager]getCommentsForDesignID:self.itemDetail._id offset:1];
    }else{
        if (![[UserManager sharedInstance] isLoggedIn]) {
            [[UIMenuManager sharedInstance] loginRequestedIphone:self withCompletionBlock:^(BOOL success) {
                if (success == YES) {
                    [self createNewComment];
                }
            }
                                                      loadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_COMMENT];
        }else{
            if (_prevReplayComment) {
                [_prevReplayComment.childComments removeLastObject];
            }
            
            if (self.isTableMoved) {
                [self moveTableViewToIndexPath:nil];
            }
            
            [self performSelector:@selector(moveTableViewToIndexPath:) withObject:nil afterDelay:0.5];
            [self.inputBox becomeFirstResponder];
        }
    }
}

-(void)scrollToPath:(NSIndexPath*)path{
    if (path.section == 1 && path.row < self.designDiscussion.comments.count) {
        [self.tableview scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)createTempCommentForComment:(CommentDO*)comment{
    if (![[UserManager sharedInstance] isLoggedIn]) {
        [[UIMenuManager sharedInstance] loginRequestedIphone:self withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self createTempCommentForComment:comment];
            }
        }                                         loadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_COMMENT ];
    }else{
        _prevReplayComment = comment;
        
        if ([self.designDiscussion getLatestTempCommentCreated]){
            [self.designDiscussion clearTempCommentsOnCancel];
        }
        
        if (_prevReplayComment) {
            [_prevReplayComment.childComments removeLastObject];
        }
        
        if (self.isTableMoved) {
            [self moveTableViewForInitialFrame];
        }
        
        self.newcomment.parentID = comment._id;
        self.newcomment.parentUID = comment.uid;
        self.newcomment.parentDisplayName = comment.displayName;
        self.newcomment.dicReply = [NSDictionary dictionary];
        
        //    [comment.childComments addObject:newcomment];
        //    [self.designDiscussion addTempComment:newcomment];
        
        //hold the curent replay commnet
        _prevReplayComment = comment;
        
        //    [self.tableview setEditing:YES];
        //    [self.tableview reloadData];
        
        //    for (int i = 0; i < [self.designDiscussion.comments count]; i++) {
        //        CommentDO * c = [self.designDiscussion.comments objectAtIndex:i];
        //        NSArray * commentChildren = [c childComments];
        //
        //        if ([commentChildren count] > 0) {
        //
        //            for (int j = 0; j < [commentChildren count]; j++) {
        //                CommentDO * cc = [commentChildren objectAtIndex:j];
        //                if (cc.isTempComment) {
        //                    NSIndexPath * path = [NSIndexPath indexPathForRow:j+1 inSection:i+1];//1 for the header of the table
        //                    [self.tableview scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        //
        //                    break;
        //                }
        //            }
        //        }
        //    }
        
        [self.inputBox becomeFirstResponder];
        
        self.inputBox.placeholder = comment.displayName ? [NSString stringWithFormat:@"@%@",comment.displayName] : @"@" ;
    }
    
}

- (void) loginRequestEndedwithState:(BOOL) state{
    
    if (state==true && self.pendingLoginComment!=nil) {
        [self publishComment:self.pendingLoginComment];
    }
}

-(void)publishComment:(CommentDO*)comment{

    //checked basic validations, now Add comment by sending it to server
    
    if (self.isTableMoved) {
        [self moveTableViewForInitialFrame];
    }
    
    if (![[UserManager sharedInstance] isLoggedIn]) {
        self.pendingLoginComment=comment;
        
        //Send information about login from user comments
        NSString *type=EVENT_PARAM_VAL_UNKNOWN;
        switch ([self getItemType]) {
            case e3DItem:
                type=EVENT_PARAM_VAL_COMMENTS_ON_3D;
                break;
            case e2DItem:
                type=EVENT_PARAM_VAL_COMMENTS_ON_2D;
                break;
            case eArticle:
                type=EVENT_PARAM_VAL_COMMENTS_ON_ARTICLE;
                
                break;
            default:
                type=EVENT_PARAM_VAL_UNKNOWN;
                
                break;
        };
        
//        [HSFlurry logAnalyticEvent:EVENT_NAME_VIEW_SIGNIN_DIALOG withParameters:@{EVENT_PARAM_SIGNUP_TRIGGER:type, EVENT_PARAM_NAME_LOAD_ORIGIN: EVENT_PARAM_VAL_LOAD_ORIGIN_COMMENT}];
        [[UIMenuManager sharedInstance] loginRequestedIphone:self.parentViewController loadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_COMMENT ];
        
        return;
    }
    
    self.pendingLoginComment = nil;
    
    [[ProgressPopupBaseViewController sharedInstance] startLoading:self];
    
    CommentDO * parent = [self.designDiscussion getCommentByID:comment.parentID];
    NSString * itemID = self.itemDetail._id;
    self.newcomment = nil;
    __weak UITableView * tblViewWeak = self.tableview;
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void)
                   {
                       [self.designDiscussion addGeneratedComment:comment forOriginalComment:parent withDesignItem:self.itemDetail withCompletion:^( BOOL status) {
                           
                           dispatch_async(dispatch_get_main_queue(),^(void){
                               
                               if (tblViewWeak.frame.origin.y < 0) {
                                   tblViewWeak.frame = CGRectMake(0,
                                                                  35,
                                                                  tblViewWeak.frame.size.width,
                                                                  tblViewWeak.frame.size.height);
                               }
                               
                               if (status == YES) {
                                   [weakSelf.designDiscussion addTempComment:comment];
                                   weakSelf.itemDetail.commentsCount = [NSNumber numberWithUnsignedInteger:weakSelf.itemDetail.commentsCount.unsignedIntegerValue+1];
                                   
                                   [tblViewWeak setEditing:NO];
                                   NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:1];
                                   [weakSelf performSelector:@selector(scrollToPath:) withObject:path afterDelay:0.5];
                               }else{
                                   [weakSelf.designDiscussion removeTempComment:comment];
                                   UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                                                  message:NSLocalizedString(@"erh_unknown_error_msg", @"")
                                                                                 delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                                                        otherButtonTitles:nil];
                                   [alert show];
                                   
                               }
                               
                               [[ProgressPopupBaseViewController sharedInstance] reset];
                               [[ProgressPopupBaseViewController sharedInstance] stopLoading];

                               [weakSelf refreshComments];
                           });
                       }];
                   });
}

-(void)moveTableViewForVisibleInput:(CommentCell*)cell{
    if (cell) {
        
        NSIndexPath *path=    [self.tableview indexPathForCell:cell];
        if (path) {
            [self.tableview scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

-(void)moveTableViewForLastIndexPath:(CommentDO*)comment{
    int row = (int)[self.designDiscussion.comments indexOfObject:comment];
    if (row < 0) {
        return;
    }

    row += (int)[comment childComments].count + 1;

    NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:1];
    
    if (path) {
        [self.tableview scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)moveTableViewToIndexPath:(DesignDiscussionDO*)comment{
    
    if (self.tableview && self.isTableMoved) {
        [self.tableview scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.tableview.contentOffset = CGPointMake(0, self.tableview.contentOffset.y - 50);
    }
}

-(void)moveTableViewForInitialFrame{
    // TODO: code clean up
//    if (self.isTableMoved==NO) {
//        return;
//    }
//
//    [UIView animateWithDuration:0.3 animations:^{
//        self.tableview.frame=CGRectMake(0,
//                                        self.tableview.frame.origin.y,
//                                        self.tableview.frame.size.width,
//                                        self.heightOfFullTableView);
//    } completion:^(BOOL finished) {
//    }];
}

-(void)moveTableViewForWritingCommentFrame{
    
//    if (self.isTableMoved) {
//        return;
//    }
//    [UIView animateWithDuration:0.3 animations:^{
//        self.tableview.frame=CGRectMake(0, self.tableview.frame.origin.y, self.tableview.frame.size.width,
//                                        self.heightOfFullTableView-TABLEVIEW_DELTA_HEIGHT);
//    } completion:^(BOOL finished) {
//        self.isTableMoved=YES;
//
//    }];
}

-(NSString*)description{
    
    return [NSString stringWithFormat:@"Item Detail id: %@",self.itemDetail._id];
}

- (void)onKeyboardWillShow:(NSNotification *)notification{
    NSDictionary *userInfoDic = notification.userInfo;
    NSTimeInterval duration = [userInfoDic[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //这里是将时间曲线信息(一个64为的无符号整形)转换为UIViewAnimationOptions，要通过左移动16来完成类型转换。
    UIViewAnimationOptions options = [userInfoDic[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    CGRect keyboardRect            = [userInfoDic[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight         = MIN(CGRectGetWidth(keyboardRect), CGRectGetHeight(keyboardRect));
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
            CGFloat offset = keyboardHeight;
            if (@available(iOS 11.0, *)) {
                offset -= self.parentViewController.view.safeAreaInsets.bottom;
            }
            self.inputBox.transform = CGAffineTransformMakeTranslation(0, -offset);
            self.inputBox.hidden = NO;
        } completion:nil];
    });
}

- (void)onKeyboardWillHide:(NSNotification *)notification{
    NSDictionary *userInfoDic = notification.userInfo;
    NSTimeInterval duration = [userInfoDic[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //这里是将时间曲线信息(一个64为的无符号整形)转换为UIViewAnimationOptions，要通过左移动16来完成类型转换。
    UIViewAnimationOptions options = [userInfoDic[UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue] << 16;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:duration delay:0.0 options:options
                         animations:^{
                             self.inputBox.transform = CGAffineTransformIdentity;
                             self.inputBox.hidden = YES;
                         } completion:^(BOOL finished) {
                             [self clearInputBox];
                         }];
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField != self.inputBox)
        return NO;
    
    if (textField.returnKeyType == UIReturnKeyDone && [self.inputBox.text length]!=0) {
        self.newcomment.body=self.inputBox.text;
        [self publishComment:self.newcomment];
        [self.inputBox resignFirstResponder];
        [self clearInputBox];
    }
    [textField reloadInputViews];
    return YES;
}

#pragma mark - Notification Method
-(void)textFieldEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    if (textField != self.inputBox)
        return;
    
    NSString *toBeString = textField.text;
    
    //获取高亮部分
    UITextRange *selectedRange = [textField markedTextRange];
    UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
    
    // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
    if (!position)
    {
        if (toBeString.length > MAX_STARWORDS_LENGTH)
        {
            NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:MAX_STARWORDS_LENGTH];
            if (rangeIndex.length == 1)
            {
                textField.text = [toBeString substringToIndex:MAX_STARWORDS_LENGTH];
            }
            else
            {
                NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, MAX_STARWORDS_LENGTH)];
                textField.text = [toBeString substringWithRange:rangeRange];
            }
        }
        if (toBeString.length >=MIN_STARWORDS_LENGTH && ![[toBeString stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            textField.returnKeyType = UIReturnKeyDone;
            [textField reloadInputViews];
        }else{
            textField.returnKeyType = UIReturnKeyDefault;
            [textField reloadInputViews];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputBox resignFirstResponder];
}


-(CommentDO *)newcomment {
    if (!_newcomment) {
        _newcomment = [[CommentDO alloc] init];
        _newcomment.displayName = [[[UserManager sharedInstance] currentUser] getUserFullName];
        _newcomment.imageUrl = [[[UserManager sharedInstance] currentUser]userProfileImage];
        _newcomment.uid = [[[UserManager sharedInstance] currentUser] userID];
        _newcomment.isTempComment = YES;
        _newcomment.body=@"";
    }
    return _newcomment;
}

-(void)setMJRefresh {
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.designDiscussion.loadedCount = 1;//Reset
        [self readCommentsAction:nil];
    }];
    header.automaticallyChangeAlpha = YES;
    [header setTitle:@"" forState:MJRefreshStateIdle];
    [header setTitle:@"" forState:MJRefreshStatePulling];
    [header setTitle:@"" forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.labelLeftInset = 0;
    self.tableview.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (self.designDiscussion.comments.count < self.designDiscussion.totalCount) {
            self.designDiscussion.loadedCount = self.designDiscussion.loadedCount + 1;
            [self readCommentsAction:nil];
        } else {
            if (self.itemDetail.isPublicOrPublished && self.designDiscussion.comments.count > 0) {
                [self.tableview.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.tableview.mj_footer endRefreshing];
            }
        }
    }];
    footer.automaticallyChangeAlpha = YES;
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer.stateLabel setValue:@"Text_Body3" forKey:@"nuiClass"];
    [footer setTitle:NSLocalizedString(@"no_more", @"No more") forState:MJRefreshStateNoMoreData];
    footer.labelLeftInset = 0;
    footer.hidden = YES;
    self.tableview.mj_footer = footer;
    
}

#pragma mark - public methods

- (void)toggleLikeState {
    GalleryImageDesignInfoCell * cell = [self currentCell];
    if (cell == nil)
        return;
    [cell toggleLikeState];
}

- (void)restoreLikeState {
    GalleryImageDesignInfoCell * cell = [self currentCell];
    if (cell == nil)
        return;
    [cell restoreLikeState];
}

-(void)resetImageLoading {
    self.isImageRequested = NO;
}

@end

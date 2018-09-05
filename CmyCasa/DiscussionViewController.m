//
//  DiscussionViewController.m
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import "DiscussionViewController.h"
#import "CommentViewController.h"
#import "GalleryItemDO.h"
#import "ControllersFactory.h"
#import "UILabel+Size.h"
#import "CommentCell.h"
#import "NoCommentCell.h"
#import "HelpersRO.h"
#import "ImageFetcher.h"
#import "UIImageView+ViewMasking.h"
#import "ProgressPopupViewController.h"
#import <MJRefresh.h>

#define comment_frame_height_close 116
#define comment_frame_height_open 304
#define comment_frame_height_open_diff 188
#define MAX_STARWORDS_LENGTH 200
#define MIN_STARWORDS_LENGTH 1

@interface DiscussionViewController () <DiscussionViewControllerDelegate,UITextFieldDelegate>
{
    DesignDiscussionDO* _discussion;
    GalleryItemDO * _ItemDetail;
    NSMutableArray * _vecCommentViewController;
    BOOL _keyboardIsShown;
    CommentDO* _prevReplayComment;
}
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isTableMoved;
@property (weak, nonatomic) IBOutlet UITextField *commentBodytf;
@property (nonatomic) CommentDO *newcomment;
- (IBAction)closePressed:(id)sender;

@end

@implementation DiscussionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
      
    _vecCommentViewController = [[NSMutableArray alloc] init];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCommentsFinishedNotification:)
                                                 name:CommentsForDesignReadyNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getCommentsFinishedWithFailNotification:)
                                                 name:CommentsForDesignFailedNotification
                                               object:nil];
    
    _keyboardIsShown = NO;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    self.commentBodytf.placeholder = NSLocalizedString(@"commentTip",@"");
    
    self.view.layer.shadowColor = [UIColor colorWithRed:52/255.0 green:58/255.0 blue:64/255.0 alpha:0.6].CGColor;
    self.view.layer.shadowOpacity = 0.8f;
    self.view.layer.shadowOffset = CGSizeMake(4, 4);
    
    [self setMJRefresh];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_ItemDetail isMemberOfClass:[MyDesignDO class]]) {
        self.commentBodytf.userInteractionEnabled = _ItemDetail.isPublicOrPublished ? YES : NO;
        self.commentBodytf.placeholder =  NSLocalizedString(self.commentBodytf.userInteractionEnabled ? @"commentTip" : @"PrivateNoComment",@"");
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldEditChanged:) name:UITextFieldTextDidChangeNotification object:self.commentBodytf];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)getCommentsFinishedWithFailNotification:(NSNotification *)notification{
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];

    if ([[notification object] isEqualToString:_ItemDetail._id]==false) {
        return;
    }
    
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(getCommentsFinishedWithFailNotification:) withObject:notification waitUntilDone:NO];
        return;
    }

    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                   message:NSLocalizedString(@"erh_unknown_error_msg", @"")
                                                  delegate:nil
                                         cancelButtonTitle:NSLocalizedString(@"alert_action_ok", @"") otherButtonTitles: nil];
    [alert show];
}

- (void)getCommentsFinishedNotification:(NSNotification *)notification
{
    if ([[notification object] isEqualToString:_ItemDetail._id]==false) {
        return;
    }
    
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    self.tableView.mj_footer.hidden = NO;

    if (_discussion.loadedCount == 1) {
        [[_discussion comments] removeAllObjects];
    }
    
    if ([_discussion comments].count) { //add
        NSArray *data = [NSArray arrayWithArray:[[[[AppCore sharedInstance] getCommentsManager]getLoadedCommentsForDesignID:_ItemDetail._id] comments]];
        if (data.count != 0) {
            self.tableView.mj_footer.hidden = NO;
            [_discussion.comments addObjectsFromArray:data];
        }
    }else{
        _discussion=[[[AppCore sharedInstance] getCommentsManager]getLoadedCommentsForDesignID:_ItemDetail._id];
        _discussion.loadedCount = 1; //Default
    }
   
    int height = [self addComment :[_discussion comments]:0 :NO ];
    
    CGRect rect = self.view.frame;
    rect.size.height = height;
    
    [self.tableView reloadData];
    [[ProgressPopupBaseViewController sharedInstance] stopLoading];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(0, 51, 323, 717);
    }];
    
}

-(void)init:(GalleryItemDO*)galleryItem{
    _ItemDetail = galleryItem;
}



- (int )addComment:(NSMutableArray*) listComments  :(int) in_yPos :(BOOL)isChild
{
    return 0;
    int height =  comment_frame_height_close;
    int originY = 0;
    originY+= in_yPos;
    int originX = 0;
    if(isChild)
    {
        originX = 50;
    }
    
    for (int i=0; i<[listComments count]; i++) {
        
        CommentViewController* commentViewController = (CommentViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"CommentViewControllerID" inStoryboard:kGalleryStoryboard];
                
        [_vecCommentViewController addObject: commentViewController];
        commentViewController.view.frame = CGRectMake(originX, originY, 323,height);
        commentViewController.discussionDelegate = self;
        
        [commentViewController init:[listComments objectAtIndex:i]  : _ItemDetail ];

        CommentDO * comm = [listComments objectAtIndex:i];
        
        if([comm.childComments count]>0)
        {
            originY+= height;
            originY  = [commentViewController addCommentWithCommentList:comm.childComments possition:originY isChild:YES item:_ItemDetail];
            
            CGRect rect  = commentViewController.view.frame;
            rect.size.height = originY-rect.origin.y;
            commentViewController.view.frame = rect;
        }
        else
        {
            originY += comment_frame_height_close;
        }
        if( isChild == NO  )
        {
            [commentViewController.commentBtn setHidden:NO];
        }
    }

    return  originY;
}

- (IBAction)closePressed:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = CGRectMake(-323, 51, 323, 717);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
        
        _vecCommentViewController = nil;
        
        [_addCommentDelegate dicusssionViewClosed:sender];
        
        _prevReplayComment = nil;
    }];
}

- (BOOL)addCommentPressed:(id)sender
{
    BOOL bRetVal = [_addCommentDelegate addCommentPressed:sender];
   
    if (bRetVal==YES) {
    #ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
//            [HSFlurry logEvent: FLURRY_DESIGN_COMMENT_SEND];
        }
      
    #endif
    }
    return bRetVal;
}

- (BOOL)addCommentPressedAfterLogin:(id)sender :(BOOL)createNewComment
{
    int originY = 0;
    CGRect rect ;
    for (CommentViewController *commentViewController in  _vecCommentViewController) {
        rect = commentViewController.view.frame;
        rect.origin.y = originY;
        commentViewController.view.frame = rect;
        originY = rect.origin.y + rect.size.height;
        
    }
    if([sender isDefaultComment] == YES)
    {
        if( createNewComment == YES )
        {
            [sender  setIsDefaultComment:NO];
            originY+=comment_frame_height_open;
        }
    }

    return YES;
}

- (BOOL) loginRequestEndedwithState:(BOOL) state
{
    BOOL bRetVal = NO;
   for (CommentViewController *commentViewController in  _vecCommentViewController) {
        bRetVal = [commentViewController loginRequestEndedwithState:state];
       if(bRetVal == YES)
       {
           break;
       }
    }
    return  bRetVal;
}

#pragma mark-  Discussions Delegate
-(void)createNewCommentPendingToLoadComments
{
}

-(void)createNewComment{
    if (![[UserManager sharedInstance] isLoggedIn]) {
        [[UIMenuManager sharedInstance] loginRequestedIphone:self withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self createNewComment];
            }
        }                                         loadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_COMMENT ];
    }else{
        if (self.isTableMoved) {
            [self moveTableViewForInitialFrame];
        }
        
        //    CommentDO * newcomment=nil;
        //
        //    if ((_discussion) && ([_discussion getLatestTempCommentCreated]==nil)) {
        //        newcomment=[[CommentDO alloc] init];
        //        newcomment.displayName=[[[UserManager sharedInstance] currentUser] getUserFullName];
        //        newcomment.isTempComment=YES;
        //        newcomment.imageUrl = [[[UserManager sharedInstance] currentUser]userProfileImage];
        //        newcomment.uid = [[[UserManager sharedInstance] currentUser] userID];
        //        newcomment.body=@"";
        //        [_discussion addTempComment:newcomment];
        //    }
        
        //    NSUInteger section = 0;
        //    int row=0;
        
        //    [self.tableView setEditing:YES];
        //    [[self tableView] reloadData];
        
        //    NSIndexPath * path=[NSIndexPath indexPathForRow:row inSection:section];
        //    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        //
        //    [self performSelector:@selector(openWritingComment:) withObject:path afterDelay:0.3];
    }
}

-(void)openWritingComment:(NSIndexPath*)path{
    
    CommentCell * cell=(CommentCell*)[self.tableView cellForRowAtIndexPath:path];
    
    if (cell && cell.commentBodytf) {
        if (_prevReplayComment) {
            cell.commentBodytf.placeholder = [NSString stringWithFormat:@"@%@",_prevReplayComment.displayName];
        }
        [cell.commentBodytf becomeFirstResponder];
    }
}

-(void)moveTableViewForInitialFrame{
    
    if (self.isTableMoved==NO) {
        return;
    }

    self.isTableMoved=NO;
    [self.tableView reloadData];
}

-(void)moveTableViewForWritingCommentFrame{
    
    return;
}

-(void)moveTableViewForVisibleInput:(CommentCell *)cell{
}

-(void)moveTableViewForLastIndexPath:(CommentDO*)comment{
    
    NSInteger section = [_discussion.comments indexOfObject:comment]+1;
    NSUInteger row = [[comment childComments] count]+1;
    
    if (section < 0) {
        return;
    }
    
    NSIndexPath * path = [NSIndexPath indexPathForRow:row inSection:section];
    
    if (path) {
        dispatch_async(dispatch_get_main_queue(), ^
                       {
                           [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                       });
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
        
        self.newcomment.parentID = comment._id;
        self.newcomment.parentUID = comment.uid;
        self.newcomment.parentDisplayName = comment.displayName;
        self.newcomment.dicReply = [NSDictionary dictionary];
        
        //    NSIndexPath * path=[NSIndexPath indexPathForRow:0 inSection:0];
        //    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //    [self.commentBodytf becomeFirstResponder];
        self.commentBodytf.placeholder = comment.displayName ? [NSString stringWithFormat:@"@%@",comment.displayName] : @"@" ;
        //    if (self.isTableMoved) {
        //        [self moveTableViewForInitialFrame];
        //    }
        //
        //    NSUInteger section = 0;
        //    NSUInteger row = 0;
        //
        //    if ([comment indexOfTempComment]>-1) {
        //        //we have a comment already
        //        section=[_discussion.comments indexOfObject:comment]+1;
        //        row=[[comment childComments] count];
        //    }else{
        //        CommentDO * newcomment=  [[CommentDO alloc] init];
        //        newcomment.parentID=comment._id;
        //        newcomment.displayName=[[[UserManager sharedInstance] currentUser] getUserFullName];
        //        newcomment.isTempComment=YES;
        //        newcomment.imageUrl = [[[UserManager sharedInstance] currentUser]userProfileImage];
        //        newcomment.body=@"";
        //        [comment.childComments addObject:newcomment];
        //        section=[_discussion.comments indexOfObject:comment]+1;
        //        row=[[comment childComments] count];
        //    }
        //
        //    [self.tableView setEditing:YES];
        //        NSIndexPath * path=[NSIndexPath indexPathForRow:row inSection:section];
        //
        //        [[self tableView] reloadData];
        //
        //        if (path) {
        //            CommentCell * cell=(CommentCell*)[self.tableView cellForRowAtIndexPath:path];
        //
        //            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        //
        //            if (cell) {
        //                [cell.commentBody becomeFirstResponder];
        //            }
        //        }
    }
}

-(void)publishComment:(CommentDO*)comment{
    //checked basic validations, now Add comment by sending it to server

    if (![[UserManager sharedInstance] isLoggedIn]) {
        [[UIMenuManager sharedInstance] loginRequestedIphone:self withCompletionBlock:^(BOOL success) {
            if (success == YES) {
                [self createTempCommentForComment:comment];
            }
        }                                         loadOrigin:EVENT_PARAM_VAL_LOAD_ORIGIN_COMMENT ];
    }else{
        if (!comment.displayName) {
            comment.displayName = [[[UserManager sharedInstance] currentUser] getUserFullName];
            comment.imageUrl = [[[UserManager sharedInstance] currentUser]userProfileImage];
        }
        
        if (self.isTableMoved) {
            [self moveTableViewForInitialFrame];
        }
        
        [[ProgressPopupBaseViewController sharedInstance] startLoading :self.parentViewController];
        
        
        CommentDO * parent=[_discussion getCommentByID:comment.parentID];
        NSString * itemID=_ItemDetail._id;
        self.newcomment = nil;
        __weak UITableView * tblViewWeak = self.tableView;
        
        //clean prev comment
        if (_prevReplayComment) {
            _prevReplayComment = nil;
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void)
                       {
                           
                           [_discussion addGeneratedComment:comment forOriginalComment:parent withItemID:itemID withCompletion:^( BOOL status) {
                               
                               
                               dispatch_async(dispatch_get_main_queue(),^(void){
                                   
                                   if (tblViewWeak.frame.origin.y<0) {
                                       tblViewWeak.frame=CGRectMake(0,
                                                                    35,
                                                                    tblViewWeak.frame.size.width,
                                                                    tblViewWeak.frame.size.height);
                                       
                                   }
                                   
                                   if (status==true) {
                                       [tblViewWeak setEditing:NO];
                                       [_discussion addTempComment:comment];
                                       [_addCommentDelegate addCommentPressed:self];
                                     
                                       [tblViewWeak setEditing:NO];
                                       NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:0];
                                       [weakSelf.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
                                   }else{
                                       UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                                                      message:NSLocalizedString(@"erh_unknown_error_msg", @"")
                                                                                     delegate:nil
                                                                            cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"")
                                                                            otherButtonTitles: nil];
                                       [alert show];
                                       
                                   }
                                   [[ProgressPopupBaseViewController sharedInstance] stopLoading];
                                   [tblViewWeak reloadData];
                               });
                           }];
                           
                       });
    }
    
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_discussion comments].count == 0) {

        return 400;
    }
    
    CommentDO * comment=[[_discussion comments]objectAtIndex:indexPath.row];
    
    if (comment.isTempComment==YES && [self.tableView isEditing]) {
        //new cell
        return 202.0f;
    }
    
    UILabel * lbl=nil;
    lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 21)];
    lbl.text=comment.body;
    [lbl setFont:[UIFont systemFontOfSize:15]];
    CGSize  size=[lbl getActualTextHeightForLabel:1000];
    CGFloat labelHeight = 21;
    CGFloat heightOffset = 5; //For some reason, the height returned from getActualTextHeightForLabel is not accurate. So we need to add a few pixels to the cell's height so the whole text could fit in.
    
    int height=90;
    if (size.height>labelHeight) {
        height = 48;
        return height + size.height + heightOffset;
    }
    
    return height; //returns floating point which will be used for a cell row height at specified row index
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewCellEditingStyleNone;
}

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    // Return the number of sections.
//
//    if (_discussion==nil || [_discussion comments].count == 0) {
//        return 1;
//    }
//    return [[_discussion comments]count]; //"+1" for the "write comment" section
//}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.

//    if (section == 0) //"write comment" section
//    {
//        return 1;
//    }

    if (_discussion==nil || [_discussion comments].count == 0) {
        return 1;
    }
    
//    CommentDO * com=[[_discussion comments]objectAtIndex:section];
//
//    NSUInteger result= [[com childComments] count];
	return [_discussion comments].count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell"; //ParentCommentCell
    static NSString *CellIdentifier2 = @"Cell2"; //ChildCommentCell
    static NSString *CellIdentifierNew = @"CellNew"; //AddCommentCell
//    static NSString *CellIdentifierInfo= @"CellBase"; //ReplyHeaderCommentCell
    static NSString *CellIdentifierNO= @"NoCell"; //NoCommentCell
    
    CommentCell * cell = nil;
    
    if (_discussion==nil || [_discussion comments].count == 0) {
        NoCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifierNO];
        if (!cell) {
            cell = [[NSBundle mainBundle] loadNibNamed:@"NoCommentCell" owner:self options:nil][0];
        }
        return cell;
    }else{
        NSMutableDictionary * dict=[NSMutableDictionary dictionaryWithCapacity:0];
        NSString * imagePath=@"";
        
        CommentDO * comment=[[_discussion comments]objectAtIndex:indexPath.row];
        
        //new temp cell
        if (comment.isTempComment==YES && [self.tableView isEditing] ) {
            cell=(CommentCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifierNew];
            if (!cell)
            {
                cell = [[NSBundle mainBundle] loadNibNamed:@"AddCommentCell" owner:self options:nil][0];
            }
            
            cell.userAvatar.image=[UIImage imageNamed:@"iph_profile_settings_image.png"];
            [cell.userAvatar setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
            cell.delegate = self;
            [cell initWithComment:comment];
            
            //it current user's comment add his avatar if logged in
            NSIndexPath * indxpath=[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
            [dict setObject:indxpath forKey:@"indexpath"];
            
            imagePath=[[[UserManager sharedInstance] currentUser] userProfileImage];
            [self loadCommentImage:imagePath forCell:cell withDictionary:dict];
            
            return cell;
        }
        
        if (comment.dicReply) {
            cell=(CommentCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            if (!cell)
            {
                cell = [[NSBundle mainBundle] loadNibNamed:@"ChildCommentCell" owner:self options:nil][0];
            }
        }else{
            cell=(CommentCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (!cell)
            {
                cell = [[NSBundle mainBundle] loadNibNamed:@"ParentCommentCell" owner:self options:nil][0];
            }
        }
        imagePath=[comment  imageUrl];
        
        [self loadCommentImage:imagePath forCell:cell withDictionary:dict];
        
        [cell initWithComment:comment];
        
        if ((_discussion!=nil || [_discussion comments].count != 0) && indexPath.row == 0) {
            cell.seperateView.hidden = YES;
        }
        
        cell.delegate = self;
        
        return  cell;
        
    }
}

-(void)loadCommentImage:(NSString*)image forCell:(CommentCell*)cell withDictionary:(NSMutableDictionary*)dict{
    
    [cell.userAvatar setImage:[UIImage imageNamed:@"iph_profile_settings_image.png"]];
    [cell.userAvatar setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
    
    CGSize designSize = cell.userAvatar.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  (image)?image:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : cell.userAvatar};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary *imageinfo)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:cell.userAvatar];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if(image)
                                          {
                                              cell.userAvatar.image = image;
                                              [cell.userAvatar setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
                                          }
                                          
                                      });
                   }
               }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_discussion && [_discussion comments].count != 0 && _ItemDetail.isPublicOrPublished) {
        CommentCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        [self createTempCommentForComment:cell.mycomment];
        [self.commentBodytf becomeFirstResponder];
        [self performSelector:@selector(scrollToPath:) withObject:indexPath afterDelay:0.5];
    }
}

-(void)scrollToPath:(NSIndexPath*)path{
    NSInteger section = [path section];
    if (section <= [[_discussion comments]count]) {
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * vw=[[UIView alloc] init];
    if (section==0) {
        return nil;
    }

    vw.backgroundColor=[UIColor clearColor];
    return vw;
    
}// custom view for header. will be adjusted to default or specified header height

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView * vw=[[UIView alloc] init];
    if (section==0) {
        return nil;
    }

    vw.backgroundColor=[UIColor clearColor];
    return vw;
}// custom view for footer. will be adjusted to default or specified footer height

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0.0f;
    }
    
    return 5.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return 0.0f;
    }
    
    return 5.0f;
}

#pragma mark - Keyboard Notifications
- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    if (_keyboardIsShown) {
        return;
    }
    
    NSDictionary* userInfo = [notification userInfo];
    
    CGSize kbSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    if (SYSTEM_VERSION_LESS_THAN(@"8")) {
        [self.tableView  setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, kbSize.width, 0.0f)];
    }else{
        [self.tableView  setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, kbSize.height, 0.0f)];
    }
    
    NSInteger count = [[_discussion comments] count] ;
    if (count) {
        [self.tableView scrollRectToVisible:CGRectMake(0, self.tableView.contentSize.height - self.tableView.bounds.size.height, self.tableView.bounds.size.width, self.tableView.bounds.size.height) animated:YES];
    }
    
    _keyboardIsShown = YES;
}

- (void)keyboardWillHideNotification:(NSNotification *)notification{
    
    if (!_keyboardIsShown) {
        return;
    }
    
    [self.tableView  setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];

    _keyboardIsShown = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.returnKeyType == UIReturnKeyDone && textField.text.length != 0) {
        self.newcomment.body=textField.text;
        [self publishComment:self.newcomment];
        [textField resignFirstResponder];
        textField.text = nil;
        textField.placeholder = NSLocalizedString(@"commentTip",@"");
    }
    [textField reloadInputViews];
    return YES;
}


#pragma mark - Notification Method
-(void)textFieldEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
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
        }else{
            textField.returnKeyType = UIReturnKeyDefault;
        }
    }
    [textField reloadInputViews];
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
        _discussion.loadedCount = 1;//Reset
        [self readCommentsActionForIPad];
    }];
    header.automaticallyChangeAlpha = YES;
    [header setTitle:@"" forState:MJRefreshStateIdle];
    [header setTitle:@"" forState:MJRefreshStatePulling];
    [header setTitle:@"" forState:MJRefreshStateRefreshing];
    header.lastUpdatedTimeLabel.hidden = YES;
    header.labelLeftInset = 0;
    self.tableView.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        _discussion.loadedCount = _discussion.loadedCount + 1;
        [self readCommentsActionForIPad];
    }];
    footer.automaticallyChangeAlpha = YES;
    [footer setTitle:@"" forState:MJRefreshStateIdle];
    [footer setTitle:@"" forState:MJRefreshStateRefreshing];
    [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
    footer.labelLeftInset = 0;
    footer.hidden = YES;
    self.tableView.mj_footer = footer;
    
}

// Get Comments
-(void)readCommentsActionForIPad {
    [[[AppCore sharedInstance]getCommentsManager]getCommentsForDesignID:_ItemDetail._id offset:_discussion.loadedCount];
}

@end

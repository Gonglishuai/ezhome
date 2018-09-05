//
//  CommentViewController.h
//  CmyCasa
//
//  Created by Gil Hadas on 12/31/12.
//
//

#import "NotificationAdditions.h"
#import "CommentViewController.h"
#import "UIImage+Scale.h"
#import "ControllersFactory.h"
#import "NotificationNames.h"
#import "ImageFetcher.h"
#import "NSString+Contains.h"
#import "UIImageView+ViewMasking.h"

#define comment_frame_height 116
#define comment_frame_height_open_diff 188

@interface CommentViewController ()
{
@private
    GalleryServerUtils* galleryServerUtils;
    CommentDO* _comment;
    DesignBaseClass * _item;
    NSMutableArray* vecCommentViewController;
    BOOL _commentPressed;
}
@end

@implementation CommentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [_commentTxtView setHidden:YES];
    [_commentTextEditBg setHidden:YES];
    [_currentUserImage setHidden:YES];
    [self.commentBtn setHidden:YES];
    self.isCommentTextOpen = NO;
    _commentPressed = NO;
    vecCommentViewController = [[NSMutableArray alloc] init];
    self.isDefaultComment = NO;
    galleryServerUtils = [GalleryServerUtils sharedInstance];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    NSLog(@"dealloc - CommentViewController");
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) init:(CommentDO*)comment :(GalleryItemDO*) in_item
{
    _comment = comment;
    _item = in_item;
  
    [self loadUserImage];
    _userName.text = comment.displayName;;
    _commentBody.text =comment.body;
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate * dt=comment.timestamp;
    
    [formatter setDateFormat:@"MMM dd"];
    _dateLbl.text =[formatter stringFromDate:dt];

}

-(void)loadUserImage{
    
    NSString * thumburl=_comment.imageUrl;
    self.userAvatar.image=[UIImage imageNamed:@"iph_profile_settings_image.png"];
    
    [self.userAvatar setMaskToCircleWithBorderWidth:0.0 andColor:[UIColor clearColor]];
    if(![NSString isNullOrEmpty:thumburl])
    {
        CGSize designSize = self.userAvatar.frame.size;
        NSValue *valSize = [NSValue valueWithCGSize:designSize];
        NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL:  thumburl,
                              IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                              IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                              IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.userAvatar};

        NSInteger lastUid = -1;
        lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
                   {
                       NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.userAvatar];

                       if (currentUid == uid)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              if(image)
                                                self.userAvatar.image = image;
                                          });
                       }
                   }];

    }

}

-(void)loadReplyUserImage:(NSString*)thumburl{
    
    
   if([thumburl length] == 0)
    {
         
        _currentUserImage.image=[UIImage imageNamed:@"iph_profile_settings_image.png"];
        [_currentUserImage setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
    }else{
     
         
        
        NSString* imagePath;
        NSRange range = [thumburl rangeOfString:@"graph.facebook.com"];
        bool bIsFBUser = false;
        if (range.location != NSNotFound)
        {
            NSString*  strID = [thumburl stringByDeletingLastPathComponent];
            imagePath = [[ConfigManager sharedInstance]getStreamFilePathWithoutExtension:[NSString stringWithFormat:@"commentrep_%@.jpg"
                                                                                          ,[strID lastPathComponent]]];
            bIsFBUser = true;
        }
        else
        {
            imagePath = [[ConfigManager sharedInstance]getStreamFilePathWithoutExtension:[NSString stringWithFormat:@"commentrep_%@"
                                                                                          ,[thumburl lastPathComponent]]];
        }
       
        NSMutableDictionary * dd=[NSMutableDictionary dictionaryWithCapacity:0];
        
        [dd setObject:[NSString stringWithFormat:@"commentrep_%@"
                       ,_comment._id] forKey:@"comment"];
        
        [dd setObject:imagePath forKey:@"path"];

        
        [[GalleryServerUtils sharedInstance] loadImageFromUrl:_currentUserImage url:imagePath];
        [_currentUserImage setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];
    }
}

-(void) setCtrlOffset:(BOOL) onOpen
{
    if(onOpen == YES)
    {
        
        CGRect rect = self.view.frame;
        rect.origin.y+=comment_frame_height_open_diff;
        self.view.frame = rect;
        
        
        for (CommentViewController *commentViewController in  vecCommentViewController) {
            [commentViewController setCtrlOffset:onOpen];
            
        }
    }
    else
    {
        CGRect rect = self.view.frame;
        rect.origin.y-=comment_frame_height_open_diff;
        self.view.frame = rect;
        
        for (CommentViewController *commentViewController in  vecCommentViewController) {
            [commentViewController setCtrlOffset:onOpen];
            
        }
    }
}

-(void) setCtrlPosition:(BOOL) onOpen
{
    if(onOpen == YES)
    {
        CGRect rect = self.view.frame;
        rect.size.height+=comment_frame_height_open_diff;
        self.view.frame = rect;
        rect = self.commentBtn.frame;
        rect.origin.y +=comment_frame_height_open_diff;
        self.commentBtn.frame = rect;
        rect = _seperateBarImage.frame;
        rect.origin.y +=comment_frame_height_open_diff;
        _seperateBarImage.frame = rect;
         
        for (CommentViewController *commentViewController in  vecCommentViewController) {
            [commentViewController setCtrlOffset:onOpen];
            
        }
    }
    else
    {
        CGRect rect = self.view.frame;
        rect.size.height-=comment_frame_height_open_diff;
        self.view.frame = rect;
        rect = self.commentBtn.frame;
        rect.origin.y -=comment_frame_height_open_diff;
        self.commentBtn.frame = rect;
        rect = _seperateBarImage.frame;
        rect.origin.y -=comment_frame_height_open_diff;
        _seperateBarImage.frame = rect;
        for (CommentViewController *commentViewController in  vecCommentViewController) {
            [commentViewController setCtrlOffset:onOpen];
            
        }
    }
}

- (void) setOpenInputText
{
    [_commentTxtView setHidden:NO];
    [_commentTextEditBg setHidden:NO];
    self.isCommentTextOpen = YES;
    NSString*  userThumbnailURL;
    NSString* strUserName;
    
    NSString* strImage = [[[UserManager sharedInstance] currentUser] userProfileImage];
    if([strImage length] != 0)
    {
        userThumbnailURL = strImage ;
    }
    NSString* strName = [[[UserManager sharedInstance] currentUser] getUserFullName];
    if([strName length] != 0)
    {
        strUserName = strName ;
    }
    if(self.isDefaultComment)
    {
        [self loadUserImage];
        CGRect rect =  _commentTxtView.frame;
        rect.origin.y-= 100;
        rect.origin.x-= 25;
        rect.size.width += 25;
        _commentTxtView.frame =rect;
         rect =  _commentTextEditBg.frame;
        rect.origin.y-= 100;
        rect.origin.x-= 25;
        rect.size.width += 25;
        _commentTextEditBg.frame =rect;
        
        rect =  self.commentBtn.frame;
        rect.origin.y-= 100;
        self.commentBtn.frame =rect;
    }else{
        [_currentUserImage setHidden:NO];
        [self loadReplyUserImage:strImage];
        [_currentUserImage setMaskToCircleWithBorderWidth:0.0f andColor:[UIColor clearColor]];

    }
    [self setCtrlPosition:YES];
    
}

- (IBAction)commentPressed:(id)sender {
    [self.commentTxtView resignFirstResponder];
    _commentPressed = YES;
    [_discussionDelegate addCommentPressed:  self  ];
    
    [_discussionDelegate positionCommentInTopScroll:self.view.frame];

}

- (BOOL)commentPressedInternal {
    BOOL bRetVal = NO;
    BOOL bCreateNewComment = NO;
    
    if(self.isCommentTextOpen == NO)
    {
        [self setOpenInputText];
    }
    else
    {
        if( [_commentTxtView hasText] == NO && self.isDefaultComment)
        {
            return NO;
        }
        [_commentTxtView setHidden:YES];
        [_commentTextEditBg setHidden:YES];
        [_currentUserImage setHidden:YES];
        self.isCommentTextOpen = NO;
        [self setCtrlPosition:NO];
        
        CGRect  rect = self.view.frame;
        NSString* itemID  =_item._id;
        NSString* body  = _commentTxtView.text;
        
        NSString* parentID =(_comment._id!=nil)?_comment._id:@"";// [NSString stringWithUTF8String:_comment.getCommentID().c_str()];
        if( [_commentTxtView hasText])
        {
            NSString* userThumbnailURL = [[[UserManager sharedInstance] currentUser]userProfileImage];
            
            NSString* strUserName = [[[UserManager sharedInstance] currentUser] getUserFullName];
            
            
            
            bRetVal = YES;
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"MMM dd"];
            
            NSDate * dt=[NSDate date];
            NSString* dateString = [formatter stringFromDate:dt];
            if(self.isDefaultComment)
            {
                _comment.isAddCommentSend=YES;
                
                _commentBody.text  = _commentTxtView.text;
                 
                _dateLbl.text = dateString;
                    CGRect rect =  _commentTxtView.frame;
                    rect.origin.y+= 100;
                    rect.origin.x+= 25;
                    rect.size.width -= 25;
                   _commentTxtView.frame =rect;
                    rect =  _commentTextEditBg.frame;
                    rect.origin.y+= 100;
                    rect.origin.x+= 25;
                    rect.size.width -= 25;
                    _commentTextEditBg.frame =rect;
                    
                    rect =  self.commentBtn.frame;
                    rect.origin.y+= 100;
                    self.commentBtn.frame =rect;
                
                
                DesignDiscussionDO *designDisc= [[[AppCore sharedInstance] getCommentsManager]getLoadedCommentsForDesignID:_item._id];
                
                if (designDisc) {
                    
                    _comment._id=@"";
                    _comment.body=_commentTxtView.text;
                    _comment.displayName=strUserName;
                    _comment.imageUrl=userThumbnailURL;
                    _comment.parentID=@"";
                    _comment.timestamp=dt;
                    parentID=@"";
                    
                    [designDisc.comments addObject:_comment];
                   
                }
            }
            else
            {
                
                NSString* strCommentID;
                 NSString* strTxt =  _commentTxtView.text;
             
                 
              
                if(userThumbnailURL ==nil)
                {
                    //userThumbnailURL =     "http://res.cloudinary.com/homestyler/image/fetch/w_50,h_50,c_fill/https%3A%2F%2Fencrypted-tbn2.gstatic.com%2Fimages%3Fq%3Dtbn%3AANd9GcSussgIOr2Frx-Q6GnoUDo_gK191FdhtJCU3jqIEb8R6RgGFn_6LTrJumP2";
                }
                
               
              DesignDiscussionDO *designDisc= [[[AppCore sharedInstance] getCommentsManager]getLoadedCommentsForDesignID:_item._id];
                    
                    if (designDisc) {
                        [designDisc addComment:strTxt withID:strCommentID userName:strUserName userThumb:userThumbnailURL time:dt parentID:_comment._id];
                    }
                    
                for (CommentViewController *commentViewController in  vecCommentViewController) {
                    [commentViewController.view removeFromSuperview];
                    
                }
                
                GalleryItemDO * gido = (GalleryItemDO*)_item;
                int retHeight = [self addCommentWithCommentList:[_comment childComments] possition:comment_frame_height isChild:YES item:gido];
                rect.size.height = retHeight;
                self.view.frame =rect;
            }
            

                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(addCommentFinishedNotification:)
                                                             name:kNotificationAddCommentFinished
                                                           object:nil];
                
                
            
           
            bCreateNewComment = YES;
       }
            
             [galleryServerUtils addComment: itemID  :body : parentID];
        _commentTxtView.text = @"";
    }
    
    [_discussionDelegate addCommentPressedAfterLogin:self :bCreateNewComment];
 
    return bRetVal;
}
static int childoffsetX = 35;

- (int)addCommentWithCommentList:(NSMutableArray*)listComments  possition:(int)in_yPos isChild:(BOOL)isChild item:(GalleryItemDO*) in_item
{
    int originY = in_yPos;
    if([listComments count]==0 )
    {
        return originY;
    }
    int height =  comment_frame_height;
    int childOriginY =  height;
   int originX = 0;
    if(isChild)
    {
        originX = childoffsetX;
    }
    for (int i=0; i<[listComments count]; i++) {
    
        CommentViewController* commentViewController = (CommentViewController*)[ControllersFactory instantiateViewControllerWithIdentifier:@"CommentViewControllerID" inStoryboard:kGalleryStoryboard];
        
        [vecCommentViewController addObject: commentViewController];
        if(isChild)
        {
            commentViewController.view.frame = CGRectMake(originX, childOriginY, 323,height);
            childOriginY+=height;
            
        }
        else
        {
            commentViewController.view.frame = CGRectMake(originX, originY, 323,height);
        }
        CGRect rect = commentViewController.seperateBarImage.frame;
        rect.origin.x-=childoffsetX;
        commentViewController.seperateBarImage.frame = rect;
        rect = commentViewController.commentTxtView.frame;
        rect.origin.x-=childoffsetX;
        commentViewController.commentTxtView.frame= rect;
        
        rect = commentViewController.commentBody.frame;
        rect.size.width -= childoffsetX;
        commentViewController.commentBody.frame= rect;

        [self.view addSubview:commentViewController.view];
        commentViewController.discussionDelegate = _discussionDelegate;
        
        [commentViewController init:[listComments objectAtIndex:i] :in_item];
        originY+=comment_frame_height;
        
        if(isChild == NO )
        {
            [commentViewController.commentBtn setHidden:NO];
        }
    }

    return  originY;
}

- (void)addCommentFinishedNotification:(NSNotification *)notification
{
	Boolean isSuccess;
    [[[notification userInfo] objectForKey:@"isSuccess"] getValue:&isSuccess];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationAddCommentFinished object:nil];

    if (isSuccess == NO)
    {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"erh_unknown_error_msg", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"") otherButtonTitles: nil];
        [alert show];
        
    }
    else
    {
		
        CommentDO *comm = [[notification userInfo] objectForKey:@"comment"];
        
        if (_comment.isAddCommentSend)
        {
            [_comment updateCommentWithComment:comm];
            _comment.isAddCommentSend=NO;
             if(isSuccess)
            {

                [self loadUserImage];
                _userName.text = _comment.displayName;
                 
                NSDate * dt=_comment.timestamp;       
                NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                [formatter setDateFormat:@"MMM dd"];
                _dateLbl.text =[formatter stringFromDate:dt];

                
            }
        }else{
            
           for (int i=0; i<[[_comment childComments] count]; i++) {
               if ([[[_comment childComments] objectAtIndex:i] isAddCommentSend]) {
                   [[[_comment childComments]objectAtIndex:i]updateCommentWithComment:comm];
                   [[[_comment childComments]objectAtIndex:i] setIsAddCommentSend:NO];
               }
            }
            
        }
    }
}

- (BOOL) loginRequestEndedwithState:(BOOL) state
{
    BOOL bRetVal = NO;
    if(_commentPressed == YES)
    {
        _commentPressed = NO;
        if (state == YES)
        {
           bRetVal =  [ self commentPressedInternal ];
        }
    }
    else
    {
        for (CommentViewController *commentViewController in  vecCommentViewController) {
        [commentViewController loginRequestEndedwithState:state];
        
        }
    }
    return bRetVal;
}

#pragma mark textview delegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    if (self.discussionDelegate) {
        [self.discussionDelegate textFieldBeginEdit:self.view.frame];
    }
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    if (self.discussionDelegate) {
        [self.discussionDelegate textFieldEndEdit:self.view.frame];
    }
     return YES;
}

- (IBAction)commentProfileClicked:(id)sender {
    NSString * uid=_comment.uid;
    if (uid!=nil) {
          [[UIMenuManager sharedInstance] openProfilePageForsomeUser:uid];  
    }
}
@end

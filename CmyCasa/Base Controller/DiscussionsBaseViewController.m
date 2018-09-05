//
//  DiscussionsBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/23/13.
//
//

#import "DiscussionsBaseViewController.h"
#import "CommentCell.h"
#import "UILabel+Size.h"
#import "DesignDiscussionDO.h"

@interface DiscussionsBaseViewController ()

@property(nonatomic)BOOL noCommentsForDiscussion;
@end

@implementation DiscussionsBaseViewController
@synthesize tableView;

-(BOOL)prefersStatusBarHidden{
    return YES;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(RefreshCommentsAfterCreationNotification:)
                                                 name:@"RefreshCommentsAfterCreationNotification"
                                               object:nil];
}

-(void)RefreshCommentsAfterCreationNotification:(NSNotification*)notification{
    
    [self stopLoading];
    [self.tableView reloadData];
}

#pragma mark - Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentDO * comment=[[self.myDiscussion comments]objectAtIndex:indexPath.section];
    
    if (comment.tempComment!=nil && [self.tableView isEditing] && indexPath.row>[[comment childComments] count]) {
        //new cell
        return 200.0f;
    }
    
    UILabel * lbl=nil;
    
    if (indexPath.row>0) {
         lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 171, 21)];
        lbl.text=[[[comment childComments]objectAtIndex:indexPath.row-1] body];
    }else{
        lbl=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 188, 21)];
        lbl.text=comment.body;
    }
    
    CGSize  size=[lbl getActualTextHeightForLabel:500];
    
    int height=123;
    if (size.height>44) {
            height= 123+size.height-44;
      
    }
    
	return height; //returns floating point which will be used for a cell row height at specified row index
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleNone;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.myDiscussion comments]count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    
    CommentDO * com=[[self.myDiscussion comments]objectAtIndex:section];
    
    NSUInteger result= [[com childComments] count]+1;
   
    if (com.tempComment!=nil && [self.tableView isEditing]) {
        return result+1;
    }
    
	return result;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    static NSString *CellIdentifier = @"Cell";
    static NSString *CellIdentifier2 = @"Cell2";
    static NSString *CellIdentifierNew = @"CellNew";
    
    CommentCell * cell = nil;
    CommentDO * comment = nil;
    
    NSArray * comments = [self.myDiscussion comments];
    if (comments && indexPath.section < [comments count]) {
        comment = [comments objectAtIndex:indexPath.section];
    }
    
    cell = (CommentCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (comment.tempComment!=nil && [self.tableView isEditing] && indexPath.row>[[comment childComments] count]) {
        cell=(CommentCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifierNew];
     
        return cell;
    }
    
    if ( [[comment childComments]count]>0) {
       
        if (indexPath.row==0) {
            [cell initWithComment:comment];
        }else{
            cell=(CommentCell*)[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            [cell initWithComment:[[comment childComments]objectAtIndex:indexPath.row-1]];
        }
    }else{
         [cell initWithComment:comment];
    }
    cell.delegate=self;
    
  
    return  cell;
}

-(void)startLoading{
    
}

-(void)stopLoading{
    
}

#pragma mark - Discussions Delegate
-(void)createNewComment{
    
}

-(void)createTempCommentForComment:(CommentDO*)comment{
    
//    CommentDO * newcomment=[[CommentDO alloc] init];
//    newcomment.parentID=comment._id;
//    newcomment.displayName=[[[UserManager sharedInstance] currentUser] getUserFullName];
//    newcomment.imageUrl = [[[UserManager sharedInstance] currentUser]userProfileImage];
//    newcomment.isTempComment=YES;
//    newcomment.body=@"test test test tezt stest asr ";
//    comment.tempComment=newcomment;
//    NSInteger section = [self.myDiscussion.comments indexOfObject:comment];
//    NSInteger row = [[comment childComments] count];
//    if (row==0) {
//        row=1;
//    }else
//        row+=1;
//    
//    [self.tableView setEditing:YES];
//        @try {
//    NSIndexPath * path=[NSIndexPath indexPathForRow:row inSection:section];
//    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
//    //get newly created cell
//
//        CommentCell * cell=(CommentCell*)[self.tableView cellForRowAtIndexPath:path];
//        if (cell) {
//            cell.delegate=self;
//            [cell initWithComment:newcomment];
//        }
//    }
//    @catch (NSException *exception) {
//        
//    }
}

-(void)publishComment:(CommentDO*)comment{
    //checked basic validations, now Add comment by sending it to server
    [self.tableView setEditing:NO];
    
    [self startLoading];
}

-(void)moveTableViewForVisibleInput:(CommentCell*)cell{
    if (cell) {
        
    NSIndexPath *path=    [self.tableView indexPathForCell:cell];
        if (path) {
            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
    }
}

-(void)moveTableViewForLastIndexPath:(CommentDO*)comment{
    
    
    NSInteger section = [self.myDiscussion.comments indexOfObject:comment];
    NSInteger row = [[comment childComments] count];
    if (row==0) {
        row=1;
    }else
        row+=1;

    
        NSIndexPath * path=[NSIndexPath indexPathForRow:row inSection:section];
        
        if (path) {
            [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
        }
}

-(void)moveTableViewForInitialFrame{
    //not implement
}

-(void)moveTableViewForWritingCommentFrame{
    //not implement
}

@end







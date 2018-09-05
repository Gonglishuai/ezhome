
//
// Created by Berenson Sergei on 12/22/13.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "UserProfileBaseTableViewController.h"
#import "ProfessionalCell.h"
#import "BaseActivityTableCell.h"
#import "ProfileUserDetailsViewController_iPad.h"

@interface UserProfileBaseTableViewController ()
@property (weak, nonatomic) IBOutlet UIView *noDesignsView;
@property (weak, nonatomic) IBOutlet UILabel *noDesignsLabel;

@end

@implementation UserProfileBaseTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableContent.clipsToBounds=YES;
    
    [self.view setBackgroundColor:[UIColor clearColor]];
    if (IS_IPAD) {
        [self placeFooterAndHeader];
        
        self.tableContent.backgroundColor = [UIColor clearColor];
    }
    self.noDesignsLabel.text = NSLocalizedString(@"No designs yet", @"");
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

-(void)dealloc{
    NSLog(@"dealloc - UserProfileBaseTableViewController");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];

    [super viewWillDisappear:animated];
}

#pragma mark -

-(UITableView*)getTableView{
    return self.tableContent;
}

-(void)placeFooterAndHeader{
    [self setFooterOnly];
    [self setHeaderOnly];
}

- (void)setFooterOnly {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 4)];
    [footerView setBackgroundColor:[UIColor whiteColor]];
    self.tableContent.tableFooterView = footerView;
}

- (void)setHeaderOnly {
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 4)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    self.tableContent.tableHeaderView = headerView;
}

-(void)removeFooter{
    self.tableContent.tableFooterView=nil;
}

-(void)removeHeader{
    self.tableContent.tableHeaderView=nil;
}

- (void)viewDidUnload {
    [self setTableContent:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateDisplay:(BOOL)isLoggedInUserProfile{
    [super updateDisplay:isLoggedInUserProfile];
    
    if (self.presentingData){
        [self.tableContent reloadData];
    }
}

-(void)insertHeaderView:(UIView*)headerView{
    self.internalHeaderContainer = headerView;
}

- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Subclass overrides
- (void)startLoadingIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.tableLoadingIndicator startAnimating];
                   });
}

- (void)stopLoadingIndicator
{
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.tableLoadingIndicator stopAnimating];
                   });
}

-(void) refreshContent{
    if (![[NSThread currentThread] isMainThread]) {
        [self performSelectorOnMainThread:@selector(refreshContent) withObject:Nil waitUntilDone:NO];
        return;
    }
    
    [self.tableContent reloadData];
}

-(void)initDisplay:(NSArray*)data {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (IS_IPAD) {
            ProfileUserDetailsViewController_iPad *currentSize = (ProfileUserDetailsViewController_iPad*)self.dataDelegate;
            self.view.frame = CGRectMake(0, 0, currentSize.containerView.bounds.size.width, currentSize.containerView.bounds.size.height);
        }else{
            self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        }
        self.presentingData=data;
        self.noDesignsView.hidden = self.presentingData.count != 0;
        self.tableContent.scrollEnabled = self.noDesignsView.hidden;
        [self.tableContent reloadData];
    });
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = self.presentingData.count;

    if (self.internalHeaderContainer) {
        count++;
    }

    return count;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    static NSString* identifierContent = @"";
    
    if (self.internalHeaderContainer && indexPath.row == 0) {
        //handle header row
        identifierContent = @"HeaderCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifierContent];
        
        [self.internalHeaderContainer removeFromSuperview];
        [cell.contentView addSubview:self.internalHeaderContainer];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    if ([self.dataDelegate respondsToSelector:@selector(getCellIdentifierForIndexpath:)])
    {
        NSIndexPath * path=[indexPath copy];
 
        if (self.internalHeaderContainer) {
            path = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        }
        
        identifierContent = [self.dataDelegate getCellIdentifierForIndexpath:path];
        cell = [tableView dequeueReusableCellWithIdentifier:identifierContent];
        
        if (!cell) {
            if ([self.dataDelegate respondsToSelector:@selector(getTableViewCellForIndexpath:)]) {
                
                cell = [self.dataDelegate getTableViewCellForIndexpath:path];
            }
        }
        
        if([cell respondsToSelector:@selector(initWithData:andDelegate:andProfileUserType:)])
        {
            id<ProfileCellUnifiedInitProtocol> protocolCell = (id<ProfileCellUnifiedInitProtocol>)cell;
            ProfileUserType puserType = [self.dataDelegate getViewedProfileUserType];
            
            [protocolCell initWithData:self.presentingData[path.row]  andDelegate:self.dataDelegate  andProfileUserType:puserType];
        }
        else if ([(BaseActivityTableCell*)cell respondsToSelector:@selector(setWithData:)])
        {
            if ([self.presentingData count] > 0 && path.row < [self.presentingData count]) {
                [cell performSelector:@selector(setWithData:) withObject:[self.presentingData objectAtIndex:path.row]];
            }
        }
        
        if([self.dataDelegate respondsToSelector:@selector(reachedRowAtIndex:fromTotalCount:)])
        {
            [self.dataDelegate reachedRowAtIndex:path.row fromTotalCount:self.presentingData.count];
        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSIndexPath *path=[indexPath copy];
    if (indexPath.row==0 && indexPath.section==0 && self.internalHeaderContainer!=Nil) {
        
        return self.internalHeaderContainer.frame.size.height;
    }
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(heightForRowAtIndexpath:)]) {
        if (self.internalHeaderContainer) {
            path=[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        }
        float height=(CGFloat)[self.dataDelegate heightForRowAtIndexpath:path];
        return height;
    }
    
    return 40.0;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0 && indexPath.section==0 && self.internalHeaderContainer!=Nil) {
        //header selection, ignore it
        return;
    }
     NSIndexPath *path=[indexPath copy];
    
    if (self.dataDelegate && [self.dataDelegate respondsToSelector:@selector(rowSelectedAtIndex:)]) {
        if (self.internalHeaderContainer) {
            path=[NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        }
        [self.dataDelegate rowSelectedAtIndex:path];
    }

}

- (BOOL)scrollToTop
{
    [super scrollToTop];
    
    if (self.tableContent == nil)
        return NO;
    
    [self.tableContent setContentOffset:CGPointMake(0, 0) animated:YES];
    return YES;
    
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    CGRect keyboardFrame = [[[notification userInfo]objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];

    CGFloat maxY = keyboardFrame.origin.y - 10;

    UIView* firstResponder_ = [UserProfileBaseTableViewController findFirstResponderInView:self.view];
    if (firstResponder_ != nil &&
        ([firstResponder_ isKindOfClass:[UITextField class]] || [firstResponder_ isKindOfClass:[UITextView class]])) {
        CGRect rc = [self.view convertRect:firstResponder_.frame fromView:firstResponder_.superview];
        float viewBottom = CGRectGetMaxY(rc);
        if (viewBottom > maxY) {
            [self.tableContent setContentOffset:CGPointMake(0, viewBottom - maxY) animated:YES];
        };
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    [self.tableContent setContentOffset:CGPointZero];
}

+ (UIView*)findFirstResponderInView:(UIView*)view
{
    if (view.isFirstResponder) {
        return view;
    }
    
    for (UIView* subView in view.subviews) {
        UIView* firstResponder_ = [self findFirstResponderInView:subView];
        if (firstResponder_ != nil) {
            return firstResponder_;
        }
    }

    return nil;
}

@end

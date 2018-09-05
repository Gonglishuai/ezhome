//
//  CommentsViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 6/10/13.
//
//

#import "CommentsViewController_iPhone.h"


@implementation CommentsViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self readCommentsAction:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0) {
        return  55;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (IBAction)navBack:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.navigationController popViewControllerAnimated:NO];
                   });
}

-(void)moveTableViewForVisibleInput:(CommentCell*)cell{
    if (cell) {
        
        NSIndexPath *path = [self.tableview indexPathForCell:(UITableViewCell*)cell];
       
        if (path) {
            [self.tableview scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}




@end

//
//  FFResultsViewController_iPhone.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "FFResultsViewController_iPhone.h"

@implementation FFResultsViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self refreshUIAfterSearch];
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

-(void)dealloc{
    NSLog(@"dealloc - FFResultsViewController_iPhone");
}

- (IBAction)navigateToSearch:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)moveToInlineView{
    
    self.topNavigation.hidden=YES;
    self.tableHolderView.frame=self.view.frame;
    CGRect size=self.resultsTable.frame;
    size.size.width=self.view.frame.size.width;
    size.origin.x=0;
    self.resultsTable.frame=size;
}


@end

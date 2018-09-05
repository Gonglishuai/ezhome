//
//  iPadFFResultsViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 8/13/13.
//
//

#import "iPadFFResultsViewController.h"
#import "iPadFindFriendsViewController.h"
@interface iPadFFResultsViewController ()

@end

@implementation iPadFFResultsViewController

-(void)moveToInlineView{
    
    self.resultsSearchView.hidden=YES;
    CGRect rect=self.resultsTable.frame;
    
    rect.size=self.view.frame.size;
    rect.origin.y=0;
    self.resultsTable.frame=rect;
    
    rect=self.noResultsLabel.frame;
    rect.origin.y=20;
    self.noResultsLabel.frame=rect;
    
}

-(void)moveToNewView{
    
    CGRect rect=self.resultsTable.frame;
    rect.origin.y=self.resultsSearchView.frame.origin.y+self.resultsSearchView.frame.size.height;
    rect.size=CGSizeMake(self.view.frame.size.width,self.view.frame.size.height-self.resultsSearchView.frame.size.height);
    self.resultsTable.frame=rect;
    self.resultsSearchView.hidden=NO;
    
    rect=self.noResultsLabel.frame;
    rect.origin.y=66;
    self.noResultsLabel.frame=rect;
}

@end

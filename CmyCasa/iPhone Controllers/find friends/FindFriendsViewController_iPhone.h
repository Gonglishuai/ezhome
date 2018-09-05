//
//  FindFriendsViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/6/13.
//
//

#import "FindFriendsBaseViewController.h"
#import "FFResultsViewController_iPhone.h"

@interface FindFriendsViewController_iPhone : FindFriendsBaseViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewFF;
@property (nonatomic, strong) FFResultsViewController_iPhone * iphResults;
@end

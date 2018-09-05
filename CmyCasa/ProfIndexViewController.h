//
//  ProfIndexViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 1/13/13.
//
//

#import <UIKit/UIKit.h>

#import "ProfessionsPopupViewController.h"
#import "LocationsPopupViewController.h"
#import "ProfPageViewController.h"
#import "ProfessionalsIndexBaseViewController.h"

@interface ProfIndexViewController : ProfessionalsIndexBaseViewController<ProfessionsDelegate, LocationsDelegate, ProfessionalDelegate>
{
    @private
    NSMutableArray*           _profViews;
    UIPopoverController*      _professionsPopover;
    UIPopoverController*      _locationsPopover;
}

@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *noResultsView;
@property (weak, nonatomic) IBOutlet UILabel *noResultsLabel;

@end

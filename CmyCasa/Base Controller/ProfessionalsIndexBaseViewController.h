//
//  ProfessionalsIndexBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/25/13.
//
//

#import <UIKit/UIKit.h>


@class ProfFilterNames;

//GAITrackedViewController
@interface ProfessionalsIndexBaseViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
}

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIButton *profSignupButton;
@property (weak, nonatomic) IBOutlet UIButton *professionBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;
@property (weak, nonatomic) IBOutlet UILabel *lbProfessionDropDown;
@property (weak, nonatomic) IBOutlet UILabel *lblLocationDropDown;
@property(nonatomic, strong) NSMutableArray * professionsArr;
@property(nonatomic, strong) NSMutableArray * locationsArr;
@property(nonatomic, copy) NSString * selectedLocationKey;
@property(nonatomic, copy) NSString * selectedProfessionKey;
@property(nonatomic) NSMutableArray * combos;
@property(nonatomic) ProfFilterNames * filterNames;
@property(nonatomic) NSMutableArray * currentProfessionals;
- (void) updateProfessionals;
- (IBAction)menuPressed:(id)sender;
- (IBAction)backPressed:(id)sender;
- (void) populateProfessionals:(NSMutableArray*) professionals ;
- (void)professionSelected:(NSString*) key :(NSString*) value ;
- (void)locationSelected:(NSString*) key :(NSString*) value;
- (void)openProfSignupPage;
@end

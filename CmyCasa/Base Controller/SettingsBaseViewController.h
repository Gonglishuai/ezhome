//
//  SettingsBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/28/13.
//
//

#import <UIKit/UIKit.h>

#define ANIMATION_DURATION 0.5f

@interface SettingsBaseViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    BOOL _isPickerShowen;
}

@property (nonatomic) NSMutableArray * settingsList;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *signoutButton;
@property (strong, nonatomic) IBOutlet UIView *filterPickerView;
@property (strong, nonatomic) IBOutlet UIPickerView *filterPicker;
@property (strong, nonatomic) UIButton * clearOfflinePackage;
@property (nonatomic, assign) BOOL isLangDataLoaded;

- (void)openFeedback:(id)sender;
- (void)openAboutPage:(id)sender;
- (void)openTermsConditions:(id)sender;
- (void)clearOfflinePackage:(id)sender;
- (void)clearCache:(id)sender;
- (IBAction)closeSettings:(id)sender;
- (BOOL)needToggleCellForTitle:(NSString*)title;
- (IBAction)signoutAction:(id)sender;
- (void)showAlert;
- (void)actionEmailComposer;
@end

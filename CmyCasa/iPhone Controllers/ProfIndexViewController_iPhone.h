//
//  iphoneProfIndexViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 4/25/13.
//
//

#import "ProfessionalsIndexBaseViewController.h"

@interface ProfIndexViewController_iPhone : ProfessionalsIndexBaseViewController<UIPickerViewDataSource,UIPickerViewDelegate,IphoneMenuManagerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *filterPickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *itemsPicker;
@property (nonatomic, strong) NSMutableArray * currentFilterValues;
@property (weak, nonatomic) IBOutlet UILabel *noProfsTitle;
@property (weak, nonatomic) IBOutlet UIButton *locationButton;
@property (weak, nonatomic) IBOutlet UIButton *profButton;

- (IBAction)openMenu:(id)sender;
- (IBAction)closeFilterPicker:(id)sender;
- (IBAction)closeFilterAndPerformAction:(id)sender;
- (IBAction)openProfFilterOptions:(id)sender;
- (IBAction)openLocationFilterOptions:(id)sender;



@end


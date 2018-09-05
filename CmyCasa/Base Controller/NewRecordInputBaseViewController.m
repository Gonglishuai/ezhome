//
//  NewRecordInputBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import "NewRecordInputBaseViewController.h"
#import "ProfileUserDetailsViewController_iPad.h"
@interface NewRecordInputBaseViewController ()

@end

@implementation NewRecordInputBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    switch (self.inputFieldReference) {
        case kFieldProfessions:
            self.recordLabel.text=NSLocalizedString(@"i_am_title", @"");
            break;
            
        default:
            break;
    }
}

- (void)viewWillAppear:(BOOL)animated {
       [super viewWillAppear:animated];
    
    if (IS_IPAD) {
        CGSize size = CGSizeMake(245, 150); // size of view in popover
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            self.preferredContentSize=size;
        }else{
            self.preferredContentSize = size;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeAndUpdateAction:(id)sender {
   
    if (self.delegate && [self.delegate respondsToSelector:@selector(newRecordEntryUsedWithValue:forField:)]) {
        [self.delegate newRecordEntryUsedWithValue:self.recordField.text forField:self.inputFieldReference];
    }
}


@end

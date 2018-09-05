//
//  NewRecordInputBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 12/19/13.
//
//

#import <UIKit/UIKit.h>
@protocol TableOptionSelectionDelegate;

@interface NewRecordInputBaseViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *recordField;
@property (weak, nonatomic) IBOutlet UILabel *recordLabel;
@property(nonatomic) UserViewField inputFieldReference;
@property(nonatomic, weak) id<TableOptionSelectionDelegate> delegate ;

- (IBAction)cancelAction:(id)sender;
- (IBAction)closeAndUpdateAction:(id)sender;
@end

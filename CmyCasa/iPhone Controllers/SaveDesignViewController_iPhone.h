//
//  iphoneSaveDesignViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import "SaveDesignBaseViewController.h"

@interface SaveDesignViewController_iPhone : SaveDesignBaseViewController <UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *screenUIContainer;
@property (weak, nonatomic) IBOutlet UIView *chooseRoomTypeView;
@property (weak, nonatomic) IBOutlet UIPickerView *roomsPicker;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)cancelRoomChoosing:(id)sender;
- (IBAction)openRoomTypesSelection:(id)sender;
- (IBAction)chooseRoomAction:(id)sender;

@end

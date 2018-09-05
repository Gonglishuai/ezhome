//
//  iphoneSaveDesignViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import "SaveDesignViewController_iPhone.h"
#import "SaveDesignFlowBaseController.h"
#import "RoomTypeDO.h"

#define GAP 10
@interface SaveDesignViewController_iPhone ()
@end

@implementation SaveDesignViewController_iPhone

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Align the public label and switch
    self.publicLabel.frame = CGRectMake(self.publicSwitch.frame.origin.x + self.publicSwitch.frame.size.width + 5, self.publicLabel.frame.origin.y, self.publicLabel.frame.size.width, self.publicLabel.frame.size.height);
    self.publicLabel.center = CGPointMake(self.publicLabel.center.x, self.publicSwitch.center.y);
    
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, self.scrollView.frame.size.height)];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];
}

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskLandscape;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];

    CGFloat screenW = ([UIScreen currentScreenBoundsDependOnOrientation].size.width > [UIScreen currentScreenBoundsDependOnOrientation].size.height) ? [UIScreen currentScreenBoundsDependOnOrientation].size.width : [UIScreen currentScreenBoundsDependOnOrientation].size.height;
    CGFloat screenH = ([UIScreen currentScreenBoundsDependOnOrientation].size.width < [UIScreen currentScreenBoundsDependOnOrientation].size.height) ? [UIScreen currentScreenBoundsDependOnOrientation].size.width : [UIScreen currentScreenBoundsDependOnOrientation].size.height;
    
    self.view.frame = CGRectMake(0, 0, screenW, screenH);
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [self cancelRoomChoosing:nil];
    [super viewWillDisappear:animated];
}

- (void) textViewDidBeginEditing:(UITextView *)textView{
    [super textViewDidBeginEditing:textView];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [super textViewDidEndEditing:textView];
}

- (IBAction)cancelPressed:(id)sender {
    
    if (self.designDelegate) {
        [self.designDelegate saveDesignPopupClosedOnCancel];
    }
    
    [self.view endEditing:YES];
    
    self.errorLabel.text=@"";
    self.errorLabelSelectRoom.text = @"";
    self.titleText.text=@"";
    if (![[self parentViewController]isKindOfClass:[SaveDesignFlowBaseController class]]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) setUserInteraction:(Boolean) isEnabled {
    [self.coverView setHidden:isEnabled];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)cancelRoomChoosing:(id)sender {
    [self.chooseRoomTypeView setHidden:YES];
    
    _selectedRoomTypeKey = nil;
    
    SavedDesign * savedDesign = [[DesignsManager sharedInstance] workingDesign];
    [self updateRoomTypeBtnTitle:savedDesign];

    if (_selectedRoomTypeKey == nil) {
        [self changeRoomTypeBtnTitle:NSLocalizedString(@"room_type_filter", @"")];
    }
    
    [self.roomsPicker selectRow:0 inComponent:0 animated:NO];
    self.errorLabelSelectRoom.text = @"";
}

- (void)doShowRoomTypesPicker
{
    [self.titleText resignFirstResponder];

    NSUInteger rowIndex = 0;
    if (_selectedRoomTypeKey != nil) {
        for (NSUInteger index = 0; index < self.roomTypesArr.count; ++index) {
            RoomTypeDO* roomType_ = [self.roomTypesArr objectAtIndex:index];
            if ([roomType_.myId isEqualToString:_selectedRoomTypeKey]) {
                rowIndex = index;
                break;
            }
        }
    }

    RoomTypeDO* roomType = [self.roomTypesArr objectAtIndex:rowIndex];
    _selectedRoomTypeKey = roomType.myId;
    [self changeRoomTypeBtnTitle:NSLocalizedString(roomType.desc, @"")];
    [self.roomsPicker selectRow:rowIndex inComponent:0 animated:NO];

    [self.chooseRoomTypeView setHidden:NO];
}

- (void)handleSingleTap:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

#pragma mark - Override
- (void)handleMissingRoomType
{
    self.errorLabelSelectRoom.text = NSLocalizedString(@"illigal_room_type",@"Please choose Room Type.");
    self.errorLabel.text = @"";
    
    [self doShowRoomTypesPicker];
}

- (void)refreshSaveDialog
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [super refreshSaveDialog];
        [self.roomsPicker reloadAllComponents];
    });
}

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return  1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return  [self.roomTypesArr count];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    RoomTypeDO *room = [self.roomTypesArr objectAtIndex:row];
    NSString * item = NSLocalizedString(room.desc, @"");
    _selectedRoomTypeKey = room.myId;
    [self changeRoomTypeBtnTitle:item];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    RoomTypeDO *room = [self.roomTypesArr objectAtIndex:row];
    NSString * item= NSLocalizedString(room.desc, @"");
    return item;
}

- (IBAction)openRoomTypesSelection:(id)sender {
    [self doShowRoomTypesPicker];
}

- (IBAction)chooseRoomAction:(id)sender {
    self.errorLabelSelectRoom.text = @"";
     [self.chooseRoomTypeView setHidden:YES];
}

- (void)keyboardWillShowNotification:(NSNotification *)notification {
    
    float contentOffset = 0.0;
    if (self.titleText.isFirstResponder) {
        contentOffset = self.titleText.frame.origin.y - GAP;
    }else if (self.descriptionView.isFirstResponder) {
        contentOffset = self.descriptionView.frame.origin.y - GAP;
    }
    [self.scrollView setContentOffset:CGPointMake(0, contentOffset) animated:YES];

}

- (void)keyboardWillHideNotification:(NSNotification *)notification {
    
    [self.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.scrollView setContentOffset:CGPointZero];
}

- (IBAction)isPublicAction:(UISwitch *)sender {
    BOOL isOpen = !sender.on;
    [sender setOn:!isOpen];
    if (sender.on) {
        self.publicLabel.text = NSLocalizedString(@"design_public", @"");
    }else{
        self.publicLabel.text = NSLocalizedString(@"design_private", @"");
    }
}

@end

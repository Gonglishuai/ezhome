//
//  SaveDesignBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/6/13.
//
//

#import "SaveDesignBaseViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "ConfigManager.h"
#import "FlurryDefs.h"
#import "UIImage+Scale.h"
#import "NotificationAdditions.h"
#import "NotificationNames.h"
#import "RoomTypeDO.h"
#import "GalleryStreamManager.h"
#import "ProgressPopupViewController.h"
#import "UILabel+NUI.h"
#import "DataManager.h"
#import "SaveDesignResponse.h"

#define kSelectRoomBtnTextColor [UIColor colorWithRed:0.f/255.f green:127.f/255.f blue:234.f/255.f alpha:1.f]
#define ERROR_CODE_SESSION_INVALID 16
@interface SaveDesignBaseViewController ()

{
    NSCharacterSet *_blockedCharacters;
    BOOL _bClickedDescFirstTime;
}

-(void)saveDesignInternal:(BOOL)overideRequested;

@end

@implementation SaveDesignBaseViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.btnCancel setTitle:NSLocalizedString(@"alert_msg_button_cancel", @"") forState:UIControlStateNormal];
    self.lblSaveDesignTitle.text = NSLocalizedString(@"save_design_title", @"");
    CGRect frame = self.lblSwitchTitle.frame;
    frame.origin.x = self.publicSwitch.frame.origin.x + self.publicSwitch.frame.size.width + 9;
    self.lblSwitchTitle.frame = frame;
    
    [self changeRoomTypeBtnTitle:NSLocalizedString(@"room_type_filter", @"")];
    
    _blockedCharacters= [NSCharacterSet characterSetWithCharactersInString:@"\";/"];
    self.descriptionView.text= NSLocalizedString(@"default_text_for_save_design", @"default_text_for_save_design");
    _descriptionInitText = self.descriptionView.text;
    _descriptionTextColor = self.descriptionView.textColor;
    self.descriptionView.textColor = [UIColor colorWithRed:199.0f/255.f green:199.0f/255.f blue:199.0f/255.f alpha:1.0f];
    [self setUserInteraction:YES];
    
    self.descriptionView.textContainerInset = UIEdgeInsetsMake(20, 7, 0, 0);
    
    
    [[GalleryStreamManager sharedInstance] getRoomTypesWithCompletionBlock:^(NSArray *arrRoomTypes)
     {
         _roomTypesArr = arrRoomTypes;
         dispatch_async(dispatch_get_main_queue(), ^{
             [self refreshSaveDialog];
             [[ProgressPopupBaseViewController sharedInstance] stopLoading];
         });
         
     } failureBlock:^ (NSError *error){
         dispatch_async(dispatch_get_main_queue(), ^{
             [[ProgressPopupBaseViewController sharedInstance] stopLoading];
         });
     }];
    
    _selectedRoomTypeKey = nil;
    _bClickedDescFirstTime = YES;
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    //check if title differs from previously saved one and change the save button copy
    //save_design_action_title_save
    
    if ([[NSString stringWithFormat:@"%@%@",self.titleText.text,string] isEqualToString:[[DesignsManager sharedInstance] workingDesign].name] &&
        [[[DesignsManager sharedInstance] workingDesign].designID length]>0) {
        
        [self.saveButton setTitle:NSLocalizedString(@"save_design_action_title_saveas", @"") forState:UIControlStateNormal];
        
    }else{
        [self.saveButton setTitle:NSLocalizedString(@"save_design_action_title_save", @"") forState:UIControlStateNormal];
        
    }
    
    return ([string rangeOfCharacterFromSet:_blockedCharacters].location == NSNotFound);
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSInteger newTextLength = [self.descriptionView.text length] - range.length + [text length];
    
    if (newTextLength > 524) {
        // don't allow change
        return NO;
    }
    
    if (!IS_IPAD) {
        if ([text isEqualToString:@"\n"]) {
            [textView resignFirstResponder];
            
            return NO;
        }
        
    }
    
    return ([text rangeOfCharacterFromSet:_blockedCharacters].location == NSNotFound);
}

-(void)refreshSaveDialog{
    
    SavedDesign * savedDesign = [[DesignsManager sharedInstance] workingDesign];
    
    if (savedDesign && savedDesign.mustSaveAsNewDesign) {
        [self.saveButton setTitle:NSLocalizedString(@"save_design_action_title_save", @"") forState:UIControlStateNormal];
    }else{
        [self.saveButton setTitle:NSLocalizedString(@"save_design_action_title_saveas", @"") forState:UIControlStateNormal];
    }
    
    if (![savedDesign.name isEqualToString:@""]) {
        if (savedDesign.designID!=nil) {
            self.titleText.text = savedDesign.name;
        }
    }
    
    if (![savedDesign.designDescription isEqualToString:@""]) {
        if (savedDesign.designID!=nil) {
            self.descriptionView.text=  savedDesign.designDescription;
        }
    }
    
    [self updateRoomTypeBtnTitle:savedDesign];
    
    MyDesignDO* item = [[DesignsManager sharedInstance] findDesignByID:savedDesign.designID];
    if (item != nil) {
        self.publicSwitch.on = (item.publishStatus !=STATUS_PUBLIC) ? NO : YES;
        if (IS_IPHONE) {
            self.publicLabel.text = NSLocalizedString((item.publishStatus != STATUS_PUBLIC) ? @"design_private" : @"design_public", @"" );
        }else{
            self.lblSwitchTitle.text = NSLocalizedString((item.publishStatus != STATUS_PUBLIC) ? @"design_private" : @"design_public", @"" );
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.activityIndicator stopAnimating];
    [self.activityIndicator setHidden:YES];
    
    self.descriptionView.text = _descriptionInitText;
    self.titleText.text = @"";
    [self colorView:self.titleText isValid:YES];
    [self colorView:self.descriptionView isValid:YES];
    
    [self refreshSaveDialog];
}

-(void)viewWillDisappear:(BOOL)animated{
    [self.activityIndicator stopAnimating];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if(_bClickedDescFirstTime ==YES)
    {
        self.descriptionView.text = @"";
        _bClickedDescFirstTime = NO;
    }
    self.descriptionView.textColor = _descriptionTextColor;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if(self.descriptionView.text.length == 0)
    {
        self.descriptionView.textColor = [UIColor lightGrayColor];
        self.descriptionView.text = _descriptionInitText;
        _bClickedDescFirstTime = YES;
        
        [self.descriptionView resignFirstResponder];
    }
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"save_design_override_explanation",@"")]) {
        
        switch (buttonIndex) {
            case 0:
                //back button do nothing
                [self.view setUserInteractionEnabled:YES];
                [self setUserInteraction:YES];
                break;
            case 1:
                [self saveDesignInternal:YES];
                break;
            default:
                break;
        }
    }
    
    if ([[alertView message] isEqualToString:NSLocalizedString(@"save_design_ok",@"")]) {
        if (!IS_IPAD) {
            [self dismissViewControllerAnimated:NO completion:^{}];
        }
    }
}

-(void)saveDesignInternal:(BOOL)overideRequested{

    [self.activityIndicator setHidden:NO];
    [self.activityIndicator startAnimating];
    [self.titleText resignFirstResponder];
    [self.descriptionView resignFirstResponder];
    
    SavedDesign * saveddesign = [[DesignsManager sharedInstance] workingDesign];
    AppDelegate * appDelegate = [UIApplication sharedApplication].delegate;
    
    //pause before creating json from SavedDesign in order to block access
    appDelegate.glkVC.paused = YES;
    NSString * jsonString=[saveddesign jsonString];
    appDelegate.glkVC.paused = NO;
    
    // error in getting json data
    if([jsonString length] == 0)
    {
        self.errorLabel.text = NSLocalizedString(@"save_design_error_low_memory",@"Hmm, looks like there are too many products for your device to save this design, sorry! Try removing a few products and then save again.");
        return ;
    }
    
    NSString * desc = @"";
    if([self.descriptionView.text isEqualToString:_descriptionInitText] == NO)
    {
        desc = self.descriptionView.text;
    }
    
    [self.view setUserInteractionEnabled:NO];
    [self setUserInteraction:NO];

    NSString *title = self.titleText.text;
    [[DesignsManager sharedInstance] saveDesignOnServer:overideRequested
                                               isPublic:self.publicSwitch.isOn
                                              withTitle:title
                                         andDescription:desc
                                            andRoomType:_selectedRoomTypeKey
                                        completionBlock:^(id serverResponse, id error) {
                                            
                                            //success
                                            if (!error) {
                                                SaveDesignResponse * saveResponse = (SaveDesignResponse*)serverResponse;

                                                [self segmentDesignSaved];

                                                //UI stuff
                                                if (self.designDelegate) {
                                                    if ([self.designDelegate conformsToProtocol:@protocol(SaveDesignPopupDelegate)]) {
                                                        [self.designDelegate updateDesignTitle:title andDescription:desc andURL:saveResponse.urlFinal];
                                                    }
                                                    
                                                    [self.designDelegate saveDesignPopupClosed];
                                                    [self showAlertOnMainThread];
                                                }
                                                
                                            }else{
                                                //failed
                                                NSString * errorCode = (NSString*)error;
                                                if ([errorCode intValue] == ERROR_CODE_SESSION_INVALID) {
                                                    
                                                }else{
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        self.errorLabel.text = NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design . Please try again.");
                                                    });

                                                }
                                            }

                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.view setUserInteractionEnabled:YES];
                                                [self setUserInteraction:YES];
                                            });

                                        } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)showAlertOnMainThread{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:NSLocalizedString(@"save_design_ok",@"Beautiful! Your design has been saved.")
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert setAccessibilityLabel:@"save_design_ok_alert"];
        [alert show];
    });
}

- (IBAction)savePressed:(id)sender {
    
    [self.titleText resignFirstResponder];
    [self.descriptionView resignFirstResponder];
    self.errorLabel.text = @"";
    if (self.errorLabelSelectRoom)
    {
        self.errorLabelSelectRoom.text = @"";
    }
    
    [self colorView:self.titleText isValid:YES];
    [self colorView:self.descriptionView isValid:YES];
    
    self.errorLabel.text = @"";
    if (self.errorLabelSelectRoom)
    {
        self.errorLabelSelectRoom.text = @"";
    }
    
    //validate title
    NSString* trimmedStr = [self.titleText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.titleText.text == nil || trimmedStr.length == 0) {
        [self colorView:self.titleText isValid:NO];
        self.errorLabel.text = NSLocalizedString(@"illigal_save_title",@"Give your design a title.");
        return;
    }
    
    //validate room type
    if (_selectedRoomTypeKey == nil) {
        self.errorLabel.text = NSLocalizedString(@"illigal_room_type",@"Please choose Room Type.");
        [self handleMissingRoomType];
        return;
    }
    
    if (self.designDelegate)
    {
        UIImage * omg = [self.designDelegate getScreenShot];        
        [[DesignsManager sharedInstance] workingDesign].ImageWithFurnitures = omg;
    }
    
    SavedDesign * saveddesign = [[DesignsManager sharedInstance] workingDesign];
    
    if ([self.titleText.text isEqualToString:[[DesignsManager sharedInstance] workingDesign].name]  &&
        [[[DesignsManager sharedInstance] workingDesign].designID length] > 0                       &&
        saveddesign.mustSaveAsNewDesign == NO)
    {
        //alert about override
    
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"save_design_override_explanation",@"")
                                                      delegate:self
                                             cancelButtonTitle:NSLocalizedString(@"save_design_override_action_back", @"")
                                             otherButtonTitles:NSLocalizedString(@"save_design_override_action_override", @""), nil];
        
        [alert show];
    }else{
        [self saveDesignInternal:NO];
    }
    
    if (IS_IPAD) {
        CGRect frm = self.view.frame;
        frm.origin.y = 0;
        [UIView animateWithDuration:0.3 delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.view.frame = frm;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void) colorView:(UIView*)view isValid:(BOOL)isValid {
    if (isValid) {
        view.layer.borderWidth = 1.0f;
        view.layer.borderColor = [[UIColor colorWithRed:214.f/255.f green:214.f/255.f blue:214.f/255.f alpha:1.f] CGColor];
        
    }
    else {
        view.layer.borderWidth = 2.0f;
        view.layer.borderColor = [[UIColor redColor] CGColor];
    }
    view.clipsToBounds      = YES;
}

- (void) setUserInteraction:(Boolean) isEnabled {
    [self.coverView setHidden:isEnabled];
    
    if (isEnabled) {
        [self.activityIndicator stopAnimating];
    }
    else {
        [self.activityIndicator startAnimating];
    }
}

- (void)handleMissingRoomType
{
    
}

- (void)changeRoomTypeBtnTitle:(NSString*)newTitle {
    
    self.lblRoomType.text = newTitle;
    [self.lblRoomType sizeToFit];
    
    if (!IS_IPAD)
        return;
    
    CGFloat buttonHeight = (IS_IPAD) ? 30.0 : 22.0;
    CGFloat extraWidth = (IS_IPAD) ? 30.0 : 15.0;
    CGFloat buttonOffset = 10.f;
    
    self.selectRoomBtn.frame = CGRectMake(self.lblRoomType.frame.origin.x, self.lblRoomType.frame.origin.y, self.lblRoomType.frame.size.width + extraWidth, buttonHeight);
    
    self.lblRoomType.text = newTitle;
    [self.lblRoomType sizeToFit];
}

- (void)updateRoomTypeBtnTitle:(SavedDesign*)savedDesign
{
    NSString* roomTypeDesc = @"room_type_filter";
    if (![savedDesign.designRoomType isEqualToString:@""]) {
        _selectedRoomTypeKey = savedDesign.designRoomType;
        for (RoomTypeDO* roomType in _roomTypesArr) {
            if ([roomType.myId isEqualToString:_selectedRoomTypeKey]) {
                roomTypeDesc = roomType.desc;
                break;
            }
        }
    }
    [self changeRoomTypeBtnTitle:NSLocalizedString(roomTypeDesc, @"")];
}

- (IBAction)cancelPressed:(id)sender{
    //implement in son's
}

#pragma mark - SEGMENT
-(void)segmentDesignSaved{
    SavedDesign * saveddesign = [[DesignsManager sharedInstance] workingDesign];

    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    if ([[DataManger sharedInstance] designSource]) {
        [dict setObject:[[DataManger sharedInstance] designSource] forKey:@"design type"];
    }
    
    if (saveddesign.designID){
        [dict setObject:saveddesign.designID forKey:@"design id"];
    }
    
    if (saveddesign.name) {
        [dict setObject:saveddesign.name forKey:@"design title"];
    }
    
    NSMutableArray * listModelsIds = [NSMutableArray array];
    NSMutableArray * listModelsName = [NSMutableArray array];
    for (int i = 0; i < [saveddesign.models count]; i++) {
        Entity * e = [saveddesign.models objectAtIndex:i];
        
        if (e.modelId) {
            [listModelsIds addObject:e.modelId];
        }
        //[listModelsIds addObject:@""];
    }
    
    if (listModelsIds) {
        [dict setObject:listModelsIds forKey:@"product list id"];
    }
 
    if (listModelsName) {
        [dict setObject:listModelsName forKey:@"design title"];
    }
    
    if ([saveddesign.models count]) {
        [dict setObject:[NSString stringWithFormat:@"%d", [saveddesign.models count]] forKey:@"product count"];
    }
    
//    [HSFlurry segmentTrack:@"design saved" withParameters:dict];
}




@end

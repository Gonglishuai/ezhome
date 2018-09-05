//
//  MyDesignEditBaseViewController.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/14/13.
//
//

#import "MyDesignEditBaseViewController.h"
#import "ImageFetcher.h"
#import "NotificationNames.h"
#import "ControllersFactory.h"

#define MAX_LENGTH_TITLE        80
#define MAX_LENGTH_DESCRIPTION  2000

@interface MyDesignEditBaseViewController ()
{
}

@end

@implementation MyDesignEditBaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    bTextWasTouched = NO;
    blockedCharacters=[NSCharacterSet characterSetWithCharactersInString:@"\";/"];
    
    [self.notificationView setHidden:YES];
    [self setUserInteraction:YES];

    self.designTitle.text = self.design.title;
    self.designDescription.text = self.design._description;
    self.isPublicLabel.text = self.design.publishStatus ? NSLocalizedString(@"design_public", @"") : NSLocalizedString(@"design_private", @"");

    [self.designStatusSwith setOn:(self.design.publishStatus != STATUS_PRIVATE)];

    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        self.designDescription.editable = NO;
        self.designTitle.enabled = NO;
        self.designStatusSwith.enabled = NO;
    }

    [self loadDesignImage];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.notificationView setHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setUserInteraction:(BOOL) isEnabled {
    
    if (self.editDesignView) {
        [self.editDesignView setUserInteractionEnabled:isEnabled];
    }
    else {
        [self.view setUserInteractionEnabled:isEnabled];
    }
    isEnabled ? [self.activityIndicator stopAnimating] : [self.activityIndicator startAnimating];
}

- (IBAction)savePressed:(id)sender{
    //implement in son's
}

- (void) displayNotification:(BOOL)isError text:(NSString*)text {
//    [self.notificationView setHidden:NO];
    self.notificationLabel.text = text;
    
    if (isError) {
        [self.errorIcon setHidden:NO];
        [self.checkIcon setHidden:YES];
    }
    else {
        [self.errorIcon setHidden:YES];
        [self.checkIcon setHidden:NO];
    }
}

- (IBAction)duplicatePressed:(id)sender {

    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"redesign_inorder_for_changes", @"Please Redesign this design in order to make any changes") delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"") otherButtonTitles:nil] show];

        return;
    }
    
    if ([sender isEnabled]==NO) {
        return;
    }
    
    [sender setEnabled:NO];
    [self setUserInteraction:NO];

    __weak typeof(self) weakSelf = self;
    [self duplicateDesignInternal:^(NSString * designId, BOOL status) {
        if (weakSelf != nil) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf finishDesignDuplicateAction:designId withStatus:status sender:sender];
        }
    }];
}

- (void)startRedesignTool
{
    SavedDesign * saveDesign = [[DesignsManager sharedInstance] workingDesign];
    
    GalleryItemDO * gido = (GalleryItemDO*)self.design;
    [[UIManager sharedInstance] galleryDesignSelected:saveDesign withOriginalDesign:gido  withOriginEvent:EVENT_PARAM_VAL_LOAD_ORIGIN_REDESIGN];
    
    [[UIManager sharedInstance] galleryDesignBGImageRecieved:saveDesign.image andOrigImage:saveDesign.originalImage andMaskImage:saveDesign.maskImage];
}

- (IBAction)redesignPressed:(id)sender {
    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ask_to_redesign_auto_Save_from_mydesigns", @"Please Redesign and Save this design in order to make any changes")
                                  delegate:self cancelButtonTitle:NSLocalizedString(@"resume_alert_button", @"")
                         otherButtonTitles:NSLocalizedString(@"alert_msg_button_cancel", @""), nil] show];

        return;
    }

    if (self.design == nil) {
        [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"my_design_could_not_load", @"Could not load the selected design") delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"") otherButtonTitles:nil] show];
    }
    else if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(redesign:)]) {
            [self.delegate redesign:self.design];
        }
    }
}

- (IBAction)isPublicAction:(UISwitch *)sender {
    BOOL isOpen = !sender.on;
    [sender setOn:!isOpen];
    self.isPublicLabel.text = sender.on ? NSLocalizedString(@"design_public", @"") : NSLocalizedString(@"design_private", @"");
}

- (IBAction)deletePressed:(id)sender {
    
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"ask_delete_design",@"Are you sure you want to delete your design?")
                                                  delegate:self cancelButtonTitle:NSLocalizedString(@"alert_msg_button_cancel",@"Cancel") otherButtonTitles:NSLocalizedString(@"alert_msg_button_yes", @"Yes"), nil];
    
    [alert show];
}

-(void)deleteDesignInternal:(editDesignCompletionBlock)completion{

    NSString * designId = [NSString stringWithString:self.design._id];
    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        //remove obj from design manger
        [[DesignsManager sharedInstance] disregardCurrentAutoSaveObject];
        completion(designId, YES);
    }else{
        [[DesignsManager sharedInstance] deleteDesign:designId completionBlock:^(id serverResponse, id error) {
            
            if (completion) {
                if (error) {
                    completion(designId, NO);
                }else{
                    BaseResponse * response=(BaseResponse *)serverResponse;
                    if (response && response.errorCode==-1) {
                        completion(designId, YES);
                    }else{
                        completion(designId, NO);
                    }
                }
            }
        } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if ([[alertView message]isEqualToString:NSLocalizedString(@"ask_delete_design",@"Are you sure you want to delete your design?")]) {
        
        switch (buttonIndex) {
            case 0:
                
                break;
            case 1:
                    [self deleteDesign];
                break;
            default:
                break;
        }
    }
    
    if ([[alertView message]isEqualToString:NSLocalizedString(@"ask_to_redesign_auto_Save_from_mydesigns", @"")]) {
        switch ( buttonIndex) {
            case 0:
                [self startRedesignTool];
                break;
            case 1:
                //do nothing
            default:
                break;
        }
    }
    
}

-(void)duplicateDesignInternal:(editDesignCompletionBlock)completion{
    
    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        return;
    }
    
    if (completion) {
        NSString * designId = [NSString stringWithString:self.design._id];
        [[DesignsManager sharedInstance] duplicateDesign:designId completionBlock:^(id serverResponse, id error) {
            
            BOOL status = NO;
            
            if (serverResponse){
                BaseResponse * response = (BaseResponse*)serverResponse;
                
                if (response && response.errorCode == -1) {
                    status = YES;
                }
            }
            
            completion(designId, status);
            
        } queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    }
}

-(void)saveDesignInternal:(editDesignMetadataCompletionBlock)completion{
 
    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        return;
    }

    DesignMetadata* metadata = [DesignMetadata new];
    metadata.designId = [NSString stringWithString:self.design._id];
    if( bTextWasTouched == NO)
    {
        completion(metadata, YES);
        return ;
    }
    [self setUserInteraction:NO];

    metadata.textChanged = YES;
    metadata.designTitle = [NSString stringWithString:self.designTitle.text];
    metadata.designDescription = [NSString stringWithString:self.designDescription.text];
    
    [[DesignsManager sharedInstance] changeDesignMetadata:metadata.designId :metadata.designTitle :metadata.designDescription completionBlock:^(id serverResponse, id error) {
        
        if (completion) {
            BOOL status=false;
            
            if (error) {
                status=false;
            }else if (serverResponse){
                BaseResponse * response=(BaseResponse*)serverResponse;
                
                if (response && response.errorCode==-1) {
                    status=true;
                }
            }
            completion(metadata, status);
        }
    } queue:dispatch_get_main_queue()];
}


- (void)loadDesignImage
{
    if (self.design.eSaveDesignStatus == SAVED_DESIGN_STATUS_AUTOSAVE) {
        SavedDesign * autoDesign = [[DesignsManager sharedInstance] workingDesign];
        self.imageView.image = autoDesign.image;
        return;
    }
    
    CGSize designSize = self.imageView.frame.size;
    NSValue *valSize = [NSValue valueWithCGSize:designSize];
    NSDictionary *dic = @{IMAGE_FETCHER_INFO_KEY_EXTERNAL_URL: (self.design.url)?self.design.url:@"",
                          IMAGE_FETCHER_INFO_KEY_VALUE_IMAGE_CGSIZE : valSize,
                          IMAGE_FETCHER_INFO_KEY_LOCAL_FOLDER_TYPE : IMAGE_FETCHER_LOCAL_FOLDER_TYPE_DESIGN_STREAM,
                          IMAGE_FETCHER_INFO_KEY_ASSOCIATED_OBJECT : self.imageView};
    
    NSInteger lastUid = -1;
    lastUid = [[ImageFetcher sharedInstance] fetchImagewithInfo:dic andCompletionBlock:^ (UIImage *image, NSInteger uid, NSDictionary* imageMeta)
               {
                   NSInteger currentUid = [[ImageFetcher sharedInstance] getAssociatedUidFromObject:self.imageView];
                   
                   if (currentUid == uid)
                   {
                       dispatch_async(dispatch_get_main_queue(), ^
                                      {
                                          if (image)
                                          {
                                              self.imageView.image = image;
                                          }
                                      });
                   }
               }];
}

-(void)finishDesignDuplicateAction:(NSString *)designId withStatus:(BOOL)status sender:(id)sender {
    //implemt in son's
}

- (void)updateDesignStatus:(DesignStatus)status withCompletionBlock:(void(^)())completionBlock {
    
    //no change required
    if (self.design.publishStatus == STATUS_DELETED)
    {
        return;
    }

    if (self.designStatusSwith.isOn == (self.design.publishStatus == STATUS_PUBLIC)) // no change
    {
        return;
    }
    
    [self setUserInteraction:NO];

    __weak typeof(self) weakSelf = self;
    NSString * designId = [NSString stringWithString:self.design._id];
    [[DesignsManager sharedInstance] changeDesignStatus:self.design._id status:status completionBlock:^(id serverResponse, id error) {

        if (weakSelf != nil) {
            __strong typeof(self) strongSelf = weakSelf;
            [strongSelf updateDesignStatusFinished:designId serverResponse:serverResponse error:error];
        }
        
        if (completionBlock) {
            completionBlock();
        }
        
    } queue:dispatch_get_main_queue()];
}

- (void)updateDesignStatusFinished:(NSString *)designId serverResponse:(id)serverResponse error:(id)error {
    if (error) {
        [self displayNotification:YES text:NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design . Please try again.")];
    } else {
        BaseResponse * response=(BaseResponse*)serverResponse;
        if (response && response.errorCode==-1) {
            [self displayNotification:NO text:NSLocalizedString(@"save_design_ok",@"Beautiful! Your design has been saved.")];

            if ((self.delegate != nil) && ([self.delegate respondsToSelector:@selector(designPublishStateChanged:status:)])) {
                [self.delegate designPublishStateChanged:designId status:self.design.publishStatus];
            }
        } else {
            [self displayNotification:YES text:NSLocalizedString(@"save_design_error",@"Sorry, we couldn't save your design . Please try again.")];
        }
    }

    [self setUserInteraction:YES];
}

- (void)deleteDesign{
    //implement in son's
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    bTextWasTouched = YES;
    if ([string rangeOfCharacterFromSet:blockedCharacters].location != NSNotFound)
        return NO;

    NSUInteger newLength = textField.text.length + string.length - range.length;
    return (newLength <= MAX_LENGTH_TITLE);
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    bTextWasTouched = YES;
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    if ([text rangeOfCharacterFromSet:blockedCharacters].location != NSNotFound)
        return NO;

    NSUInteger newLength = textView.text.length + text.length - range.length;
    return (newLength <= MAX_LENGTH_DESCRIPTION);
}

@end

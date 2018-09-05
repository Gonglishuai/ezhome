//
//  iPhoneShoppingListViewController.m
//  Homestyler
//
//  Created by Dor Alon on 6/13/13.
//
//

#import "ShoppingListViewController_iPhone.h"
#import "ShoppingListCell.h"
#import <QuartzCore/QuartzCore.h>
#import "ProductVendorDO.h"

@interface ShoppingListViewController_iPhone ()

@end

@implementation ShoppingListViewController_iPhone
 
- (void)viewDidLoad
{
    [super viewDidLoad];
	self.titleLabel.text = NSLocalizedString(@"shopping_list_title", @"Product List");
    
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_PRODUCT_LIST withParameters:@{EVENT_PARAM_DESGIN_ID:(self.designObj._id)?self.designObj._id:@""}];
    
//    if ([ConfigManager isWhiteLabel])
    {
        [self.shareBtn setHidden:YES];
        [self.shareBtn setEnabled:NO];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];;
    
    __weak ShoppingListViewController_iPhone * weakSelf = self;
    [[ShoppingListManager sharedInstance] setDesign:self.designObj withComplition:^( NSString *response) {
        weakSelf.items = [[ShoppingListManager sharedInstance] getShoppingList];
        [weakSelf.tableView reloadData];
    }];
   
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){
        if (self.designObj._id && [self.designObj._id isEqual:[NSNull null]]==false) {
            
        NSArray * objs=[NSArray arrayWithObjects:self.designObj._id, nil];
        NSArray * keys=[NSArray arrayWithObjects:@"design_id", nil];
//        [HSFlurry logEvent:FLURRY_SHOPPING_LIST_VISITED withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        
        }
    }
#endif
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

-(void)dealloc{
    NSLog(@"dealloc - ShoppingListViewController_iPhone");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* cellIdentifier = @"ShoppingListCell";
    
    ShoppingListCell* cell = (ShoppingListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ShoppingListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.image.image = nil;
    cell.vendorImage.image = nil;
    
    if (indexPath.row < [_items count]) {
        ShoppingListItem* item = [_items objectAtIndex:indexPath.row];
        cell.nameLabel.text = item.Name;
        [cell.nameLabel setNumberOfLines:2];

        //[cell.gotoWebLabel setHidden:item.IsGeneric];
        //[cell.vendorLabel setHidden:item.IsGeneric];
        
        if (item.vendorName) {
            NSString* by = NSLocalizedString(@"shopping_list_by", @"by");
            cell.vendorLabel.text = [NSString stringWithFormat:@"%@ %@",by, item.vendorName];
        }
        cell.vendorProductUrl = item.vendorLink;
        cell.gotoWebLabel.hidden = cell.vendorProductUrl ? NO : YES;
        [cell initShoppingListCell:item];
    }
    
//    cell.userInteractionEnabled = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (void) showImage:(UIImageView*) imageView :(NSString*) path {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        UIImage* image = [UIImage safeImageWithContentsOfFile:path];
        dispatch_sync(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ShoppingListCell *cell = (ShoppingListCell*) [tableView cellForRowAtIndexPath:indexPath];
   
    if (cell.vendorProductUrl && [cell.vendorProductUrl length] != 0) {
        NSString *escapedUrl = [cell.vendorProductUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSArray *shoppingList = [[ShoppingListManager sharedInstance] getShoppingList];
        ShoppingListItem * item = nil;
        if (shoppingList && indexPath.row < [shoppingList count]) {
            item = [shoppingList objectAtIndex:indexPath.row];
        }
        
        if (item) {
 
//            [HSFlurry logAnalyticEvent:EVENT_NAME_CLICK_BRAND_LINK withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:
//                                                                                        EVENT_PARAM_VAL_LOAD_ORIGIN_PRODUCT_LIST,
//                                                                                    EVENT_PARAM_CONTENT_ID:(item.productId)?item.productId:@"",
//                                                                                    EVENT_PARAM_CONTENT_BRAND:(item.productVendor)?item.productVendor.vendorName:@""}];
        }

        GenericWebViewBaseViewController * web = [[UIManager sharedInstance]createGenericWebBrowser:cell.vendorProductUrl];
        [self presentViewController:web animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:  (NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)navigateBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)sharePressed:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        NSString * subjectPost = NSLocalizedString(@"shopping_list_email_subject", @"Check out these products from Homestyler.");
        [mailViewController setSubject:subjectPost];
        
        NSString * body = [[ShoppingListManager sharedInstance] getShoppingListAsHTML];
        
        [mailViewController setMessageBody:body isHTML:YES];
        dispatch_async(dispatch_get_main_queue(), ^ {
            [self  presentViewController:mailViewController animated:YES completion:nil];
        });
        
        
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
            NSArray * objs=[NSArray arrayWithObjects:self.designObj._id, nil];
            NSArray * keys=[NSArray arrayWithObjects:@"design_id", nil];
//            [HSFlurry logEvent:FLURRY_SHOPPING_LIST_SHARE withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        }
#endif
    }else {
        
        HSMDebugLog(@"Device is unable to send email in its current state.");
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"email_missing_default_msg",
                                                                                 @"Sorry no email account defined on this device")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
    }
}

@end

//
//  iPadShoppingListViewController.m
//  Homestyler
//
//  Created by Dor Alon on 6/9/13.
//
//

#import "ShoppingListViewController_iPad.h"
#import "ShoppingListCell.h"
#import "ProductVendorDO.h"
#import "ShoppingListManager.h"

@interface ShoppingListViewController_iPad ()

@end

@implementation ShoppingListViewController_iPad

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.titleLabel.text = NSLocalizedString(@"shopping_list_title", @"Product List");
    self.closeBtn.titleLabel.text = NSLocalizedString(@"shopping_list_close", @"Close");
    
    self.backImageView.clipsToBounds = NO;
    
//    [HSFlurry logAnalyticEvent:EVENT_NAME_PRODUCT_LIST withParameters:@{EVENT_PARAM_DESGIN_ID:(self.designObj._id)?self.designObj._id:@""}];
    
//    if ([ConfigManager isWhiteLabel])
    {
        [self.shareBtn setHidden:YES];
        [self.shareBtn setEnabled:NO];
    }
    
    [self updateData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
#ifdef USE_FLURRY
    if(ANALYTICS_ENABLED){    
        if (self.designObj._id && [self.designObj._id isEqual:[NSNull null]]==false) {
            NSArray * objs=[NSArray arrayWithObjects:self.designObj._id, nil];
            NSArray * keys=[NSArray arrayWithObjects:@"design_id", nil];
//            [HSFlurry logEvent:FLURRY_SHOPPING_LIST_VISITED withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        }
    }
#endif
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)dealloc{
    NSLog(@"dealloc - ShoppingListViewController_iPad");
}

- (void) updateData {
    [self.loader startAnimating];
    [self.tableView setAlpha:0.0];
    
   // __weak ShoppingListViewController_iPad * weakSelf = self;
    
    [[ShoppingListManager sharedInstance] setDesign:self.designObj withComplition:^(NSString *response) {
        [self.loader stopAnimating];
        
        NSInteger numOfElements = [[[ShoppingListManager sharedInstance] getShoppingList] count];
        if (numOfElements == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:NSLocalizedString(@"no_product", @"Sorry no products found")
                                           delegate:nil
                                  cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil] show];
                [self navigateBackPressed:nil];

            });
           
        }else{
            [self.tableView reloadData];
            [UIView animateWithDuration:0.3 animations:^{
                [self.tableView setAlpha:1.0];
            }];
        }
    }];
}

- (IBAction)backPressed:(id)sender {
    [self navigateBackPressed:nil];
}

- (IBAction)sharePressed:(id)sender {
    
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        
        NSString * subjectPost = NSLocalizedString(@"shopping_list_email_subject", @"Check out these products from Homestyler.");
        [mailViewController setSubject:subjectPost];
        
        NSString * body = [[ShoppingListManager sharedInstance] getShoppingListAsHTML];
        
        [mailViewController setMessageBody:body isHTML:YES];
        [self presentViewController:mailViewController animated:YES completion:nil];
        
#ifdef USE_FLURRY
        if(ANALYTICS_ENABLED){
            NSArray * objs=[NSArray arrayWithObjects:self.designObj._id, nil];
            NSArray * keys=[NSArray arrayWithObjects:@"design_id", nil];
//            [HSFlurry logEvent:FLURRY_SHOPPING_LIST_SHARE withParameters:[NSDictionary dictionaryWithObjects:objs forKeys:keys]];
        }
#endif
    }else{
        
        HSMDebugLog(@"Device is unable to send email in its current state.");
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@""
                                                       message:NSLocalizedString(@"email_missing_default_msg",
                                                                                 @"Sorry no email account defined on this device")
                                                      delegate:nil
                                             cancelButtonTitle:NSLocalizedString(@"alert_view_close_btn", @"Close") otherButtonTitles: nil];
        
        [alert show];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[ShoppingListManager sharedInstance] getShoppingList] count];
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString* cellIdentifier = @"ShoppingListCell";
    
    ShoppingListCell* cell = (ShoppingListCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[ShoppingListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    ShoppingListItem * item = nil;
    NSArray * shoppingList = [[ShoppingListManager sharedInstance] getShoppingList];
    
    if (shoppingList && indexPath.row < [shoppingList count]) {
        item = [shoppingList objectAtIndex:indexPath.row];
    }
   
    cell.nameLabel.text = item.Name;
    [cell.nameLabel setNumberOfLines:2];

    //[cell.gotoWebLabel setHidden:item.IsGeneric];
    //[cell.vendorLabel setHidden:item.IsGeneric];
    
    //if (!item.IsGeneric && item.productVendor.vendorName) {
    if (item.vendorName) {
        NSString* by = NSLocalizedString(@"shopping_list_by", @"by");
        cell.vendorLabel.text = [NSString stringWithFormat:@"%@ %@",by, item.vendorName];
    }
    
    cell.image.image = nil;
    cell.vendorImage.image = nil;
    cell.vendorProductUrl = item.vendorLink;
    cell.gotoWebLabel.hidden = cell.vendorProductUrl ? NO : YES;
    
//    cell.userInteractionEnabled = NO;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [cell initShoppingListCell:item];
    return cell;
}

//old way
- (void) showImage:(UIImageView*) imageView :(NSString*) path {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        UIImage* image = [UIImage safeImageWithContentsOfFile:path];
        dispatch_async(dispatch_get_main_queue(), ^{
            imageView.image = image;
        });
    });
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShoppingListCell *cell = (ShoppingListCell*) [tableView cellForRowAtIndexPath:indexPath];
 
    if (cell.vendorProductUrl && [cell.vendorProductUrl length] != 0) {
        NSString *escaped = [cell.vendorProductUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
       
        ShoppingListItem * item = nil;
        NSArray * shoppingList = [[ShoppingListManager sharedInstance] getShoppingList];
        
        if (shoppingList && indexPath.row < [shoppingList count]) {
            item = [shoppingList objectAtIndex:indexPath.row];
        }
        
        if (item) {
//            [HSFlurry logAnalyticEvent:EVENT_NAME_CLICK_BRAND_LINK withParameters:@{EVENT_PARAM_NAME_LOAD_ORIGIN:
//                                                                                        EVENT_PARAM_VAL_LOAD_ORIGIN_PRODUCT_LIST,
//                                                                                    EVENT_PARAM_CONTENT_ID:(item.productId)?item.productId:@"",
//                                                                                    EVENT_PARAM_CONTENT_BRAND:(item.productVendor)?item.productVendor.vendorName:@""}];
        
        }
        
//        NSString* urlWithReferer = [[ConfigManager sharedInstance] updateURLStringWithReferer:escaped];
        GenericWebViewBaseViewController * web = [[UIManager sharedInstance] createGenericWebBrowser:cell.vendorProductUrl];
        [self presentViewController:web animated:YES completion:nil];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult :(MFMailComposeResult)result error:  (NSError*)error {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)navigateBackPressed:(id)sender {
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.backImageView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self removeFromParentViewController];
        [self.view removeFromSuperview];
        [self.viewBg setAlpha:0.0];
        [self.backImageView setAlpha:1.0];
    }];
}

-(void)startBgAnimation{
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewBg setAlpha:0.5];
    } completion:nil];
}
@end

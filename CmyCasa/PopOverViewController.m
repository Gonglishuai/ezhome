//
//  RoomTypesViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/16/13.
//
//

#import "PopOverViewController.h"
#import "RoomTypeDO.h"
#import "WishListProductDO.h"
#import "CatalogMenuLogicManger.h"

#define KEYBOARD_HEIGHT_LANDSCAPE  162.0f
#define TEXTFIELD_TOP_MARGIN 5.0f

@interface PopOverViewController ()
{
    NSInteger _selectedIndex;
    float textfieldOriginalYLocation;
}
@end

@implementation PopOverViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    self.tableView.allowsMultipleSelection = YES;
    [self.doneBtn setEnabled:NO];
    
    // save old textfiled y location for finish editing
    textfieldOriginalYLocation = _wishListNameTextField.frame.origin.y;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

//override setter
-(void)setAllreadyInWishlist:(NSArray *)allreadyInWishlist{
    
    _allreadyInWishlist = allreadyInWishlist;
    
    if (!_wishListsArraySelection) {
        _wishListsArraySelection = [[NSMutableArray alloc] init];
    }
    
    [_wishListsArraySelection addObjectsFromArray:allreadyInWishlist];
}

- (void) setDataArray:(NSArray *) dataArray;
{
    if (dataArray && [dataArray count] > 0) {
        _keys = [[NSMutableArray alloc] init];
        _values = [[NSMutableArray alloc] init];

        //fail save
        if (!_wishListsArraySelection) {
            _wishListsArraySelection = [[NSMutableArray alloc] init];
        }
        
        NSObject * obj = [dataArray objectAtIndex:0];
        
        if ([obj isKindOfClass:[WishListProductDO class]]){
            for (WishListProductDO * wish in dataArray) {
                [_keys addObject:wish.productId];
                [_values addObject:wish.productName];
            }
        }else if ([obj isKindOfClass:[RoomTypeDO class]]) {
            for(RoomTypeDO *roomType in dataArray) {
                [_keys addObject:roomType.myId];
                [_values addObject:NSLocalizedString(roomType.desc, @"")];
            }
        }else if ([obj isKindOfClass:[NSDictionary class]]){
            for(NSDictionary* sortType in dataArray) {
                [_keys addObject:[sortType objectForKey:@"id"]];
                [_values addObject:[sortType objectForKey:@"d"]];
            }
        }else if ([obj isKindOfClass:[NSString class]]){
            for(NSString * language in dataArray) {
                [_keys addObject:language];
                [_values addObject:[language capitalizedString]];
            }
        }
    }
}

- (BOOL)setCurrentSelectedKey:(NSString*)key
{
    if (![_keys containsObject:key])
        return NO;
    
    self.selectedKey = key;
    return YES;
}

// Decode a percent escape encoded string.
- (NSString*) decodeFromPercentEscapeString:(NSString *) string {
    return (__bridge NSString *) CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,
                                                                                         (__bridge CFStringRef) string,
                                                                                         CFSTR(""),
                                                                                         kCFStringEncodingUTF8);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_keys count];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectZero];
    return footerView;
}

- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
   
    if (_values && indexPath.row < [_values count])
    {
        cell.textLabel.text = [self decodeFromPercentEscapeString:[_values objectAtIndex:indexPath.row]];
        cell.textLabel.textColor = [UIColor darkGrayColor];
        if ([cell.textLabel.text rangeOfString:NSLocalizedString(@"sort_type_copy", @"")].location !=NSNotFound || [cell.textLabel.text rangeOfString:NSLocalizedString(@"design_stream_filter", @"")].location !=NSNotFound) {
            cell.textLabel.textColor = [UIColor colorWithRed:157.0f/255.0f green:157.0f/255.0f blue:157.0f/255.0f alpha:1.0f];
        }
        
        if (self.popOverType == kPopOverWishList) {

            NSString * key = [_keys objectAtIndex:indexPath.row];
            
            if([_wishListsArraySelection containsObject:key] ){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }else{
            if ([[_keys objectAtIndex:indexPath.row] isEqualToString:self.selectedKey]){
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                _selectedIndex = indexPath.row;
            }else{
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
    }
    
    return cell;
}

- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{
	NSInteger idx = indexPath.row;
    
    NSArray * visiblecells = [tableView visibleCells];
    
    if (self.popOverType != kPopOverWishList) {
        for (UITableViewCell * cell in visiblecells) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
    }
   
    UITableViewCell *currentSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if ([currentSelectedCell.textLabel.text rangeOfString:NSLocalizedString(@"design_stream_filter", @"")].location != NSNotFound || [currentSelectedCell.textLabel.text rangeOfString:NSLocalizedString(@"sort_type_copy", @"")].location != NSNotFound) {
        [currentSelectedCell setAccessoryType:UITableViewCellAccessoryNone];
    }else{
        [currentSelectedCell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }

    
    switch (self.popOverType) {
        case kPopOverRoom:
            if ([self.delegate respondsToSelector:@selector(roomTypeSelectedKey:value:)] && [currentSelectedCell.textLabel.text rangeOfString:NSLocalizedString(@"design_stream_filter", @"")].location == NSNotFound ) {
                [self.delegate roomTypeSelectedKey:[_keys objectAtIndex:idx] value:[_values objectAtIndex:idx]];
            }
            break;
           
        case kPopOverSort:
            self.selectedKey = [_keys objectAtIndex:idx];
            if ([self.delegate respondsToSelector:@selector(sortTypeSelectedKey:value:)] && [currentSelectedCell.textLabel.text rangeOfString:NSLocalizedString(@"sort_type_copy", @"")].location == NSNotFound  ) {
                [self.delegate sortTypeSelectedKey:[_keys objectAtIndex:idx] value:[_values objectAtIndex:idx]];
            }
            break;
            
        case kPopOverLang:
            if ([self.delegate respondsToSelector:@selector(langSelectedkey:value:)]) {
                [self.delegate langSelectedkey:[_keys objectAtIndex:idx] value:[_values objectAtIndex:idx]];
            }

            break;
            
        case kPopOverCountry:
            if ([self.delegate respondsToSelector:@selector(countrySelectedkey:value:)]) {
                [self.delegate countrySelectedkey:[_keys objectAtIndex:idx] value:[_values objectAtIndex:idx]];
            }
            
            break;
            
        case kPopOverWishList:
        {
            //key = wishList Id
            NSString * key = [_keys objectAtIndex:indexPath.row];

            UITableViewCell *currentSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
            
            if (![_wishListsArraySelection containsObject:key]) {
                [_wishListsArraySelection addObject:key];
            }else{
                //need to upadate the remove array
                [_wishListsArraySelection removeObject:key];
                [currentSelectedCell setAccessoryType:UITableViewCellAccessoryNone];
            }
        }
            break;
        default:
            break;
    }
    
    if ([self isSelectionChange]) {
        [self.doneBtn setEnabled:YES];
    }else{
        [self.doneBtn setEnabled:NO];
    }
}

-(void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.popOverType == kPopOverWishList) {
        NSString * key = [_keys objectAtIndex:indexPath.row];
        
        if ([_wishListsArraySelection containsObject:key]) {
            [_wishListsArraySelection removeObject:key];
        }
        
        if ([self isSelectionChange]) {
            [self.doneBtn setEnabled:YES];
        }else{
            [self.doneBtn setEnabled:NO];
        }
        
        UITableViewCell *currentSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
        [currentSelectedCell setAccessoryType:UITableViewCellAccessoryNone];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - Wishlist Functions
-(IBAction)cancelBtnClicked:(id)sender{
    
    
    [UIView animateWithDuration:0.5 animations:^{
        [self.view setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.activityIndicator stopAnimating];
         if ([self.delegate respondsToSelector:@selector(wishlistCancelPressed)]) {
             [self.delegate wishlistCancelPressed];
         }
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        
        [[CatalogMenuLogicManger sharedInstance] setIsTableInEditMode:NO];

    }];
}

-(NSString *)encodeStringToUnicode:(NSString *)text
{
    NSString * encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                   NULL,
                                                                                   (CFStringRef)text,
                                                                                   NULL,
                                                                                   (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                   kCFStringEncodingUTF8));
    return encodedString;
}

-(IBAction)doneBtnClicked:(id)sender{
    

    NSString *encodedText = [self encodeStringToUnicode:self.wishListNameTextField.text];
    
    [self.doneBtn setEnabled:NO];
    [self.tableView setUserInteractionEnabled:NO];
    
    if (wishlistType == kWishListAddNewWishList) {
        if (![encodedText isEqualToString:@""]) {
            
            if ([self.delegate respondsToSelector:@selector(addNewWishList:)]) {
                [self.activityIndicator startAnimating];
                [self.delegate addNewWishList:encodedText];
            }
        }
    }else if(wishlistType == kWishListAddProduct){
        if ([self.delegate respondsToSelector:@selector(wishlistAddProductToWishLists: removeWishList:)]) {
            [self.activityIndicator startAnimating];
            
            NSMutableArray *removeArray = [[NSMutableArray alloc] init];
            for (NSString * key in self.allreadyInWishlist) {
                if (![_wishListsArraySelection containsObject:key]) {
                    [removeArray addObject:key];
                }
            }
            [self.delegate wishlistAddProductToWishLists:_wishListsArraySelection removeWishList:removeArray];
        }
    }
}

-(IBAction)addNewWishlistBtnClicked:(id)sender{

    [self.doneBtn setEnabled:NO];
    
    [self.addNewWishListName setHidden:NO];
    [self.addNewWishList setHidden:YES];
    [self.doneBtn setHidden:NO];

    wishlistType = kWishListAddNewWishList;
    
    [UIView transitionFromView:self.tableView toView:self.addNewWishListName
                      duration:1.0
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    completion:^(BOOL finished) {}];
}


-(void)stopActivityIndicator{
    [self.activityIndicator stopAnimating];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    // call animate textfield only for iphone device
    if (!IS_IPAD)
    {
        _wishListNameTextField.placeholder = _enterWishlistNameLabel.text;
        [self animateTextFieldAboveKeyboard:YES];
    }
    
    [self.doneBtn setEnabled:YES];
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField.text isEqual:@""]) {
        [self.doneBtn setEnabled:NO];
    }
    
    // call animate textfield only for iphone device
    if (!IS_IPAD)
    {
        // remove placeholder
        _wishListNameTextField.placeholder = @"";
        [self animateTextFieldAboveKeyboard:NO];
    }
    
    [textField resignFirstResponder];
    return YES;
}

- (void)keyboardDidHide:(NSNotification *)aNotification {
    if ([self.wishListNameTextField.text isEqual:@""]) {
        [self.doneBtn setEnabled:NO];
    }
}

//move textfield according to the keyboard when editing and finish editing
-(void)animateTextFieldAboveKeyboard:(BOOL)beginEdit
{
    float newY;
    
    // if YES we move the textfield to its superview y location (top of the textfield view)
    if (beginEdit == YES)
        newY = _wishListNameTextField.superview.superview.frame.origin.y + TEXTFIELD_TOP_MARGIN;
    else
        newY = textfieldOriginalYLocation;
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.wishListNameTextField setFrame:CGRectMake(_wishListNameTextField.frame.origin.x, newY,
                                                        _wishListNameTextField.frame.size.width,
                                                        _wishListNameTextField.frame.size.height)];
    } completion:^(BOOL finished) {
    }];
}

-(BOOL)isSelectionChange{
    
    if ([self.allreadyInWishlist count] != [_wishListsArraySelection count]) {
        return YES;
    }
    
    NSSet * allreadyInWishlistSet = [NSSet setWithArray:self.allreadyInWishlist];
    NSMutableSet * wishListsArraySelectionSet = [NSMutableSet setWithCapacity:[_wishListsArraySelection count]];
    [wishListsArraySelectionSet addObjectsFromArray:_wishListsArraySelection];
    
    [wishListsArraySelectionSet minusSet:allreadyInWishlistSet];
    if ([wishListsArraySelectionSet count] > 0) {
        return YES;
    }
    return NO;
}

@end

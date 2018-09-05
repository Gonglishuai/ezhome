//
//  RoomTypesViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 1/16/13.
//
//

#import <UIKit/UIKit.h>
#import "ProtocolsDef.h"

typedef enum {
    kPopOverRoom,
    kPopOverSort,
    kPopOverLang,
    kPopOverWishList,
    kPopOverCountry,
} PopOverType;

typedef enum {
    kWishListAddProduct,
    kWishListAddNewWishList,
} WishlistViewType;


@interface PopOverViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    @private
    NSMutableArray* _keys;
    NSMutableArray* _values;
    WishlistViewType wishlistType;
    NSMutableArray* _wishListsArraySelection;
}

@property (nonatomic,weak) id<PopoverDelegate>  delegate;
@property (nonatomic,assign) PopOverType popOverType;
@property (nonatomic,assign) NSString *selectedKey;
@property (nonatomic, weak) NSArray * allreadyInWishlist;
@property (nonatomic, weak) IBOutlet UIButton * cancelBtn;
@property (nonatomic, weak) IBOutlet UIButton * doneBtn;
@property (nonatomic, weak) IBOutlet UIButton * addNewWishList;
@property (nonatomic, weak) IBOutlet UIView * addNewWishListName;
@property (nonatomic, weak) IBOutlet UITableView * tableView;
@property (nonatomic, weak) IBOutlet UITextField * wishListNameTextField;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView * activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *enterWishlistNameLabel;

- (void) setDataArray:(NSArray *) dataArray;
- (BOOL)setCurrentSelectedKey:(NSString*)key;

-(IBAction)cancelBtnClicked:(id)sender;
-(IBAction)doneBtnClicked:(id)sender;
-(IBAction)addNewWishlistBtnClicked:(id)sender;
-(void)stopActivityIndicator;

@end

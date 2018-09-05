//
//  ProductsCatalogBaseViewController.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/20/13.
//
//

#import <UIKit/UIKit.h>
#import "ModelsHandler.h"
//GAITrackedViewController
@class  CatalogCategoryDO;
@interface ProductsCatalogBaseViewController : UIViewController <UITextFieldDelegate>
{
    int _offset;
    NSUInteger _limit; // TODO: need to read from config file
}

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addBrandButton;
@property (weak, nonatomic) IBOutlet UIButton *cataologButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (strong, nonatomic) NSMutableArray *products;
@property (strong, nonatomic) NSString* originalCategoryId;
@property (weak, nonatomic) IBOutlet UIView *tblHeaderView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UIView *missingResualtView;
@property (weak, nonatomic) IBOutlet UIView *topBarView;
@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet UILabel *lblMissingText;
@property (weak, nonatomic) IBOutlet UILabel *lblHeaderTitle;
@property (nonatomic) BOOL shouldShowErrorView;
@property (nonatomic) BOOL loading;
@property (nonatomic) BOOL isRootCategoryExpanded;
@property (weak, nonatomic) id <ProductsCatalogDelegate> delegate;
@property (nonatomic, assign) CatalogType catalogType;
@property (assign,nonatomic) BOOL isFromAR;
@property(strong,nonatomic) UIVisualEffectView *shadowView;

-(IBAction)catalogClicked:(id)sender;
-(void)categorySelected:(NSString*)categoryId catalogType:(CatalogType)catalogType;
-(void)searchCatalog:(NSString*)searchString;
-(void)flurry1:(CatalogCategoryDO*) category;
-(void)flurry2:(CatalogCategoryDO*) category;
-(void)flurry3:(NSString*)productid;
-(void)loadDataDelayed;

@end

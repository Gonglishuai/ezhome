//
//  ProductsCatalogViewController_iPhone.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/20/13.
//
//

#import "ProductsCatalogBaseViewController.h"
#import "ModelsHandler.h"

#define ROOT_CAT_TABLE_INIT_X 34
#define ROOT_CAT_TABLE_INIT_W 170
#define SUBROOT_CAT_TABLE_INIT_X 250

@interface ProductsCatalogViewController_iPhone : ProductsCatalogBaseViewController<UITableViewDataSource,UITableViewDelegate,ProductsCatalogDelegate, GenericWebViewDelegate>{
    
@private
    BOOL _isFirstRun;
}


@property (weak, nonatomic) IBOutlet UIView *vDarkBG;
@property (weak, nonatomic) IBOutlet UIView *rootContainer;
@property (weak, nonatomic) IBOutlet UIView *controlsContainer;
@property (weak, nonatomic) IBOutlet UIImageView* searchImage;
@property (weak, nonatomic) IBOutlet UIButton* toggleCatlogBtn;

- (IBAction)closeCatalog:(id)sender;
- (IBAction)toggleCatgoriesTables:(id)sender;

@end

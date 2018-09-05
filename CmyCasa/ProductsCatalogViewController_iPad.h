//
//  ProductsCatalogViewController.h
//  CmyCasa
//
//  Created by Dor Alon on 2/4/13.
//
//

#import <UIKit/UIKit.h>
#import "ProductsCatalogBaseViewController.h"
#import "CatalogSideMenuProtocols.h"
#import "ModelsHandler.h"

@interface ProductsCatalogViewController_iPad : ProductsCatalogBaseViewController <ProductsCatalogDelegate, GenericWebViewDelegate, CatalogSideMenuDelegate>

@property (weak, nonatomic) IBOutlet UIImageView* searchImage;
@property (nonatomic, assign) BOOL isTableInEditMode;

-(BOOL)isTableInEditMode;
-(IBAction)backPressed:(id)sender;

@end

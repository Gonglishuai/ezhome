//
//  ProductTagImageView.h
//  Homestyler
//
//  Created by Berenson Sergei on 8/20/13.
//
//

#import <UIKit/UIKit.h>
#define IPAD_PRODUCT_PROJECT_WIDTH 280
#define IPHONE_PRODUCT_PROJECT_WIDTH 167

@interface ProductTagImageView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *productImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property(nonatomic,strong) NSString* actionUrl;
@property (weak, nonatomic) IBOutlet UIImageView *ribonImage;
@property (weak, nonatomic) IBOutlet UILabel *ribonLabel;
@property (weak, nonatomic) IBOutlet UIView *ribonLabelContainer;
@property(nonatomic,strong) NSString * productID;
@property(nonatomic,strong) NSString * vendorName;
@property (weak, nonatomic) id<GenericWebViewDelegate> genericWebViewDelegate;
@property (strong,nonatomic) UIImage *selectedProductImage;

+(id)getProductTagImageView;
-(void)setupProductImage:(NSString*)image andUrl:(NSString*)url  prodID:(NSString *)productID vendorName:(NSString*)vendorName;
-(IBAction)actionButton:(id)sender;

@end

//
//  ProductTagGroupView.h
//  Homestyler
//
//  Created by Dan Baharir on 2/16/15.
//
//

#import <Foundation/Foundation.h>

@protocol SwappableProductDelegate <NSObject>

-(void)swappableProduct:(ProductDO *)product;

@end

@interface ProductTagGroupView : UIView

@property(nonatomic,strong) NSString* actionUrl;
@property (strong,nonatomic) ProductDO *product;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *productInfoButton;
@property (strong,nonatomic) NSMutableArray *productImagesArray;
@property (weak, nonatomic) id<SwappableProductDelegate> swappableProductDelegate;
@property (weak, nonatomic) id<GenericWebViewDelegate> genericWebViewDelegate;

-(void)setProductInView:(ProductDO *)product;
-(void)setDeselect;
-(void)setSelected;

- (IBAction)actionButtonClicked:(id)sender;
- (IBAction)swapEntityClicked:(id)sender;

@end

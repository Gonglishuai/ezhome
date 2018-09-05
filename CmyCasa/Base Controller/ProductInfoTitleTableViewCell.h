//
//  ProductInfoTitleTableViewCell.h
//  Homestyler
//
//  Created by Dan Baharir on 11/18/14.
//
//

#import <UIKit/UIKit.h>

@interface ProductInfoTitleTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *brandImageView;
@property (strong, nonatomic) IBOutlet UILabel *brandNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *productNameLabel;
@property (strong, nonatomic) IBOutlet UIButton *closeProductInfoButton;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *brandButton;
@property (strong, nonatomic) IBOutlet UIView *swappableVariationView;
@property (strong, nonatomic) IBOutlet UIScrollView *swappableVariationScrollView;
@property (weak, nonatomic) IBOutlet UIButton *goToWebBtn;
@property (weak, nonatomic) IBOutlet UIButton *goToWebBtnForIpad;

@end

//
//  CatalogProductCell.h
//  Homestyler
//
//  Created by Dor Alon on 2/17/13.
//
//

#import <UIKit/UIKit.h>
#import "SingleProductViewController.h"

@interface CatalogProductCell : UITableViewCell

@property (strong, nonatomic) SingleProductViewController *productView1;
@property (strong, nonatomic) SingleProductViewController *productView2;
@property (strong, nonatomic) SingleProductViewController *productView3;
@end

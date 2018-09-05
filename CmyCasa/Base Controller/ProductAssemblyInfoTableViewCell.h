//
//  ProductAssemblyInfoTableViewCell.h
//  Homestyler
//
//  Created by Dan Baharir on 1/4/15.
//
//

#import <UIKit/UIKit.h>

@interface ProductAssemblyInfoTableViewCell : ProductSwappableVariationCell

@property (weak, nonatomic) IBOutlet UIImageView *assemblyInfoImageView;
@property (weak, nonatomic) IBOutlet UILabel *assemblyProductNameLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;



@end

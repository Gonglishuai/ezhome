//
//  BannerCell.h
//  Homestyler
//
//  Created by xiefei on 1/11/17.
//

#import <UIKit/UIKit.h>
#import "GalleryStreamViewController.h"

@interface BannerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
-(void)loadBannerImage:(NSString*)imageUrlStr;
@property (weak,nonatomic) GalleryStreamViewController *vc;
@property (copy,nonatomic) NSString *bannerUrl;
@end

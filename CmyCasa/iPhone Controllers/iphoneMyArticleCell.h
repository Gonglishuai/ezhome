//
//  iphoneMyArticleCell.h
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import <UIKit/UIKit.h>

@interface iphoneMyArticleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *articleTitle;
@property (weak, nonatomic) IBOutlet UIImageView *articleImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activity;


@property(nonatomic)NSString * imagePath;
@property(nonatomic)GalleryItemDO * myarticle;

-(void)initWithArticle:(GalleryItemDO*)article;
@end

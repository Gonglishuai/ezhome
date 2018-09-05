//
//  iphoneMyArticleCell.m
//  Homestyler
//
//  Created by Berenson Sergei on 5/12/13.
//
//

#import "iphoneMyArticleCell.h"

@implementation iphoneMyArticleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initWithArticle:(GalleryItemDO*)article{
    
    self.myarticle=article;
    self.articleImage.image=nil;
    
    NSString* strID_Thumb = [NSString stringWithFormat:@"%@_thumb", article._id];
    NSString* imagePath = [[ConfigManager sharedInstance] getStreamFilePath:strID_Thumb];
    imagePath=[imagePath generateImagePathForWidth:self.frame.size.width andHight:self.frame.size.height];
    self.imagePath=imagePath;
    
    
    self.articleTitle.text=article.title;
}

@end

//
//  ArticleItemView.m
//  Homestyler
//
//  Created by Yiftach Ringel on 18/06/13.
//
//

#import "ArticleItemCollectionView.h"
#import "UIImageView+URLLoader.h"
#import "GalleryItemDO.h"

@interface ArticleItemCollectionView ()

- (IBAction)articlePressed;

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *articleImage;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@end

@implementation ArticleItemCollectionView

- (id)init
{
    self = [[NSBundle mainBundle] loadNibNamed:@"ArticleItemView" owner:self options:nil][0];
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.containerView.hidden = YES;    
}

- (void)setArticle:(GalleryItemDO *)article
{
    _article = article;
    
    if (article != nil)
    {
        self.containerView.hidden = NO;
        [self.articleImage loadImageWithUrl:article.url];
        self.titleLabel.text = article.title;
        if (self.containerView)
        {
            self.authorLabel.text = article.author;
        }
        else
        {
            self.authorLabel.text =[NSString stringWithFormat:NSLocalizedString(@"author_title", @"author_title"), article.author];
        }
    }
    else
    {
        self.containerView.hidden = YES;
    }
}

- (IBAction)articlePressed
{
    [self.delegate articlePressed:self.article];
}

@end

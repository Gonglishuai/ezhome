//
//  MyArticlesSingleItemViewController.m
//  CmyCasa
//
//  Created by Dor Alon on 1/10/13.
//
//

#import "MyArticlesSingleItemViewController.h"
#import "GalleryItemDO.h"

@interface MyArticlesSingleItemViewController ()

@end

@implementation MyArticlesSingleItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)prefersStatusBarHidden{
    return YES;
}

- (void) setArticle:(GalleryItemDO*) article {
    self.articleTitle.text = article.title;//[article objectForKey:@"t"];
    self.articleText.text =article._description;// [article objectForKey:@"d"];
    self.author.text = article.author;//[article objectForKey:@"author"];
    _articleId =article._id;// [article objectForKey:@"id"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0),^(void) {
        NSString* imageUrlStr =article.url;// [article objectForKey:@"url"];
        imageUrlStr=[imageUrlStr generateImageURLforWidth:self.imageView.bounds.size.width andHight:self.imageView.bounds.size.height];
        NSURL *url = [NSURL URLWithString:imageUrlStr];
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        dispatch_async(dispatch_get_main_queue(),^(void){
            self.imageView.image = [UIImage imageWithData:data];
        });
    });
}

- (IBAction)articlePressed:(id)sender {
    if (self.delegate != nil) {
        [self.delegate articleSelected:_articleId:nil:0];
    }
}
@end



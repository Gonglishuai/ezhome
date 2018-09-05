//
//  HSWebView.m
//  Homestyler
//
//  Created by Berenson Sergei on 4/2/13.
//
//

#import "HSWebView.h"
@interface HSWebView ()
{
    int lastOffsetY;
}
@end

@implementation HSWebView
@synthesize sendReverseScrollNotification;

-(void)updateOffset:(int)offset
{
    CGPoint p = self.scrollView.contentOffset;
    p.y += offset;
    [self.scrollView setContentOffset:p animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > lastOffsetY + 200) {
        //moved at least 50 pixels down from last we have
        if (sendReverseScrollNotification==false)
        {
            //HSMDebugLog(@"bottom");
            sendReverseScrollNotification=YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:ArticleWebViewScrollDownNotification object:nil];
        }
        else
        {
            lastOffsetY=scrollView.contentOffset.y;
        }
            
    }
    
    if (scrollView.contentOffset.y < lastOffsetY - 200) {
        //moved at least 50 pixels up from last we have
        if (sendReverseScrollNotification==TRUE)
        {
            sendReverseScrollNotification=NO;
            //HSMDebugLog(@"top");
            [[NSNotificationCenter defaultCenter] postNotificationName:ArticleWebViewScrollUpNotification object:nil];
            
        }
        else
        {
            lastOffsetY = scrollView.contentOffset.y;
        }
    }
}

- (void)dealloc
{
    NSLog(@"dealloc - HSWebView");
}

@end

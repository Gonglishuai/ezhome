 //
//  ProductInfoGroupTableViewCell.m
//  Homestyler
//
//  Created by Dan Baharir on 2/16/15.
//
//

#import "ProductInfoGroupTableViewCell.h"

#define GROUP_VIEW_WIDTH 280
#define GROUP_VIEW_SPACE 10
#define GROUP_VIEW_INDENT_SPACE 20


@implementation ProductInfoGroupTableViewCell 

-(void)clearCell{
    //clear views
    NSArray * subviews = [_groupScrollView subviews];
    for (UIView * gView in subviews) {
        [gView removeFromSuperview];
    }
}

-(void)generateGroupViews:(NSArray *)products currentProductId:(NSString*)productId
{
    
    //check if there are products in the group
    if (!products || [products count] == 0)
        return;

    //find the current element and put it first
    NSMutableArray * orderProduct = [NSMutableArray array];
    for (NSInteger i = 0; i < [products count]; i++)
    {
        ProductDO * product = [products objectAtIndex:i];
        if ([product.productId isEqualToString:productId]) {
            [orderProduct insertObject:product atIndex:0];
        }else{
            [orderProduct addObject:product];
        }
    }
    
    _groupScrollView.delegate = self;
    
    
    //clear views
    NSArray * subviews = [_groupScrollView subviews];
    for (UIView * gView in subviews) {
        [gView removeFromSuperview];
    }
    
    int totalWidth = 0;
    ProductTagGroupView *groupView;
 
    // add products (views) to the cell scroll view
    for (NSInteger i = 0; i < [orderProduct count]; i++)
    {
        ProductDO *product = [orderProduct objectAtIndex:i];
        if (IS_IPAD)
        {
            groupView =  [[[NSBundle mainBundle] loadNibNamed:@"ProductTagGroupView" owner:self options:nil] objectAtIndex:0];
        }
        else
        {
            groupView =  [[[NSBundle mainBundle] loadNibNamed:@"ProductTagGroupView_iphone" owner:self options:nil] objectAtIndex:0];
        }
        groupView.genericWebViewDelegate = self.genericWebViewDelegate;
        groupView.swappableProductDelegate = self;
        [groupView setProductInView:product];
        
   
        
        groupView.frame = CGRectMake(GROUP_VIEW_INDENT_SPACE + (i * groupView.frame.size.width) + (i * GROUP_VIEW_SPACE),
                                   0,
                                   groupView.frame.size.width,
                                   groupView.frame.size.height);
        
      
        [_groupScrollView addSubview:groupView];
        
        if (i == 0 ) {
            [groupView setSelected];
        }
    }
    
    totalWidth = GROUP_VIEW_INDENT_SPACE + GROUP_VIEW_SPACE + ([orderProduct count]  * groupView.frame.size.width ) + ([orderProduct count] * GROUP_VIEW_SPACE);
    
    // set the cell scroll view
    [_groupScrollView setContentOffset:CGPointMake(0, 0)];
    [_groupScrollView setContentSize:CGSizeMake(totalWidth, _groupScrollView.frame.size.height)];
    [self.loadingLbl setHidden:YES];
}

-(void)swappableProduct:(ProductDO *)product{
    
    RETURN_VOID_ON_NIL(product);
    
    if (self.productSwappableVariationCellDelegate && [self.productSwappableVariationCellDelegate respondsToSelector:@selector(swapEntityWithProduct:)])
    {
        [self.productSwappableVariationCellDelegate swapEntityWithProduct:product];
    }
}


@end

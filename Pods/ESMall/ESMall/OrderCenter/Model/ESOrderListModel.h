//
//  ESOrderListModel.h
//  Consumer
//
//  Created by shejijia on 2017/7/4.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESOrderListModel : NSObject

@property (assign, nonatomic) NSInteger pageNum;
@property (assign, nonatomic) NSInteger pageSize;
@property (assign, nonatomic) NSInteger size;
@property (assign, nonatomic) NSInteger startRow;
@property (assign, nonatomic) NSInteger endRow;
@property (assign, nonatomic) NSInteger total;
@property (assign, nonatomic) NSInteger pages;
@property (assign, nonatomic) NSArray * list;
@property (assign, nonatomic) NSInteger prePage;
@property (assign, nonatomic) NSInteger nextpage;
@property (assign, nonatomic) BOOL      isFirstPage;
@property (assign, nonatomic) BOOL      isLastPage;
@property (assign, nonatomic) BOOL      hasPreviousPage;
@property (assign, nonatomic) BOOL      hasNextPage;
@property (assign, nonatomic) NSInteger navigatePages;
@property (assign, nonatomic) NSArray * navigatepageNums;
@property (assign, nonatomic) NSInteger navigateFirstPage;
@property (assign, nonatomic) NSInteger navigateLastPage;
@property (assign, nonatomic) NSInteger firstPage;
@property (assign, nonatomic) NSInteger lastPage;

@end

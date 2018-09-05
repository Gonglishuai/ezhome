//
//  HomeConsumerDesignerModel.h
//  Consumer
//
//  Created by jiang on 2017/5/23.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "ESBaseModel.h"

@interface HomeConsumerDesignerModel : ESBaseModel

@property (nonatomic, copy) NSString *designer_id;
@property (nonatomic, copy) NSString *hs_uid;
@property (nonatomic, copy) NSString *backgroundImage;
@property (nonatomic, copy) NSString *designer_avatar;
@property (nonatomic, copy) NSString *designer_name;

@property (nonatomic, copy) NSString *work_years;
@property (nonatomic, copy) NSString *styles;
@property (nonatomic, copy) NSString *attention_count;
@end

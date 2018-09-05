//
//  HtmlURL.h
//  Consumer
//
//  Created by jiang on 2017/5/23.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JRNetEnvConfig.h"
#import "JRKeychain.h"

/**创建北舒套餐*/
#define kCreatePackage [NSString stringWithFormat:@"%@/h5/taocan/checkOwner?token=%@",[JRNetEnvConfig sharedInstance].netEnvModel.mServer, [JRKeychain loadSingleUserInfo:UserInfoCodeXToken]]


/**创建施工项目*/
#define kCreateEnterprise [NSString stringWithFormat:@"%@/static/pages/app/promotion.html?token=%@",[JRNetEnvConfig sharedInstance].netEnvModel.WebHost, [JRKeychain loadSingleUserInfo:UserInfoCodeXToken]]

/**买卖协议*/
#define kSaleAgreeSment [NSString stringWithFormat:@"%@/agreement?time=%lf",[JRNetEnvConfig sharedInstance].netEnvModel.mServer, [[NSDate date] timeIntervalSince1970]]

/**居然承诺*/
#define kJuranPromise [NSString stringWithFormat:@"%@promise?app&time=%lf",[JRNetEnvConfig sharedInstance].netEnvModel.mServer, [[NSDate date] timeIntervalSince1970]]

/**施工项目细则*/
#define kConstruction [NSString stringWithFormat:@"%@construction?app&time=%lf",[JRNetEnvConfig sharedInstance].netEnvModel.mServer, [[NSDate date] timeIntervalSince1970]]

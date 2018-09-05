//
//  ESDataAnalysisEvent.h
//  ESFoundation
//
//  Created by jiang on 2017/11/10.
//  Copyright © 2017年 jiangYunFeng. All rights reserved.
//

#import <Foundation/Foundation.h>

/*-------------打点事件统一定义到此处-----------*/
/*家装试衣间*/
#define Event_homestylerDownloadCount @"homestylerDownloadCount"// 美家达人下载按钮的点击次数
#define Event_fitting_room_banner @"fitting_room_banner"//家装试衣间Banner
#define Event_fitting_room_parlor @"fitting_room_parlor"//家装试衣间-客餐
#define Event_fitting_room_study @"fitting_room_study"//家装试衣间-书卧
#define Event_fitting_room_kitchen @"fitting_room_kitchen"//家装试衣间-厨卫

/*丽屋超市*/
#define Event_liwumarket_category @"liwumarket_category"//丽屋超市(五金涂料)
#define Event_liwumarket_banner @"liwumarket_banner"//商城丽屋超市banner
#define Event_liwumarket_hot_sale @"liwumarket_hot_sale"//商城丽屋超市热卖商品


/*商城*/
#define Event_mall_home_banner @"mall_home_banner"//商城首页Banner
#define Event_home_selected_plate(platformId) [NSString stringWithFormat:@"home_selected_plate_%ld", (long)platformId]//商城首页家具精选版块 轮播图下方第一个模块platformId:1, 第二模块platformId:2
#define Event_click_shop_card @"click_shop_card"//立即定制 添加购物车 立即购买
#define Event_to_promotion_purchase @"to_promotion_purchase"//立即抢购-秒杀商品详情
#define Event_commit_order_button @"commit_order_button"//提交订单按钮点击
#define Event_pay_order @"pay_order"//支付按钮点击
#define Event_pay_success @"pay_success"//支付成功事件监测

/*个人中心*/
#define Event_my_address @"my_address"//我的地址
#define Event_my_order @"my_order"//我的订单
#define Event_my_shopcar @"my_shopcar"//我的购物车
#define Event_mine_designers_recommend @"my_designers_recommend"//我的设计师推荐

#define Event_mine_news @"mine_news"//个人中心顶栏消息icon点击
#define Event_mine_avatar @"mine_avatar"//个人中心个人头像点击
#define Event_mine_booking @"mine_booking"//个人中心立即预约点击
#define Event_mine_project @"mine_project"//个人中心我的项目点击
#define Event_mine_concerned_designers @"mine_concerned_designers"//个人中心关注设计师点击
#define Event_mine_homepage @"mine_homepage"//个人中心个人主页点击
#define Event_mine_construction_project @"mine_construction_project"//个人中心我的施工项目点击
#define Event_mine_create_beishu @"mine_create_beishu"//个人中心创建北舒套餐点击
#define Event_mine_bind_owner @"mine_bind_owner"//个人中心绑定业主点击

//网络
#define Event_401 @"401"//接口401报错

//业主首页
#define Event_consumerhome_banner @"consumerhome_banner"//消费者首页顶部轮播图
#define Event_consumer_home_notice @"consumer_home_notice"//消费者首页公告位
#define Event_consumer_home_case @"consumer_home_case"//消费者首页精选案例
#define Event_consumer_home_designer @"consumer_home_designer"//消费者首页遇见设计师
#define Event_consumer_home_designer_more @"consumer_home_designer_more"//消费者首页更多设计师

//设计师首页
#define Event_designerhome_banner @"designerhome_banner"//设计师首页顶部轮播图
#define Event_designer_home_notice @"designer_home_notice"//设计师首页公告位
#define Event_designer_home_case @"designer_home_case"//设计师首页精选案例
#define Event_designer_home_case_more @"designer_home_case_more"//设计师首页更多案例
#define Event_designer_home_perfect_data @"designer_home_perfect_data"//设计师首页完善资料

//案例
#define Event_case_2D @"case_2D"//案例栏目顶栏左侧tab点击
#define Event_case_3D @"case_3D"//案例栏目顶栏右侧tab点击
#define Event_case_2D_filter @"case_2D_filter"//案例栏目顶栏左tab页筛选点击
#define Event_case_2D_search @"case_2D_search"//案例栏目顶栏左tab页搜索点击
#define Event_case_3D_filter @"case_3D_filter"//案例栏目顶栏右tab页筛选点击
#define Event_case_3D_search @"case_3D_search"//案例栏目顶栏右tab页搜索点击
#define Event_case_2D_case_img @"case_2D_case_img"//案例栏目左tab页所有案例图点击
#define Event_case_2D_case_avatar @"case_2D_case_avatar"//案例栏目左tab页所有头像点击
#define Event_case_3D_case_img @"case_3D_case_img"//案例栏目右tab页所有案例图点击
#define Event_case_3D_case_avatar @"case_3D_case_avatar"//案例栏目右tab页所有头像点击

//我要装修
#define Event_master @"master"//装修栏目大师tab点击
#define Event_master_booking @"master_booking"//装修栏目大师预约按钮点击
#define Event_studio @"studio"//装修栏目工作室tab点击
#define Event_studio_booking @"studio_booking"//装修栏目工作室预约按钮点击
#define Event_selected @"selected"//装修栏目精选tab点击
#define Event_selected_booking @"selected_booking"//装修栏目精选预约按钮点击
#define Event_jy @"jy"//装修栏目竞优tab点击
#define Event_jy_booking @"jy_booking"//装修栏目竞优预约按钮点击
#define Event_package @"package"//装修栏目套餐tab点击
#define Event_package_booking @"package_booking"//装修栏目套餐预约按钮点击
#define Event_diy @"diy"//装修栏目DIYtab点击

//设计师列表
#define Event_designer_filter @"designer_filter"//设计师栏目顶栏筛选点击
#define Event_designer_search @"designer_search"//设计师栏目顶栏搜索点击
#define Event_designer_list @"designer_list"//设计师栏目所有设计师条目点击


/*---------------LABEL-----------*/
#define Event_Param_position(index) @{@"index" : [NSString stringWithFormat:@"position%ld", (long)index]}

@interface ESDataAnalysisEvent : NSObject
@end


#import "MPBaseViewController.h"

@class MPDesignerInfoModel;
@class MPDecorationNeedModel;

typedef void (^ReturnBoolBlock)(BOOL isRequest);

@interface MPDesignerDetailViewController : MPBaseViewController

@property (nonatomic, copy) ReturnBoolBlock returnBoolBlock;

@property (nonatomic, assign) BOOL isSelection;

- (void)returnBool:(ReturnBoolBlock)block;

/**
 *  @brief the method for instancetype.
 *
 *  @param isDesignerPersonCenter the bool for come from person center or not.
 *
 *  @param model the model for designer.
 *
 *  @param isConsumerNeeds the bool for come from consumerNeeds.
 *
 *  @param needModel the model for decoration.
 *
 *  @param index the index for designer in bidders.
 *
 *  @return void nil.
 */
- (instancetype)initWithIsDesignerCenter:(BOOL)isDesignerPersonCenter
                               member_id:(NSString *)member_id
                         isConsumerNeeds:(BOOL)isConsumerNeeds;
@property (nonatomic, copy) void (^success)(void);

/// chat room id.
@property (nonatomic, copy) NSString *thread_id;

@end

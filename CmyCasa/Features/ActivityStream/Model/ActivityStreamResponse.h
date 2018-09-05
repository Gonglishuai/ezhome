//
//  ActivityStreamResponseObject.h
//  Homestyler
//
//  Created by Avihay Assouline on 12/23/13.
//
//

#import "BaseResponse.h"

///////////////////////////////////////////////////////
//                  INTERFACE                        //
///////////////////////////////////////////////////////

@interface ActivityStreamResponse : BaseResponse

// An array to store the buffered recent activities
@property (nonatomic, copy) NSMutableArray *activities;

// A date representing the most recent date the user accessed the stream prior to the current response (retrieved from server)
@property (nonatomic, copy) NSDate *lastRead;

// The number of activities in the current response that their creation date is newer than lastRead field
@property (nonatomic) NSUInteger activitiesSinceLastRead;

@end



#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CoValueType) {
	CoValueTypeNumber,
	CoValueTypePoint,
	CoValueTypeSize,
	CoValueTypeRect,
	CoValueTypeAffineTransform,
	CoValueTypeTransform3D,
	CoValueTypeUnknown
};

@interface NSValue (CoAdditions)

- (CGRect)co_rectValue;
- (CGSize)co_sizeValue;
- (CGPoint)co_pointValue;
- (CGAffineTransform)co_affineTransformValue;

+ (NSValue *)co_valueWithRect:(CGRect)rect;
+ (NSValue *)co_valueWithSize:(CGSize)size;
+ (NSValue *)co_valueWithPoint:(CGPoint)point;
+ (NSValue *)co_valueWithAffineTransform:(CGAffineTransform)transform;

- (CoValueType)co_type;

@end

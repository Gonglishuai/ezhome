
#import "NSValue+CoAdditions.h"

@implementation NSValue (CoAdditions)

- (CGRect)co_rectValue {
	return [self CGRectValue];
}

- (CGSize)co_sizeValue {
	return [self CGSizeValue];
}

- (CGPoint)co_pointValue {
	return [self CGPointValue];
}

- (CGAffineTransform)co_affineTransformValue {
	return [self CGAffineTransformValue];
}

+ (NSValue *)co_valueWithRect:(CGRect)rect {
	return [self valueWithCGRect:rect];
}

+ (NSValue *)co_valueWithPoint:(CGPoint)point {
	return [self valueWithCGPoint:point];
}

+ (NSValue *)co_valueWithSize:(CGSize)size {
	return [self valueWithCGSize:size];
}

+ (NSValue *)co_valueWithAffineTransform:(CGAffineTransform)transform {
	return [self valueWithCGAffineTransform:transform];
}


- (CoValueType)co_type {
	const char *type = self.objCType;
	
	static const NSInteger numberofNumberTypes = 10;
	static const char *numberTypes[numberofNumberTypes] = { "i", "s", "l", "q", "I", "S", "L", "Q", "f", "d" };
	
	for (NSInteger i = 0; i < numberofNumberTypes; i++) {
		if (strcmp(type, numberTypes[i]) == 0) {
			return CoValueTypeNumber;
		}
	}
	if (strcmp(type, @encode(CGPoint)) == 0) {
		return CoValueTypePoint;
	} else if (strcmp(type, @encode(CGSize)) == 0) {
		return CoValueTypeSize;
	} else if (strcmp(type, @encode(CGRect)) == 0) {
		return CoValueTypeRect;
	} else if (strcmp(type, @encode(CGAffineTransform)) == 0) {
		return CoValueTypeAffineTransform;
	} else if (strcmp(type, @encode(CATransform3D)) == 0) {
		return CoValueTypeTransform3D;
	} else {
		return CoValueTypeUnknown;
	}
}

@end

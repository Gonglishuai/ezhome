//
//  JRConsumerQRCodeReader.h
//  Consumer
//
//  Created by jiang on 2017/6/16.
//  Copyright © 2017年 Autodesk. All rights reserved.
//

#import "SHQRCodeReader.h"

typedef NS_ENUM(NSInteger, QRReaderType)
{
    QRReaderTypeUnKnow,
    QRReaderTypePackage,
    QRReaderTypeEnterprise
};

@interface JRConsumerQRCodeReader : SHQRCodeReader

@property (nonatomic, assign) QRReaderType type;

@end

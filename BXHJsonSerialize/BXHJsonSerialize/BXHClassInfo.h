//
//  BXHClassInfo.h
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/7.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

typedef NS_ENUM(NSInteger, BXHPropertyType)
{
    BXHPropertyTypeNone,
    BXHPropertyTypeNSInteger, //'i'
    BXHPropertyTypeCGFloat,//'f'
    BXHPropertyTypeBool,// 'B'
    BXHPropertyTypeNSObject,//'@'
    BXHPropertyTypeSelfObject//'@'
};

typedef NS_ENUM(NSInteger, BXHPropertyNSType)
{
    BXHPropertyTypeNSNone = 0,
    BXHPropertyTypeNSString,
    BXHPropertyTypeNSMutableString,
    BXHPropertyTypeNSValue,
    BXHPropertyTypeNSNumber,
    BXHPropertyTypeNSURL,
    BXHPropertyTypeNSArray,
    BXHPropertyTypeNSMutableArray,
    BXHPropertyTypeNSDictionary,
    BXHPropertyTypeNSMutableDictionary,
};

@interface BXHPropertyInfo : NSObject

@property (nonatomic, copy, readonly) NSString *name;

@property (nonatomic, assign, readonly) BXHPropertyType propertyType;

@property (nonatomic, assign, readonly) BXHPropertyNSType nsType;

@property (nonatomic, assign, readonly) Class cls;

@property (nonatomic, assign, readonly) SEL setter;               ///< setter (nonnull)

@property (nonatomic, assign, readonly) SEL getter;               ///< getter (nonnull)

@end

@interface BXHClassInfo : NSObject

@property (nonatomic, readonly, strong) NSDictionary <NSString *, BXHPropertyInfo *>*propertyMap;

@property (nonatomic, readonly, copy) NSString *className;

- (instancetype)initWithClass:(Class)cls;

@end

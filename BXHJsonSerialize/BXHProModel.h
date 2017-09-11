//
//  BXHProModel.h
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/11.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXHCityModel.h"
#import "NSObject+BXHJsonSerialize.h"

@interface BXHProModel : NSObject

@property (nonatomic, copy) NSString *provId;

@property (nonatomic, copy) NSString *provName;

@property (nonatomic, strong) NSArray <BXHCityModel *>*cityList;

@property (nonatomic, strong) NSURL *proUrl;

@property (nonatomic, assign) NSInteger proNum;

@property (nonatomic, copy) NSMutableString *proMStr;

@end

//
//  BXHCityModel.h
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/11.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BXHAreaModel.h"
#import "NSObject+BXHJsonSerialize.h"

@interface BXHCityModel : NSObject

@property (nonatomic, copy) NSString *cityId;

@property (nonatomic, copy) NSString *cityName;

@property (nonatomic, strong) NSArray <BXHAreaModel *>*areaList;

@end

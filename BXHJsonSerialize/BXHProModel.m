//
//  BXHProModel.m
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/11.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import "BXHProModel.h"

@implementation BXHProModel

- (id)bxh_JsonSerializeWithSerializeArray:(NSArray *)array andPropertyName:(NSString *)name
{
    return [BXHCityModel bxh_modelArySerializeWithAry:array];
}

@end

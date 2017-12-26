//
//  BXHCityModel.m
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/11.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import "BXHCityModel.h"

@implementation BXHCityModel

- (id)bxh_JsonSerializeWithSerializeArray:(NSArray *)array andPropertyName:(NSString *)name
{
    return [BXHAreaSubModel bxh_modelArySerializeWithAry:array];
}

- (NSArray *)bxh_JsonSerizlizeAryWithModels:(NSArray *)modelAry andPropertyName:(NSString *)name
{
    return [BXHAreaSubModel bxh_DeserializeToAryWithModelAry:modelAry];
}

@end

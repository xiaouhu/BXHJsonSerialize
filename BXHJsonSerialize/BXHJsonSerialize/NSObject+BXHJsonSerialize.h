//
//  NSObject+BXHJsonSerialize.h
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/7.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 1.支持model-json url互转
 2.基本类型 NSNumber互转
 3.string - mString ary - mAry dict - mDict 互转
 4.支持model含有model的情况（但不支持model中含有modelAry）不需要操作直接转
 5.支持替换 不解析（对应jsonToModel  modelToJson 两个过程）
*/

@protocol BXHJsonSerializeProtcol <NSObject>

@optional

/**
 json转model时替换的key  如：{@"jsonName" : @"propertyName"}

 @return dict
 */
+ (NSDictionary *)bxh_ReplaceKeyJsonToModel;

/**
 model转json时替换的key  如：{@"propertyName" : @"jsonName"}
 
 @return dict
 */
+ (NSDictionary *)bxh_ReplaceKeyModelToJson;


/**
 json转model时不参加的propertyName;

 @return ary
 */
+ (NSArray *)bxh_IgnoredKeyJsonToModel;


/**
 model转json时不参加的propertyName;

 @return ary
 */
+ (NSArray *)bxh_IgnoredKeyModelToJson;


/**
 用于json转model中有modelAry的情况

 @param array 会返回jsonAry
 @param name propertyName
 @return modelAry
 */
- (id)bxh_JsonSerializeWithSerializeArray:(NSArray *)array andPropertyName:(NSString *)name;


/**
 用于model转json中有modelAry的情况

 @param modelAry 会返回modelAry
 @param name propertyName
 @return jsonAry
 */
- (NSArray *)bxh_JsonSerizlizeAryWithModels:(NSArray *)modelAry andPropertyName:(NSString *)name;

@end

@interface NSObject (BXHJsonSerialize) <BXHJsonSerializeProtcol>

//================= json -----> model ====================//
//jsonStr转model 或 jsonStr转modelAry 如果json有误返回nil
+ (id)bxh_SerializeWithJsonStr:(NSString *)jsonStr;

//json转model工厂方法
+ (instancetype)bxh_SerializeWithDict:(NSDictionary*)dict;

//json转model类方法
- (id)bxh_SerializeWithDict:(NSDictionary *)dict;

//json转model工厂方法
+ (NSArray *)bxh_modelArySerializeWithAry:(NSArray *)ary;

//================= model -------> json ======================//

//model转json工厂方法传入modelAry
+ (NSArray *)bxh_DeserializeToAryWithModelAry:(NSArray *)modelAry;

//model转json
- (NSDictionary *)bxh_DeserializeToDict;


@end

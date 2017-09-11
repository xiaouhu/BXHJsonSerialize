//
//  BXHTempModel.h
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/8.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BXHTempModel : NSObject

@property (nonatomic, assign) double dbl;

@property (nonatomic, assign) long nLong;

@property (nonatomic, assign) long long nLLong;

@property (nonatomic, assign) int age;

@property (nonatomic, assign) CGFloat size;

@property (nonatomic, assign) float nFloat;

@property (nonatomic, assign) NSInteger integer;

@property (nonatomic, assign) BOOL isMan;

@property (nonatomic, strong) BXHTempModel *model;

@property (nonatomic, strong) NSNumber *number;

@property (nonatomic, strong) NSValue *value;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, strong) NSDictionary *dict;

@property (nonatomic, strong) NSMutableDictionary *mDict;

@property (nonatomic, strong) NSArray *ary;

@property (nonatomic, strong) NSMutableArray *mAry;


@end

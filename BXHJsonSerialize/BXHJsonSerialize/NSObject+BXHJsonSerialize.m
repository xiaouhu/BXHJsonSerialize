//
//  NSObject+BXHJsonSerialize.m
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/7.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import "NSObject+BXHJsonSerialize.h"
#import "BXHClassInfo.h"
#import <objc/message.h>

static id BXHNoneNull(__unsafe_unretained id value)
{
    static NSCharacterSet *dot;
    static NSDictionary *dic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        dic = @{
                @"NIL" :    (id)kCFNull,
                @"Nil" :    (id)kCFNull,
                @"nil" :    (id)kCFNull,
                @"NULL" :   (id)kCFNull,
                @"Null" :   (id)kCFNull,
                @"null" :   (id)kCFNull,
                @"(NULL)" : (id)kCFNull,
                @"(Null)" : (id)kCFNull,
                @"(null)" : (id)kCFNull,
                @"<NULL>" : (id)kCFNull,
                @"<Null>" : (id)kCFNull,
                @"<null>" : (id)kCFNull};
    });
    
    if (!value || value == (id)kCFNull) return nil;

    id v = dic[value];
    if (v) return nil;
    return value;
}


@interface BXHJsonSerializeMeta : NSObject

@property (nonatomic, strong) NSDictionary *replaceJTMDict;

@property (nonatomic, strong) NSDictionary *replaceMTJDict;

@property (nonatomic, strong) NSArray *ignoredJTMAry;

@property (nonatomic, strong) NSArray *ignoredMTJAry;

@property (nonatomic, strong) BXHClassInfo *classInfo;

+ (instancetype)bxh_serializeMetaWithClass:(Class)cls;

@end

@implementation BXHJsonSerializeMeta

- (instancetype)initWithClass:(Class)cls
{
    BXHClassInfo *classInfo = [[BXHClassInfo alloc] initWithClass:cls];
    if (!classInfo) return nil;
    if (self = [super init])
    {
        self.classInfo = classInfo;
        if ([cls respondsToSelector:@selector(bxh_ReplaceKeyJsonToModel)])
        {
            self.replaceJTMDict = [(id<BXHJsonSerializeProtcol>)cls bxh_ReplaceKeyJsonToModel];
        }
        
        if ([cls respondsToSelector:@selector(bxh_ReplaceKeyModelToJson)])
        {
            self.replaceMTJDict = [(id<BXHJsonSerializeProtcol>)cls bxh_ReplaceKeyModelToJson];
        }
        
        if ([cls respondsToSelector:@selector(bxh_IgnoredKeyJsonToModel)])
        {
            self.ignoredJTMAry = [(id<BXHJsonSerializeProtcol>)cls bxh_IgnoredKeyJsonToModel];
        }
        
        if ([cls respondsToSelector:@selector(bxh_IgnoredKeyModelToJson)])
        {
            self.ignoredMTJAry = [(id<BXHJsonSerializeProtcol>)cls bxh_IgnoredKeyModelToJson];
        }

    }
    return self;
}

+ (instancetype)bxh_serializeMetaWithClass:(Class)cls
{
    if (!cls) return nil;
    static CFMutableDictionaryRef cache;
    static dispatch_once_t onceToken;
    static dispatch_semaphore_t lock;
    dispatch_once(&onceToken, ^{
        cache = CFDictionaryCreateMutable(CFAllocatorGetDefault(), 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        lock = dispatch_semaphore_create(1);
    });
    dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
    BXHJsonSerializeMeta *meta = CFDictionaryGetValue(cache, (__bridge const void *)(cls));
    dispatch_semaphore_signal(lock);
    if (!meta)
    {
        meta = [[BXHJsonSerializeMeta alloc] initWithClass:cls];
        if (meta)
        {
            dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
            CFDictionarySetValue(cache, (__bridge const void *)(cls), (__bridge const void *)(meta));
            dispatch_semaphore_signal(lock);
        }
    }
    return meta;
}

@end

@implementation NSObject (BXHJsonSerialize)

#pragma mark - private
+ (id)jsonStrSerilize:(NSString *)jsonStr
{
    if (!jsonStr || jsonStr == (id)kCFNull) return nil;
    id result = nil;
    NSData *jsonData = [jsonStr dataUsingEncoding : NSUTF8StringEncoding];
    
    if (jsonData)
    {
        result = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:NULL];
    }
    return result;
}

- (void)setNumber:(id)obj ToProperty:(BXHPropertyInfo *)propertyInfo
{
    NSNumber *num = obj;
    if ([obj isKindOfClass:[NSString class]])
    {
        NSCharacterSet *dot = [NSCharacterSet characterSetWithRange:NSMakeRange('.', 1)];
        if ([(NSString *)obj rangeOfCharacterFromSet:dot].location != NSNotFound)
        {
            const char *cstring = ((NSString *)obj).UTF8String;
            if (!cstring) return;
            double n = atof(cstring);
            if (isnan(n) || isinf(n)) return;
            num = @(n);
        } else {
            const char *cstring = ((NSString *)obj).UTF8String;
            if (!cstring) return;
            num = @(atoll(cstring));
        }
    }
 
    switch (propertyInfo.propertyType)
    {
        case BXHPropertyTypeCGFloat:
        {
            ((void(*)(id, SEL, double))objc_msgSend)(self, propertyInfo.setter, [num doubleValue]);
        }
            break;
        case BXHPropertyTypeNSInteger:
        {
            ((void(*)(id, SEL, ino64_t))objc_msgSend)(self, propertyInfo.setter, [num integerValue]);
        }
            break;
        case BXHPropertyTypeBool:
        {
            ((void(*)(id, SEL, BOOL))objc_msgSend)(self, propertyInfo.setter, [num boolValue]);
        }
            break;
        
        default:
            break;
    }
}

- (NSNumber *)getNumOfProperty:(BXHPropertyInfo *)propertyInfo
{
    switch (propertyInfo.propertyType)
    {
        case BXHPropertyTypeCGFloat:
        {
            return @(((double (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter));
        }
            break;
        case BXHPropertyTypeNSInteger:
        {
            return @(((ino64_t (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter));
        }
            break;
        case BXHPropertyTypeBool:
        {
            return @(((BOOL (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter));
        }
            break;
            
        default:
            break;
    }
    return nil;
}

- (void)setSelfObject:(id)obj ToProperty:(BXHPropertyInfo *)propertyInfo
{
    if ([obj isKindOfClass:[NSDictionary class]])
    {
        id value = [propertyInfo bxh_SerializeWithDict:obj];
        ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, value);
    }
}

- (void)setNSObject:(id)obj ToProperty:(BXHPropertyInfo *)propertyInfo
{
    switch (propertyInfo.nsType)
    {
        case BXHPropertyTypeNSURL:
        {
            if (![obj isKindOfClass:[NSString class]]) return;
            ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, [NSURL URLWithString:obj]);
        }
            break;
        case BXHPropertyTypeNSString:
        {
            if (![obj isKindOfClass:[NSString class]]) return;
            ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, obj);
        }
            break;
        case BXHPropertyTypeNSMutableString:
        {
            if (![obj isKindOfClass:[NSString class]]) return;
            ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, [[NSMutableString alloc] initWithString:obj]);
        }
            break;
        case BXHPropertyTypeNSValue:
        {
            if ([obj isKindOfClass:[NSValue class]] && [obj isKindOfClass:[NSNumber class]])
            {
                ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, obj);
            }
        }
            break;
        case BXHPropertyTypeNSNumber:
        {
            if ([obj isKindOfClass:[NSValue class]] && [obj isKindOfClass:[NSNumber class]])
            {
                ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, obj);
            }
        }
            break;
        case BXHPropertyTypeNSArray:
        {
            if ([obj isKindOfClass:[NSArray class]])
            {
                NSArray *ary = obj;
                if ([self respondsToSelector:@selector(bxh_JsonSerializeWithSerializeArray:andPropertyName:)])
                {
                    ary = [self bxh_JsonSerializeWithSerializeArray:ary andPropertyName:propertyInfo.name];
                }
                ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, ary);
            }
        }
            break;
        case BXHPropertyTypeNSMutableArray:
        {
            if ([obj isKindOfClass:[NSArray class]])
            {
                NSArray *ary = obj;
                if ([self respondsToSelector:@selector(bxh_JsonSerializeWithSerializeArray:andPropertyName:)])
                {
                    ary = [self bxh_JsonSerializeWithSerializeArray:ary andPropertyName:propertyInfo.name];
                }
                ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, [NSMutableArray arrayWithArray:ary]);
            }
        }
            break;
        case BXHPropertyTypeNSDictionary:
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dict = obj;
             
                ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, dict);
            }
        }
            break;
        case BXHPropertyTypeNSMutableDictionary:
        {
            if ([obj isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dict = obj;
                if (dict)
                {
                    ((void(*)(id, SEL, id))objc_msgSend)(self, propertyInfo.setter, [NSMutableDictionary dictionaryWithDictionary:dict]);

                }
            }
        }
            break;
        default:
            break;
    }
}

- (id)getNSObjectWithProperty:(BXHPropertyInfo *)propertyInfo
{
    switch (propertyInfo.nsType)
    {
        case BXHPropertyTypeNSURL:
        {
            NSURL *url = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if (url) return url.relativeString;
            return nil;
        }
            break;
        case BXHPropertyTypeNSString:
        {
            NSString *str = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if (str) return str;
            return nil;
        }
            break;
        case BXHPropertyTypeNSMutableString:
        {
            NSMutableString *mStr = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if (mStr) return mStr;
            return nil;
        }
            break;
        case BXHPropertyTypeNSValue:
        {
            NSValue *value = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if (value) return value;
        }
            break;
        case BXHPropertyTypeNSNumber:
        {
            NSNumber *num = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if (num) return num;
        }
            break;
        case BXHPropertyTypeNSArray:
        {
            NSArray *ary = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if ([self respondsToSelector:@selector(bxh_JsonSerizlizeAryWithModels:andPropertyName:)])
            {
               ary = [self bxh_JsonSerizlizeAryWithModels:ary andPropertyName:propertyInfo.name];
            }
            if (ary) return ary;
        }
            break;
        case BXHPropertyTypeNSMutableArray:
        {
            NSArray *ary = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if ([self respondsToSelector:@selector(bxh_JsonSerizlizeAryWithModels:andPropertyName:)])
            {
                ary = [self bxh_JsonSerizlizeAryWithModels:ary andPropertyName:propertyInfo.name];
            }
            if (ary) return ary;
        }
            break;
        case BXHPropertyTypeNSDictionary:
        {
            NSDictionary *dict = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if (dict) return dict;
        }
            break;
        case BXHPropertyTypeNSMutableDictionary:
        {
            NSDictionary *dict = ((id (*)(id, SEL))(void *) objc_msgSend)(self, propertyInfo.getter);
            if (dict) return dict;
        }
            break;
        default:
            return nil;
            break;
    }
    return nil;
}

#pragma mark - public
//================= json -----> model ====================//

+ (id)bxh_SerializeWithJsonStr:(NSString *)jsonStr
{
    id result = [self jsonStrSerilize:jsonStr];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        return [self bxh_SerializeWithDict:result];
    }
    else if ([result isKindOfClass:[NSArray class]])
    {
        return [self bxh_modelArySerializeWithAry:result];
    }
    else
    {
        return nil;
    }
}

+ (instancetype)bxh_SerializeWithDict:(NSDictionary*)dict
{
    NSObject *object = [[self alloc] init];
    return [object bxh_SerializeWithDict:dict];
}

- (id)bxh_SerializeWithDict:(NSDictionary *)dict
{
    BXHJsonSerializeMeta *meta = [BXHJsonSerializeMeta bxh_serializeMetaWithClass:[self class]];
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if(![meta.ignoredJTMAry containsObject:key])
        {
            id value = BXHNoneNull(obj);
            if (value)
            {
                NSString *replaceKey = [meta.replaceJTMDict objectForKey:key];
                BXHPropertyInfo *propertyInfo = [meta.classInfo.propertyMap objectForKey:(replaceKey && replaceKey.length) ? replaceKey : key];
    
                if (propertyInfo.propertyType == BXHPropertyTypeSelfObject)
                {
                    [self setSelfObject:obj ToProperty:propertyInfo];
                }
                else if (propertyInfo.propertyType == BXHPropertyTypeNSObject)
                {
                    [self setNSObject:obj ToProperty:propertyInfo];
                }
                else
                {
                    [self setNumber:obj ToProperty:propertyInfo];
                }
            }
        }
    }];
    return self;
}

+ (NSArray *)bxh_modelArySerializeWithAry:(NSArray *)ary
{
    if (!ary || !ary.count) return nil;
    NSMutableArray *result = [NSMutableArray array];
    for (NSDictionary *dict in ary)
    {
        NSObject *obj = [[self alloc] init];
        [obj bxh_SerializeWithDict:dict];
        [result addObject:obj];
    }
    return result;
}

//================= model -------> json ======================//
+ (NSArray *)bxh_DeserializeToAryWithModelAry:(NSArray *)modelAry
{
    NSMutableArray *dicts = [NSMutableArray arrayWithCapacity:modelAry.count];
    for (id obj in modelAry)
    {
       [dicts addObject:[obj bxh_DeserializeToDict]];
    }
    return dicts.copy;
}

- (NSDictionary *)bxh_DeserializeToDict
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    BXHJsonSerializeMeta *meta = [BXHJsonSerializeMeta bxh_serializeMetaWithClass:[self class]];
    [meta.classInfo.propertyMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, BXHPropertyInfo * _Nonnull obj, BOOL * _Nonnull stop)
     {
         if (![meta.ignoredMTJAry containsObject:key])
         {
             NSString *replaceKey = [meta.replaceMTJDict objectForKey:key];
             if (!replaceKey && !replaceKey.length)
             {
                 replaceKey = key;
             }
             
             if (obj.propertyType == BXHPropertyTypeNSObject)
             {
                 NSObject *value = [self getNSObjectWithProperty:obj];
                 if (value) [dict setObject:value forKey:replaceKey];
             }
             else if (obj.propertyType == BXHPropertyTypeSelfObject)
             {
                 if (obj)
                 {
                    NSDictionary *desDict = [obj bxh_DeserializeToDict];
                    [dict setObject:desDict forKey:replaceKey];
                 }
             }
             else
             {
                 NSNumber *num = [self getNumOfProperty:obj];
                 if (num)
                 {
                     [dict setObject:num forKey:replaceKey];
                 }
             }
         }
    }];
    return dict;
}

@end

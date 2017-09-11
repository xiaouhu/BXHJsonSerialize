//
//  BXHClassInfo.m
//  BXHJsonSerialize
//
//  Created by 步晓虎 on 2017/9/7.
//  Copyright © 2017年 步晓虎. All rights reserved.
//

#import "BXHClassInfo.h"



static BXHPropertyType BXHEncodeGetType(const char *type)
{
    char *tempType = (char *)type;
    size_t len = strlen(tempType);
    if (len == 0) return BXHPropertyTypeNone;
    
    switch (*type) {
        case 'B': return BXHPropertyTypeBool;
        case 'c':
        case 'C':
        case 's':
        case 'S':
        case 'i':
        case 'I':
        case 'l':
        case 'L':
        case 'q':
        case 'Q': return BXHPropertyTypeNSInteger;
        case 'f':
        case 'd':
        case 'D': return BXHPropertyTypeCGFloat;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return BXHPropertyTypeNone;
            else
                return BXHPropertyTypeNSObject;
        }
        default: return BXHPropertyTypeNone;
    }

}

static BXHPropertyNSType BXHClassIsNSClass(Class cls)
{
    if (!cls) return BXHPropertyTypeNSNone;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return BXHPropertyTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return BXHPropertyTypeNSString;
    if ([cls isSubclassOfClass:[NSNumber class]]) return BXHPropertyTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return BXHPropertyTypeNSValue;
    if ([cls isSubclassOfClass:[NSURL class]]) return BXHPropertyTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return BXHPropertyTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return BXHPropertyTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return BXHPropertyTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return BXHPropertyTypeNSDictionary;
    return BXHPropertyTypeNSNone;
}

@interface BXHPropertyInfo()

@property (nonatomic, assign) objc_property_t property;

@end

@implementation BXHPropertyInfo

- (void)setProperty:(objc_property_t)property
{
    _property = property;
    _name = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
    unsigned int attrCount;
    objc_property_attribute_t *attrs = property_copyAttributeList(property, &attrCount);
    for (int i = 0; i < attrCount; i ++)
    {
        objc_property_attribute_t attr = attrs[i];
        if (attr.name[0] == 'T')
        {
            if (attrs[i].value)
            {
                NSString *typeEncode = [NSString stringWithUTF8String:attrs[i].value];
                BXHPropertyType type = BXHEncodeGetType(attrs[i].value);
                
                if (type == BXHPropertyTypeNSObject && typeEncode.length)
                {
                    NSScanner *scanner = [NSScanner scannerWithString:typeEncode];
                    if (![scanner scanString:@"@\"" intoString:NULL]) continue;
                    
                    NSString *clsName = nil;
                    if ([scanner scanUpToCharactersFromSet: [NSCharacterSet characterSetWithCharactersInString:@"\"<"] intoString:&clsName]) {
                        if (clsName.length)
                        {
                            _cls = objc_getClass(clsName.UTF8String);
                            _nsType = BXHClassIsNSClass(_cls);
                        }
                    }
                    if (_nsType == BXHPropertyTypeNSNone)
                    {
                        type = BXHPropertyTypeSelfObject;
                    }
                }
                _propertyType = type;
            }
        }
    }
    if (!_getter)
    {
        _getter = NSSelectorFromString(_name);
    }
    if (!_setter)
    {
        _setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [_name substringToIndex:1].uppercaseString, [_name substringFromIndex:1]]);
    }
    free(attrs);
}

@end

@implementation BXHClassInfo

- (instancetype)initWithClass:(Class)cls
{
    if (self = [super init])
    {
        unsigned int outCount;
        _propertyMap = [NSMutableDictionary dictionary];
        objc_property_t *properties = class_copyPropertyList(cls, &outCount);
        for (int i = 0; i < outCount; i++)
        {
            BXHPropertyInfo *propertyInfo = [[BXHPropertyInfo alloc] init];
            propertyInfo.property = properties[i];
            [(NSMutableDictionary *)_propertyMap setObject:propertyInfo forKey:propertyInfo.name];
        }
        free(properties);
    }
    return self;
}

@end

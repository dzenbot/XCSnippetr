//
//  XCSKit
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "NSObject+SmartDescription.h"
#import <objc/runtime.h>

@implementation NSObject (SmartDescription)

- (NSString *)smartDescription
{
    NSMutableString *string = [NSMutableString stringWithFormat:@"<%@: %p> ", NSStringFromClass([self class]), self];
    NSDictionary *properties = [self propertyList];
    
    for (int i = 0; i < properties.count; i++) {
        
        if (i != 0) {
            [string appendString:@" | "]; // Separator
        }
        
        NSString *key = [properties allKeys][i];
        [string appendFormat:@"%@ = %@", key, properties[key]];
    }
    
    return string;
}

- (NSDictionary *)propertyList
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (propertyValue) [props setObject:propertyValue forKey:propertyName];
    }
    free(properties);
    return props;
}

@end

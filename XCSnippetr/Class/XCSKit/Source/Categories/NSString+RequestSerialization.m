//
//  XCSKit
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "NSString+RequestSerialization.h"

@implementation NSString (RequestSerialization)

- (NSString *)stringByAppendingRequestParameters:(NSDictionary *)params
{
    NSMutableArray *scopes = [NSMutableArray new];
    
    for (int i = 0; i < [params allKeys].count; i++) {
        
        NSString *key = [params allKeys][i];
        NSString *value = params[key];
        
        if (([value isKindOfClass:[NSString class]] && value.length > 0) || [value isKindOfClass:[NSNumber class]]) {
            
            if ([value isKindOfClass:[NSString class]]) {
                value = NSStringEscapedFrom(value);
            }
            
            [scopes addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
        }
    }
    
    if (scopes.count == 0) {
        return self;
    }
    
    NSString *parameters = [scopes componentsJoinedByString:@"&"];
    
    return [self stringByAppendingFormat:@"?%@", parameters];
}

#pragma mark - Helpers

NSString *NSStringEscapedFrom(NSString *v) {
    static CFStringRef charactersToBeEscaped = CFSTR("￼=,!$&'()*+;@?\r\n\"<>#\t :/");
    static CFStringEncoding encoding = kCFStringEncodingUTF8;
    return ((__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[v mutableCopy], NULL, charactersToBeEscaped, encoding));
}

@end

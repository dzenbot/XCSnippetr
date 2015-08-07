//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "NSJSONSerialization+FileContent.h"

static NSString * const kJSONType = @"json";

@implementation NSJSONSerialization (FileContent)

+ (id)JSONObjectFromBundleResource:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:kJSONType];
    return [self JSONObjectFromFileAtPath:path];
}

+ (id)JSONObjectFromFileAtPath:(NSString *)path
{
    NSLog(@"path : %@", path);
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    return [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
}

@end

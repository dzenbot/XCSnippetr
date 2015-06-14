//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "XCSServiceAPIProtocol.h"

@interface XCSBaseAPI : NSObject <XCSServiceAPIProtocol>

/**
 A client singleton object.
 
 @returns The shared client.
 */
+ (instancetype)sharedClient;

/**
 Creates a POST request with path and params.
 
 @returns The shared client.
 */
- (void)post:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion;

@end
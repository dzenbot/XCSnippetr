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
 Performs a GET HTTP request with specific resource path and params.
 */
- (void)GET:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion;

/**
 Performs a POST HTTP request with specific resource path and params.
 */
- (void)POST:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion;

@end
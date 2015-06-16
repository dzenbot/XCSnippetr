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
#import "XCSService.h"

@interface XCSServiceAPIFactory : NSObject

/**
 
 */
+ (id<XCSServiceAPIProtocol>)APIClientForService:(XCSService)service;

/**
 
 */
+ (NSString *)tokenSourceUrlForService:(XCSService)service;

/**
 
 */
+ (void)reset;

@end

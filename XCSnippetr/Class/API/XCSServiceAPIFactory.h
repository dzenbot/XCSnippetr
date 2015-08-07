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

/**
 An abstract factory manager of XCSServiceAPIProtocol objects.
 */
@interface XCSServiceAPIFactory : NSObject

/**
 Returns a generic object conforming to XCSServiceAPIProtocol.
 
 @param service The service target.
 @return A generic object conforming to XCSServiceAPIProtocol.
 */
+ (id<XCSServiceAPIProtocol>)APIClientForService:(XCSService)service;

/**
 Returns an API token source URL for a specific service.
 
 @param service The service target.
 @return A string URL.
 */
+ (NSString *)tokenSourceUrlForService:(XCSService)service;

/**
 
 */
+ (void)reset;

@end

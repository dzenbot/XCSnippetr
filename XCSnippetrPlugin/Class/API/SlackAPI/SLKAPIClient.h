//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSBaseAPI.h"
#import "SLKAPIConstants.h"

@interface SLKAPIClient : XCSBaseAPI

/**
 Gets all the available rooms (channels, groups and IMs).
 If a previous request was pending, it is first cancelled before performing a new request.

 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If successfully, it returns a dictionary containing channels, groups and IMs separately. If unsuccessfully, it returns an Error.
 */
- (void)getAvailableRooms:(void (^)(NSDictionary *rooms, NSError *error))completion;

@end

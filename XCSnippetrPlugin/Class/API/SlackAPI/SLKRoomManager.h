//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "SLKRoom.h"

/**
 An abstraction object on top of the HTTP client.
 The usage of this object allows keeping cached data in an Xcode sessions.
 */
@interface SLKRoomManager : NSObject

/**
 Gets all the available rooms (channels, groups and IMs).
 If a previous request was pending, it is first cancelled before performing a new request.
 
 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If unsuccessfully, it returns an Error.
 */
+ (void)getAvailableRooms:(void (^)(NSError *error))completion;

/**
 YES if the current account has any cached room data.
 */
+ (BOOL)hasRooms;

/**
 Gets all the cached room's name for type, sorted alphabetically.
 
 @param type The room type (channel, group or im).
 @return An array of string names.
 */
+ (NSArray *)roomNamesForType:(SLKRoomType)type;

/**
 Fetches a room object by its id.
 
 @param tsid The room id.
 @return A cached SLKRoom object.
 */
+ (SLKRoom *)roomForId:(NSString *)tsid;

/**
 Fetches a room object by its name.
 
 @param name The room name.
 @return A cached SLKRoom object.
 */
+ (SLKRoom *)roomForName:(NSString *)name;

@end

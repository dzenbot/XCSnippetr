//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

@class SLKSnippet, SLKAccount;

@interface SLKAPIClient : NSObject

/**
 A client singleton object.
 
 @returns The shared client.
 */
+ (instancetype)sharedClient;

/**
 Authenticates using an accepted access token.
 If a previous request was pending, it is first cancelled before performing a new request.
 
 @param token The access token, retrieved from https://api.slack.com/web
 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If successfully, it returns a valid account object containing data about the team. If unsuccessfully, it returns an Error.
 */
- (void)authWithToken:(NSString *)token completion:(void (^)(SLKAccount *account, NSError *error))completion;

/**
 Gets all the available rooms (channels, groups and IMs).
 If a previous request was pending, it is first cancelled before performing a new request.

 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If successfully, it returns a dictionary containing channels, groups and IMs separately. If unsuccessfully, it returns an Error.
 */
- (void)getAvailableRooms:(void (^)(NSDictionary *rooms, NSError *error))completion;

/**
 Uploads a code snippet to Slack.
 If a previous request was pending, it is first cancelled before performing a new request.

 @param snippet The snippet object containing all the necessairy metadata.
 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If successfully, it returns a JSON response (either a File object or a Message object, depending of how the snippet was uploaded). If unsuccessfully, it returns an Error.
 */
- (void)uploadSnippet:(SLKSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion;

/**
 Cancels all HTTP requests, if any.
 */
- (void)cancelRequestsIfNeeded;

@end

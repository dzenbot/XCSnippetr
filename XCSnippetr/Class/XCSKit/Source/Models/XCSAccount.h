//
//  XCSKit
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>
#import "XCSService.h"

@interface XCSAccount : NSObject <NSCoding>

/** The account id, composed by the team and user ids. */
@property (nonatomic, readonly) NSString *accountId;
/** The session access token retrieved from the system Keychain. */
@property (nonatomic, copy) NSString *accessToken;
/** */
@property (nonatomic) XCSService service;
/** */
@property (nonatomic, readonly) NSString *serviceName;

/** The team unique id. */
@property (nonatomic, copy) NSString *teamId;
/** The team name. */
@property (nonatomic, copy) NSString *teamName;
/** The user unique id. */
@property (nonatomic, copy) NSString *userId;
/** The user name. */
@property (nonatomic, copy) NSString *userName;
/** Latest selected channel id for this account. */
@property (nonatomic, copy) NSString *channelId;

/** 
 Initializes an Account object from a response payloads.
 
 @param response A JSON data structure.
 @returns A new or updated Account object.
*/
- (instancetype)initWithResponse:(NSDictionary *)response service:(XCSService)service;

/**
 Returns the currently selected account.
 Returns nil if no account is yet registered.
 */
+ (instancetype)currentAccountForService:(XCSService)service;


/** Sets the account as current. */
- (void)setAsCurrentForService:(XCSService)service;

/** Sets the latest selected channel id. */
- (void)setChannelId:(NSString *)channelId;

/** Returns YES if the account is the current. */
- (BOOL)isCurrentForService:(XCSService)service;


/** Returns YES if no account is yet registered. */
+ (BOOL)needsForcedLoginForService:(XCSService)service;

/** Returns all available accounts. */
+ (NSArray *)allAccountsForService:(XCSService)service;

/** Convinience method to get all account's team names ordered alphabetically. */
+ (NSArray *)accountNamesForService:(XCSService)service;

/** Removes the account and clears the system Keychain. */
- (BOOL)clear;

/** Removes any accounts of the same service and clears the system Keychain */
+ (BOOL)clearForService:(XCSService)service;

/** Removes all accounts and clears the system Keychain. */
+ (BOOL)clearAll;

@end

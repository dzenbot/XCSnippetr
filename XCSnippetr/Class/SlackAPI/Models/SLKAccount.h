//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

@interface SLKAccount : NSObject <NSCoding>

/** The account id, composed by the team and user ids. */
@property (nonatomic, readonly) NSString *accountId;
/** The session access token retrieved from the system Keychain. */
@property (nonatomic, copy) NSString *accessToken;
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
- (instancetype)initWithResponse:(NSDictionary *)response;

/**
 Returns the currently selected account.
 Returns nil if no account is yet registered.
 */
+ (instancetype)currentAccount;

/**  Returns YES if no account is yet registered. */
+ (BOOL)forceLogin;

/** Returns all available accounts. */
+ (NSArray *)allAccounts;

/** Convinience method to get all account's team names ordered alphabetically. */
+ (NSArray *)teamNames;

/** Removes the account and clears the system Keychain. */
- (BOOL)clear;

/** Removes all accounts and clears the system Keychain. */
+ (BOOL)clearAll;

/** Sets the account as current. */
- (void)setAsCurrent;

/** Sets the latest selected channel id. */
- (void)setChannelId:(NSString *)channelId;

/** Returns YES if the account is the current. */
- (BOOL)isCurrent;

@end
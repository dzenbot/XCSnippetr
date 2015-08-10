//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "SLKRoomManager.h"
#import "SLKRoom.h"
#import "XCSSlackClient.h"

#import "XCSClientFactory.h"
#import "XCSAccount.h"
#import "XCSMacros.h"

#define kSharedManager [SLKRoomManager sharedManager]
#define kCurrentAccount [XCSAccount currentAccountForService:XCSServiceSlack]

@interface SLKRoomManager ()
@property (nonatomic, strong) NSMutableDictionary *rooms;
@end

@implementation SLKRoomManager

#pragma mark - Initialization

+ (instancetype)sharedManager
{
    static SLKRoomManager *_sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[SLKRoomManager alloc] init];
        _sharedManager.rooms = [NSMutableDictionary new];
    });
    return _sharedManager;
}


#pragma mark - Public Getters

+ (BOOL)hasRooms
{
    return [kSharedManager hasRoomsForAccount:kCurrentAccount];
}

+ (NSArray *)roomNamesForType:(SLKRoomType)type
{
    return [kSharedManager roomNamesForAccount:kCurrentAccount type:type];
}

+ (SLKRoom *)roomForId:(NSString *)tsid
{
    return [self roomForKey:kSlackAPIParamTsid andValue:tsid];
}

+ (SLKRoom *)roomForName:(NSString *)name
{
    return [self roomForKey:kSlackAPIParamName andValue:name];
}

+ (SLKRoom *)roomForKey:(id<NSCopying>)key andValue:(id<NSCopying>)value
{
    NSArray *rooms = [kSharedManager allRoomsForAccount:kCurrentAccount];
    return [[rooms filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", key, value]] firstObject];
}

+ (void)getAvailableRooms:(void (^)(NSError *error))completion
{
    XCSSlackClient *APIClient = [XCSClientFactory clientForService:XCSServiceSlack];
    
    [APIClient getAvailableRooms:^(NSDictionary *rooms, NSError *error) {
        
        if (!error) {
            [[SLKRoomManager sharedManager] setRooms:rooms forAccount:kCurrentAccount];
        }
        
        if (completion) {
            completion(error);
        }
    }];
}


#pragma mark - Private Getters

- (NSDictionary *)roomsListsForAccount:(XCSAccount *)account
{
    if ([self hasRoomsForAccount:account]) {
        return self.rooms[account.accountId];
    }
    return nil;
}

- (NSArray *)allRoomsForAccount:(XCSAccount *)account
{
    NSDictionary *lists = [self roomsListsForAccount:account];
    NSMutableArray *rooms = [NSMutableArray new];
    
    for (NSString *key in [lists allKeys]) {
        NSArray *array = lists[key];
        
        if (array.count > 0) {
            [rooms addObjectsFromArray:array];
        }
    }
    
    return rooms;
}

- (BOOL)hasRoomsForAccount:(XCSAccount *)account
{
    if (!account || ![[self.rooms allKeys] containsObject:account.accountId]) {
        return NO;
    }
    return YES;
}

- (NSArray *)roomsForAccount:(XCSAccount *)account type:(SLKRoomType)type
{
    if ([self hasRoomsForAccount:account]) {
        
        NSDictionary *list = [self roomsListsForAccount:account];
        NSString *key = SLKKeyFromRoomType(type);
        
        NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
        return [list[key] sortedArrayUsingDescriptors:@[nameSort]];
    }
    return nil;
}

- (NSArray *)roomNamesForAccount:(XCSAccount *)account type:(SLKRoomType)type
{
    NSArray *rooms = [self roomsForAccount:account type:type];
    return [rooms valueForKeyPath:@"@unionOfObjects.name"];
}


#pragma mark - Private Setters

- (void)setRooms:(NSDictionary *)rooms forAccount:(XCSAccount *)account
{
    if (!isNonEmptyString(account.accountId)) {
        return;
    }
    
    if (rooms.count > 0) {
        [self.rooms setObject:rooms forKey:account.accountId];
    }
    else if (self.rooms.count > 0) {
        [self.rooms removeObjectForKey:account.accountId];
    }
}

@end

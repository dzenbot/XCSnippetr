//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "SLKRoom.h"
#import "SLKAPIConstants.h"
#import "XCSMacros.h"

#import "NSObject+SmartDescription.h"

@implementation SLKRoom

+ (instancetype)roomWithId:(NSString *)tsid name:(NSString *)name
{
    if (!isNonEmptyString(tsid) || !isNonEmptyString(name)) {
        return nil;
    }
    
    SLKRoom *room = [[SLKRoom alloc] init];
    room.tsid = tsid;
    room.name = name;
    return room;
}

+ (NSDictionary *)roomsFromResponse:(NSDictionary *)response
{
    NSArray *channels = [self channelsFromResponse:response];
    NSArray *groups = [self groupsFromResponse:response];
    NSArray *ims = [self imsFromResponse:response];
    
    NSMutableDictionary *lists = [NSMutableDictionary dictionary];
    if (channels.count > 0) [lists setObject:channels forKey:SLKKeyFromRoomType(SLKRoomTypeChannel)];
    if (groups.count > 0) [lists setObject:groups forKey:SLKKeyFromRoomType(SLKRoomTypeGroup)];
    if (ims.count > 0) [lists setObject:ims forKey:SLKKeyFromRoomType(SLKRoomTypeIM)];
    
    return lists;
}

+ (NSArray *)channelsFromResponse:(NSDictionary *)response
{
    NSMutableArray *channels = [NSMutableArray new];
    NSString *key = SLKKeyFromRoomType(SLKRoomTypeChannel);
    
    for (NSDictionary *raw in response[key]) {
        if ([raw[kAPIParamIsChannel] boolValue] == NO || [raw[kAPIParamIsMember] boolValue] == NO || [raw[kAPIParamIsArchived] boolValue] == YES) {
            continue;
        }
        
        NSString *Id = raw[kAPIParamId];
        NSString *name = [NSString stringWithFormat:@"#%@", raw[kAPIParamName]];
        
        SLKRoom *room = [SLKRoom roomWithId:Id name:name];
        if (room) [channels addObject:room];
    }
    
    return channels;
}

+ (NSArray *)groupsFromResponse:(NSDictionary *)response
{
    NSMutableArray *groups = [NSMutableArray new];
    NSString *key = SLKKeyFromRoomType(SLKRoomTypeGroup);
    
    for (NSDictionary *raw in response[key]) {
        if ([raw[kAPIParamIsGroup] boolValue] == NO || [raw[kAPIParamIsOpen] boolValue] == NO || [raw[kAPIParamIsArchived] boolValue] == YES) {
            continue;
        }
        
        NSString *Id = raw[kAPIParamId];
        NSString *name = raw[kAPIParamName];
        
        SLKRoom *room = [SLKRoom roomWithId:Id name:name];
        if (room) [groups addObject:room];
    }
    
    return groups;
}

+ (NSArray *)imsFromResponse:(NSDictionary *)response
{
    NSMutableArray *ims = [NSMutableArray new];
    NSString *key = SLKKeyFromRoomType(SLKRoomTypeIM);
    
    for (NSDictionary *raw in response[key]) {
        if ([raw[kAPIParamIsIM] boolValue] == NO) {
            continue;
        }
        
        NSString *userId = raw[kAPIParamUser];
        
        if (!isNonEmptyString(userId)) {
            continue;
        }
        
        NSArray *users = response[kAPIParamUsers];
        NSDictionary *user = [[users filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K == %@", kAPIParamId, userId]] firstObject];
        
        NSString *Id = raw[kAPIParamId];
        
        NSString *username = [userId isEqualToString:kAPISlackbotId] ? kAPISlackbotName : user[kAPIParamName];
        NSString *name = [NSString stringWithFormat:@"@%@", username];
        
        SLKRoom *room = [SLKRoom roomWithId:Id name:[name capitalizedString]];
        if (room) [ims addObject:room];
    }
    
    return ims;
}

NSString *SLKKeyFromRoomType(SLKRoomType type)
{
    switch (type) {
        case SLKRoomTypeChannel:     return kAPIParamChannels;
        case SLKRoomTypeGroup:       return kAPIParamGroups;
        case SLKRoomTypeIM:          return kAPIParamIMs;
    }
}

- (NSString *)description
{
    return [self smartDescription];
}

@end

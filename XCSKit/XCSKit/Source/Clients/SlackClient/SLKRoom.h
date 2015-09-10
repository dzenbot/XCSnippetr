//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SLKRoomType) {
    SLKRoomTypeChannel,
    SLKRoomTypeGroup,
    SLKRoomTypeIM,
};

@interface SLKRoom : NSObject

@property (nonatomic, copy) NSString *tsid;
@property (nonatomic, copy) NSString *name;

+ (NSDictionary *)roomsFromResponse:(NSDictionary *)response;

NSString *SLKKeyFromRoomType(SLKRoomType type);

@end

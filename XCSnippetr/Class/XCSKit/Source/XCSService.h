//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

typedef NS_ENUM(NSUInteger, XCSService) {
    XCSServiceUndefined,
    XCSServiceSlack,
    XCSServiceGithub,
    XCSServiceXcode
};

static inline NSString *NSStringFromXCSService(XCSService service) {
    switch (service) {
        case XCSServiceSlack:       return @"Slack";
        case XCSServiceGithub:      return @"Github";
        default:                    return nil;
    }
}
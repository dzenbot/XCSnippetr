//
//  XCSBezelAlert.h
//  XCSnippetr-Builder
//
//  Created by pronebird on 8/6/15.
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XCSBezelAlert : NSObject

+ (void)showWithIcon:(NSImage *)icon message:(NSString *)message parentWindow:(NSWindow *)parentWindow duration:(NSTimeInterval)duration;

@end

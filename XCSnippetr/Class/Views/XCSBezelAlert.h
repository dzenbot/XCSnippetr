//
//  XCSBezelAlert.h
//  XCSnippetr-Builder
//
//  Created by pronebird on 8/6/15.
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/**
 Custom wrapper of the private DVTBezelAlertPanel class from the DVT framework,
 capable of presenting a toast view, with an image and duration for action feedback confirmation.
 */
@interface XCSBezelAlert : NSObject

/**
 Shows the alert with an icon image and message in the main IDE window, automatically dismissed after a default interval (3 seconds).
 
 @param icon An NSImage object.
 @param message An optional message string.
 */
+ (void)showWithIcon:(NSImage *)icon message:(NSString *)message;

/**
 Shows the alert with an icon image and message, automatically dismissed after an time interval.
 
 @param icon An NSImage object.
 @param message An optional message string.
 @param parentWindow The parent window to be presented to. If nil, the main IDE window will be used.
 @param duration A time interval to automatically dismiss the alert.
 */
+ (void)showWithIcon:(NSImage *)icon message:(NSString *)message parentWindow:(NSWindow *)parentWindow duration:(NSTimeInterval)duration;

@end

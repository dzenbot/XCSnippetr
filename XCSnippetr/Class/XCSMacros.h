//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

static NSString * const kXCSnippetrPlugin =         @"XCSnippetrPlugin";
static NSString * const kCFBundleName =             @"CFBundleName";
static NSString * const kCFBundleIdentifier =       @"CFBundleIdentifier";

#if !defined(isNonEmptyString)
    #define isNonEmptyString(string) \
        ((NSString *)string).length > 0
#endif

#if !defined(StringOrEmpty)
    #define StringOrEmpty(string) \
        isNonEmptyString(string) ? string : @""
#endif

/** Returns the XCSnippetr Bundle. */
inline static NSBundle *SLKBundle() {
    return [NSBundle bundleForClass:NSClassFromString(kXCSnippetrPlugin)];
}

/** Returns the XCSnippetr Bundle Name. */
inline static NSString *SLKBundleName() {
    return [SLKBundle() infoDictionary][kCFBundleName];
}

/** Returns the XCSnippetr Bundle Identifier. */
inline static NSString *SLKBundleIdentifier() {
    return [SLKBundle() infoDictionary][kCFBundleIdentifier];
}

/** YES if the bundle is the plugin's. */
inline static BOOL isSLKPlugin() {
    return [SLKBundleIdentifier() localizedCaseInsensitiveContainsString:@"plugin"];
}
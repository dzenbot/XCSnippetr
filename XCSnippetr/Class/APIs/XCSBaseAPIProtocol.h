//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

@protocol XCSBaseAPIProtocol <NSObject>
@required

/**
 
 */
- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params;

@end

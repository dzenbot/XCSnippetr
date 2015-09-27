//
//  XCSSnippetRepository.h
//  XCSnippetr
//
//  Created by Ignacio Romero on 9/26/15.
//  Copyright © 2015 DZN Labs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "XCSSnippet.h"

@interface XCSSnippetRepository : NSObject

/**
 
 */
+ (instancetype)defaultRepository;

/**
 
 */
- (void)saveSnippet:(XCSSnippet *)snippet completion:(void (^)(NSString *filePath, NSError *error))completion;

@end

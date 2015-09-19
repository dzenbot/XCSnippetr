//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import <Foundation/Foundation.h>

@class XCSAccount, XCSSnippet;

/**
 An abstract interface shared between generic API clients.
 */
@protocol XCSClientProtocol <NSObject>
@required

/**
 Returns a NSURLRequest object to be used internally in XCSBaseClient super class to perform any HTTP request.
 NOTE: Your XCSBaseClient subclass must override this method.
 
 @param path The request path url.
 @param params The request parameters.
 @return An NSMutableURLRequest object that provides the URL, cache policy, request type, body data or body stream, to be used internally.
 */
- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params;

/**
 An optional response key, to be used for fetching any response's error message.
 */
- (NSString *)errorResponseKey;

/**
 Authenticates using an accepted access token.
 If a previous request was pending, it is first cancelled before performing a new request.
 NOTE: Your XCSBaseClient subclass must override this method.
 
 @param token The access token, generated and available from the web client.
 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If successfully, it returns a valid account object containing data about the team. If unsuccessfully, it returns an Error.
 */
- (void)authWithToken:(NSString *)token completion:(void (^)(XCSAccount *account, NSError *error))completion;

/**
 Uploads a code snippet.
 If a previous request was pending, it is first cancelled before performing a new request.
 NOTE: Your XCSBaseClient subclass must override this method.

 @param snippet The snippet object containing all the necessairy metadata.
 @param completion A block object to be executed when the task finishes successfully or unsuccessfully. If successfully, it returns a JSON response (either a File object or a Message object, depending of how the snippet was uploaded). If unsuccessfully, it returns an Error.
 */
- (void)uploadSnippet:(XCSSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion;

/**
 Cancels all HTTP requests, if any.
 NOTE: Don't override this method.
 */
- (void)cancelRequestsIfNeeded;

@end

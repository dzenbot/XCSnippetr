//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "XCSBaseAPI.h"
#import "XCSMacros.h"

// HTTP Methods
static NSString * const kHTTPMethodGET =        @"GET";
static NSString * const kHTTPMethodPOST =       @"POST";
static NSString * const kHTTPMethodPUT =        @"PUT";

@interface XCSBaseAPI () <NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSURLSessionDataTask *URLSessionTask;
@end

@implementation XCSBaseAPI

#pragma mark - Request Methods

- (NSURLSession *)URLSession
{
    if (!_URLSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _URLSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _URLSession;
}

- (void)GET:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion
{
    [self performHTTPMethod:kHTTPMethodGET path:path params:params completion:completion];
}

- (void)POST:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion
{
    [self performHTTPMethod:kHTTPMethodPOST path:path params:params completion:completion];
}

- (void)performHTTPMethod:(NSString *)HTTPMethod path:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");
    
    [self cancelRequestsIfNeeded];
    
    NSMutableURLRequest *request = [self requestfForPath:path andParams:params];
    request.HTTPMethod = HTTPMethod;
    
    if (!request) {
        return;
    }
    
    NSLog(@"Client : %@", NSStringFromClass([self class]));
    NSLog(@"HTTPMethod : %@", HTTPMethod);
    NSLog(@"path : %@", path);
    NSLog(@"request url : %@", request.URL.absoluteString);
    NSLog(@"request HTTPBody : %@", request.HTTPBody);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul), ^{
        
        id completionHandler = ^void(NSData *data, NSURLResponse *response, NSError *error) {
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
            
            NSLog(@"response : %@", json);
                        
            if (!error && json[[self errorResponseKey]]) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: json[[self errorResponseKey]]};
                error = [NSError errorWithDomain:SLKBundleIdentifier() code:400 userInfo:userInfo];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(json, error);
                }
            });
        };
        
        self.URLSessionTask = [self.URLSession dataTaskWithRequest:request completionHandler:completionHandler];
        [self.URLSessionTask resume];
    });
}


#pragma mark - XCSServiceAPIProtocol

- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");
    return nil;
}

- (NSString *)errorResponseKey
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");
    return nil;
}

- (void)authWithToken:(NSString *)token completion:(void (^)(XCSAccount *account, NSError *error))completion
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");
}

- (void)uploadSnippet:(XCSSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");
}

- (void)cancelRequestsIfNeeded
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");

    if (_URLSessionTask) {
        [_URLSessionTask cancel];
        _URLSessionTask = nil;
    }
}

@end

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

static NSString * const kBaseAPIParamError =    @"error";

@interface XCSBaseAPI () <NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSURLSessionDataTask *URLSessionTask;
@end

@implementation XCSBaseAPI

#pragma mark - Initialization

+ (instancetype)sharedClient
{
    static id _sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[[self class] alloc] init];
    });
    return _sharedClient;
}


#pragma mark - Request Methods

- (NSURLSession *)URLSession
{
    if (!_URLSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _URLSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _URLSession;
}

- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");
    return nil;
}

- (void)post:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");

    [self cancelRequestsIfNeeded];
    
    NSMutableURLRequest *request = [self requestfForPath:path andParams:params];
    request.HTTPMethod = kHTTPMethodPOST;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        
        id completionHandler = ^void(NSData *data, NSURLResponse *response, NSError *error) {
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
            
            if (!error && json[kBaseAPIParamError]) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: json[kBaseAPIParamError]};
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

- (void)cancelRequestsIfNeeded
{
    NSAssert([self class] != [XCSBaseAPI class], @"Oops! You must subclass XCSBaseAPI to use this method.");

    if (_URLSessionTask) {
        [_URLSessionTask cancel];
        _URLSessionTask = nil;
    }
}

@end

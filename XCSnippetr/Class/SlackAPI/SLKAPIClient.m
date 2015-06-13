//
//  XCSnippetr
//  https://github.com/dzenbot/XCSnippetr
//
//  Created by Ignacio Romero Zurbuchen on 13/6/15
//  Copyright (c) 2015 DZN Labs. All rights reserved.
//  Licence: MIT-Licence
//

#import "SLKAPIClient.h"
#import "SLKAPIConstants.h"

#import "SLKAccount.h"
#import "SLKSnippet.h"
#import "SLKRoom.h"
#import "XCSMacros.h"

@interface SLKAPIClient () <NSURLSessionTaskDelegate>
@property (nonatomic, strong) NSURLSession *URLSession;
@property (nonatomic, strong) NSURLSessionDataTask *URLSessionTask;
@end

@implementation SLKAPIClient

#pragma mark - Initialization

+ (instancetype)sharedClient
{
    static SLKAPIClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[SLKAPIClient alloc] init];
    });
    return _sharedClient;
}


#pragma mark - Getters

- (NSURLSession *)URLSession
{
    if (!_URLSession) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _URLSession = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    }
    return _URLSession;
}


#pragma mark - API Methods

- (void)authWithToken:(NSString *)token completion:(void (^)(SLKAccount *account, NSError *error))completion
{
    if (!isNonEmptyString(token)) {
        return;
    }
    
    NSDictionary *params = @{kAPIParamToken: token};
    
    [self post:kAPIMethodAuthTest params:params completion:^(id response, NSError *error) {
        
        SLKAccount *account = nil;
        
        if (!error) {
            account = [[SLKAccount alloc] initWithResponse:response];
            account.accessToken = token;
        }
        
        if (completion) {
            completion(account, error);
        }
    }];
}

- (void)getAvailableRooms:(void (^)(NSDictionary *rooms, NSError *error))completion
{
    NSString *teamId = [SLKAccount currentAccount].teamId;
    
    if (!isNonEmptyString(teamId)) {
        return;
    }
    
    NSDictionary *params = @{kAPIParamTeam: teamId};
    
    [self post:kAPIMethodRTMStart params:params completion:^(id response, NSError *error) {
        
        if (completion) {
            completion([SLKRoom roomsFromResponse:response], error);
        }
    }];
}

- (void)uploadSnippet:(SLKSnippet *)snippet completion:(void (^)(NSDictionary *JSON, NSError *error))completion
{
    if (!snippet) {
        return;
    }
    
    NSDictionary *params = [snippet params];
    NSString *path = snippet.uploadAsFile ? kAPIMethodFilesUpload : kAPIMethodChatPostMessage;
    
    [self post:path params:params completion:completion];
}


#pragma mark - Session Helpers

- (NSMutableURLRequest *)requestfForPath:(NSString *)path andParams:(NSDictionary *)params
{
    NSMutableDictionary *parameters = [params mutableCopy];
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@%@", kAPIBaseUrl, path];
    
    NSString *accessToken = [SLKAccount currentAccount].accessToken;
    
    if (accessToken && ![path isEqualToString:kAPIMethodAuthTest]) {
        [parameters setObject:accessToken forKey:kAPIParamToken];
    }
    
    for (int i = 0; i < [parameters allKeys].count; i++) {
        
        if (i == 0) {
            [url appendString:@"?"];
        }
        else {
            [url appendString:@"&"];
        }
        
        NSString *key = [parameters allKeys][i];
        [url appendFormat:@"%@=%@", key, NSStringEscapedFrom(parameters[key])];
    }
    
    return [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
}

- (void)post:(NSString *)path params:(NSDictionary *)params completion:(void (^)(id response, NSError *error))completion
{
    [self cancelRequestsIfNeeded];
    
    NSMutableURLRequest *request = [self requestfForPath:path andParams:params];
    request.HTTPMethod = kHTTPMethodPOST;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul), ^{
        
        id completionHandler = ^void(NSData *data, NSURLResponse *response, NSError *error) {
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSUTF8StringEncoding error:nil];
            
            if (!error && json[kAPIParamError]) {
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey: json[kAPIParamError]};
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
    if (_URLSessionTask) {
        [_URLSessionTask cancel];
        _URLSessionTask = nil;
    }
}


#pragma mark - Helpers

// Base on Holtwick's answer in http://stackoverflow.com/a/1192589/590010
static inline NSString *NSStringEscapedFrom(NSString *v) {
    static CFStringRef charactersToBeEscaped = CFSTR("￼=,!$&'()*+;@?\r\n\"<>#\t :/");
    static CFStringEncoding encoding = kCFStringEncodingUTF8;
    return ((__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)[v mutableCopy], NULL, charactersToBeEscaped, encoding));
}

@end

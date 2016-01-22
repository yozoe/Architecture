//
//  InboxAppService.m
//  B1Anywhere
//
//  Created by Hu, Peng on 1/4/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import "InboxAppBaseService.h"
#import "InboxAppRequestManager.h"

NSString * const InboxAppBaseServiceName = @"InboxAppBaseService";
NSString * const InboxAppDemoServiceName = @"InboxAppDemoService";

@implementation InboxAppBaseService

#pragma mark - common methods

- (id)handleResult:(id)result
{
    // implemented by subclass...
    return result;
}

- (void)fetchWithParams:(NSDictionary *)params completionBlock:(void(^)(NSError *error, id result))callback
{
    self.params = params;
    
    NSMutableDictionary *requestParams = [params mutableCopy];
    NSString *endPoint = self.endPoint;
    NSString *itemID   = self.params[SAP_SERVICE_ID_FILTER];
    if (itemID) {
        [requestParams removeObjectForKey:SAP_SERVICE_ID_FILTER];
        endPoint = [endPoint stringByAppendingPathComponent:itemID];
    }
    
    AFHTTPSessionManager *manager = [InboxAppRequestManager defaultManager].requestManager;
    [manager GET:endPoint parameters:requestParams progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!responseObject) {
                return callback(nil, nil);
            }
            id result = [self handleResult:responseObject];
            
            if (callback) {
                callback(nil, result);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(error, nil);
            }
        });
    }];
}

- (void)postWithParams:(NSDictionary *)params completionBlock:(void(^)(NSError *error, id result))callback
{
    self.params = params;
    
    NSMutableDictionary *requestParams = [params mutableCopy];
    NSString *endPoint = self.endPoint;
    NSString *itemID   = self.params[SAP_SERVICE_ID_FILTER];
    if (itemID) {
        [requestParams removeObjectForKey:SAP_SERVICE_ID_FILTER];
        endPoint = [endPoint stringByAppendingPathComponent:itemID];
    }
    
    AFHTTPSessionManager *manager = [InboxAppRequestManager defaultManager].requestManager;
    [manager POST:endPoint parameters:requestParams progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!responseObject) {
                return callback(nil, nil);
            }
            
            id result = [self handleResult:responseObject];
            
            if (callback) {
                callback(nil, result);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(error, nil);
            }
        });
    }];
}

- (void)deleteWithParams:(NSDictionary *)params completionBlock:(void(^)(NSError *error, id result))callback
{
    self.params = params;
    
    NSMutableDictionary *requestParams = [params mutableCopy];
    NSString *endPoint = self.endPoint;
    NSString *itemID   = self.params[SAP_SERVICE_ID_FILTER];
    if (itemID) {
        [requestParams removeObjectForKey:SAP_SERVICE_ID_FILTER];
        endPoint = [endPoint stringByAppendingPathComponent:itemID];
    }
    AFHTTPSessionManager *manager = [InboxAppRequestManager defaultManager].requestManager;
    [manager DELETE:endPoint parameters:requestParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, responseObject);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // specical situation : delete method return nothing will cause this error
            if (error.code == 3840) {
                if (callback) {
                    callback(nil, nil);
                }
            } else {
                if (callback) {
                    callback(error, nil);
                }
            }
        });
    }];
}

- (void)putWithParams:(NSDictionary *)params completionBlock:(void(^)(NSError *error, id result))callback
{
    self.params = params;
    
    NSMutableDictionary *requestParams = [params mutableCopy];
    NSString *endPoint = self.endPoint;
    NSString *itemID   = self.params[SAP_SERVICE_ID_FILTER];
    if (itemID) {
        [requestParams removeObjectForKey:SAP_SERVICE_ID_FILTER];
        endPoint = [endPoint stringByAppendingPathComponent:itemID];
    }
    
    AFHTTPSessionManager *manager = [InboxAppRequestManager defaultManager].requestManager;

    [manager PUT:endPoint parameters:requestParams success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(nil, responseObject);
            }
        });
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // specical situation : delete method return nothing will cause this error
            if (error.code == 3840) {
                if (callback) {
                    callback(nil, nil);
                }
            } else {
                if (callback) {
                    callback(error, nil);
                }
            }
        });
    }];
}

@end

@implementation InboxAppServiceFactory

+ (instancetype)factory
{
    CREATE_SINGLETON_INSTANCE([[InboxAppServiceFactory alloc] init]);
}

- (InboxAppBaseService *)serviceWithName:(NSString *)serviceName
{
    Class serviceCls = NSClassFromString(serviceName);
    if (!serviceCls) {
        return nil;
    }
    InboxAppBaseService *service = [[serviceCls alloc] init];
    return service;
}
@end

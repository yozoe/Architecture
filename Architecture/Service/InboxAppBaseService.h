//
//  InboxAppService.h
//  B1Anywhere
//
//  Created by Hu, Peng on 1/4/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HPCommonMacro.h"

#define SAP_SERVICE_ID_FILTER  @"SAP_SERVICE_ID_FILTER"

extern NSString * const InboxAppBaseServiceName;
extern NSString * const InboxAppDemoServiceName;

@interface InboxAppBaseService : NSObject

@property (nonatomic, strong) NSString *endPoint;
@property (nonatomic, strong) NSDictionary *params;

- (id)handleResult:(id)result;

// Get
- (void)fetchWithParams:(NSDictionary *)params
        completionBlock:(void(^)(NSError *error, id result))callback;

// Post
- (void)postWithParams:(NSDictionary *)params
       completionBlock:(void(^)(NSError *error, id result))callback;

// Delete
- (void)deleteWithParams:(NSDictionary *)params
         completionBlock:(void(^)(NSError *error, id result))callback;

// Put
- (void)putWithParams:(NSDictionary *)params
      completionBlock:(void(^)(NSError *error, id result))callback;

@end

@interface InboxAppServiceFactory : NSObject

+ (instancetype)factory;

- (InboxAppBaseService *)serviceWithName:(NSString *)serviceName;

@end


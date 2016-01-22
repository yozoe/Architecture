//
//  InboxAppRequestManager.h
//  B1Anywhere
//
//  Created by Hu, Peng on 1/5/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AFNetworking/AFNetworking.h>


@interface InboxAppRequestManager : NSObject

+ (instancetype)defaultManager;

@property (nonatomic, strong) AFHTTPSessionManager *requestManager;

@end

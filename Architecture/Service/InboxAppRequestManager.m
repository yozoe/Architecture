//
//  InboxAppRequestManager.m
//  B1Anywhere
//
//  Created by Hu, Peng on 1/5/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import "InboxAppRequestManager.h"
#import "NSString+TCEExt.h"
#import "InboxAppTask.h"
#import "HPCommonMacro.h"

@interface InboxAppRequestManager ()
@end

@implementation InboxAppRequestManager

+ (instancetype)defaultManager
{
    CREATE_SINGLETON_INSTANCE([[InboxAppRequestManager alloc] init]);
}

- (instancetype)init
{
    if (self = [super init]) {

        _requestManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://fakePeopleInfoAddress.com"]];
        // add ur settings
    }
    return self;
}

@end

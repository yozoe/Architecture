//
//  People.m
//  Architecture
//
//  Created by Hu, Peng on 1/22/16.
//  Copyright © 2016 Hu, Peng. All rights reserved.
//

#import "People.h"

#import "InboxAppTask.h"

@implementation People

// Insert code here to add functionality to your managed object subclass

@end

@implementation People (Service)

+ (NSArray *)highSecureKeys
{
    return @[@"identifier, address"];
}

+ (NSDictionary *)keyMap
{
    return @ {@"id"   : @"identifier",
              @"age"  : @"age",
              @"addr" : @"address",
              @"name" : @"name",
              @"gender" : @"sex"};
}

+ (NSArray *)requiredKeys
{
    return @[@"id"];
}


+ (void)fetchAllWithCompletionBlock:(void(^)(BOOL success, id result))block
{
    InboxAppTask *task = [[InboxAppTask alloc] init];
    task.service = InboxAppDemoServiceName;
    task.method  = InboxAppTaskMethodTypeGet;
//    task.params  = @{};
    [task execute:^(InboxAppTask *change) {
       
        if (block) {
            block(change.state == InboxAppTaskStateFinished, change.result);
        }
    }];
}
@end

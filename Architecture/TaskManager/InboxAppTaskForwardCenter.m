//
//  InboxAppTaskForwardCenter.m
//  B1Anywhere
//
//  Created by Hu, Peng on 1/8/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import "InboxAppTaskForwardCenter.h"
#import "HPCommonMacro.h"
#import "InboxAppTask.h"

@interface InboxAppTaskForwardCenter ()
{
    NSMutableDictionary *_blockMap;
}
@end

@implementation InboxAppTaskForwardCenter

+ (instancetype)defaultCenter
{
    CREATE_SINGLETON_INSTANCE([[InboxAppTaskForwardCenter alloc] init]);
}

- (void)addObserverForTask:(nonnull InboxAppTask *)task usingBlock:(nonnull InboxAppTaskForwardCenterBlock)block
{
    if (!_blockMap) {
        _blockMap = [[NSMutableDictionary alloc] init];
    }
    [_blockMap setObject:block forKey:task.identifier];
}

- (void)handleTask:(nonnull InboxAppTask *)task
{
    InboxAppTaskForwardCenterBlock block = [_blockMap objectForKey:task.identifier];
    block(task);
    [_blockMap removeObjectForKey:task.identifier];
}

@end

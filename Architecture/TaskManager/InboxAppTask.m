//
//  Task.m
//  B1Anywhere
//
//  Created by Hu, Peng on 12/18/15.
//  Copyright © 2015 SAP. All rights reserved.
//

#import "InboxAppTask.h"
#import "InboxAppTaskForwardCenter.h"
#import "InboxAppQueueManager.h"
#import "NSString+TCEExt.h"

@implementation InboxAppTask

- (BOOL)isEqual:(id)object
{
    InboxAppTask *anotherTask = object;
    
    return [anotherTask.service isEqualToString:self.service] &&
                     [anotherTask.params isEqual:self.params] &&
       [anotherTask.dependecncies isEqual:self.dependecncies] &&
                            anotherTask.method == self.method;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.service       = [aDecoder decodeObjectForKey:@"service"];
        self.params        = [aDecoder decodeObjectForKey:@"params"];
        self.dependecncies = [aDecoder decodeObjectForKey:@"dependecncies"];
        self.isBarrier     = [[aDecoder decodeObjectForKey:@"isBarrier"] boolValue];
        self.state         = InboxAppTaskStateWaiting;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.service       forKey:@"service"];
    [aCoder encodeObject:self.params        forKey:@"params"];
    [aCoder encodeObject:self.dependecncies forKey:@"dependecncies"];
    [aCoder encodeObject:@(self.isBarrier)  forKey:@"isBarrier"];
}

- (void)execute:(InboxAppTaskCallBack)block
{
    [[InboxAppTaskForwardCenter defaultCenter] addObserverForTask:self usingBlock:^(InboxAppTask * _Nonnull change) {
        if (block) {
            block(change);
        }
    }];
    [[InboxAppQueueManager defaultManager] queueTask:self];
}

- (NSString *)identifier
{
    return self.description.toHex;
}

- (void)dealloc
{
    NSLog(@"release task: %@", self.service);
}

+ (InboxAppTask *)emptyBarrierTask
{
    InboxAppTask *task = [[InboxAppTask alloc] init];
    task.isBarrier = TRUE;
    return task;
}

@end

//
//  InboxAppQueueManager.m
//  B1Anywhere
//
//  Created by Hu, Peng on 12/18/15.
//  Copyright © 2015 SAP. All rights reserved.
//

#import "InboxAppQueueManager.h"
#import "InboxAppTaskForwardCenter.h"
#import "InboxAppRequestManager.h"
#import "HPCommonMacro.h"
#import "InboxAppTask.h"

@interface InboxAppQueueManager ()
{
    NSMutableArray *_taskPool;
    
    dispatch_queue_t _queue;
    dispatch_semaphore_t _semaphore;
    BOOL _isRunning;
    
    unsigned int _maxThreadCount;
}
@end

@implementation InboxAppQueueManager

+ (instancetype)defaultManager
{
    CREATE_SINGLETON_INSTANCE([[InboxAppQueueManager alloc] init]);
}

- (instancetype)init
{
    if (self = [super init]) {
        _maxThreadCount = 3;
        _queue = dispatch_queue_create("task queue", DISPATCH_QUEUE_SERIAL);
        _semaphore = dispatch_semaphore_create(_maxThreadCount);
        _taskPool = @[].mutableCopy;
    }
    return self;
}

- (NSArray*)taskQueue
{
    return [_taskPool copy];
}

- (void)queueTask:(InboxAppTask *)task;
{
    if ([_taskPool containsObject:task]) {
        return;
    }
    [_taskPool addObject:task];
    [self startRunning];
}

- (void)dequeueTask:(InboxAppTask *)task
{
    [_taskPool removeObject:task];
}

- (InboxAppTask *)getNextTask
{
    if (!_taskPool || _taskPool.count == 0) {
        return nil;
    }
    InboxAppTask *task = _taskPool[0];
    [_taskPool removeObjectAtIndex:0];
    return task;
}

- (void)startRunning
{
    if (_isRunning) {
        return;
    }

    _isRunning = TRUE;
    
    dispatch_async(_queue, ^{
        // offer enough time to queue task
        sleep(1);
        
        while (1) {
            InboxAppTask *task = [self getNextTask];
            if (!task) {
                _isRunning = FALSE;
                break;
            }
            [self lock:task.isBarrier];
            [self handleTask:task withCompletionBlock:^(NSError *error, id result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    task.state = error ? InboxAppTaskStateFail : InboxAppTaskStateFinished;
                    task.result = result;
                    [[InboxAppTaskForwardCenter defaultCenter] handleTask:task];
                    [self unlock:task.isBarrier];
                });
            }];
        }
    });
}

- (void)lock:(BOOL)lockAll
{
    for (int i = 0; i < (lockAll ? _maxThreadCount : 1); i++) {
        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
    }
}

- (void)unlock:(BOOL)unlockAll
{
    for (int i = 0; i < (unlockAll ? _maxThreadCount : 1); i++) {
        dispatch_semaphore_signal(_semaphore);
    }
}

- (void)handleTask:(InboxAppTask *)task withCompletionBlock:(void(^)(NSError *error, id result))block
{
    task.state = InboxAppTaskStateInProgress;
    
    // empty task, just used for barrier task
    if (!task.service) {
        if (block) {
            block(nil, nil);
        }
        return;
    }
    
    InboxAppBaseService *service = [[InboxAppServiceFactory factory] serviceWithName:task.service];
    if (task.method == InboxAppTaskMethodTypeGet) {
        [service fetchWithParams:task.params completionBlock:^(NSError *error, id result) {
            if (block) {
                block(error, result);
            }
        }];
    } else if (task.method == InboxAppTaskMethodTypePost) {
        [service postWithParams:task.params completionBlock:^(NSError *error, id result) {
            if (block) {
                block(error, result);
            }
        }];
        
    } else if (task.method == InboxAppTaskMethodTypeDelete) {
        [service deleteWithParams:task.params completionBlock:^(NSError *error, id result) {
            if (block) {
                block(error, result);
            }
        }];
    } else if (task.method == InboxAppTaskMethodTypePut) {
        [service putWithParams:task.params completionBlock:^(NSError *error, id result) {
            if (block) {
                block(error, result);
            }
        }];
    }
}

@end

//
//  Task.h
//  B1Anywhere
//
//  Created by Hu, Peng on 12/18/15.
//  Copyright © 2015 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InboxAppBaseService.h"

@class InboxAppTask;

typedef void(^InboxAppTaskCallBack)(InboxAppTask *change);

typedef enum : NSUInteger {
    InboxAppTaskStateWaiting,
    InboxAppTaskStateInProgress,
    InboxAppTaskStateFinished,
    InboxAppTaskStateFail
} InboxAppTaskState;

typedef enum {
    InboxAppTaskMethodTypeGet,
    InboxAppTaskMethodTypePost,
    InboxAppTaskMethodTypeDelete,
    InboxAppTaskMethodTypePut
} InboxAppTaskMethodType;


@interface InboxAppTask : NSObject<NSCoding>

@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSDictionary *params;
@property (nonatomic, assign) InboxAppTaskMethodType method;

// type of dependecncies' elements is Task
// if a task has dependecncies, task manager will handle it's dependecncies first
@property (nonatomic, copy) NSArray *dependecncies;

@property (nonatomic, assign) BOOL isBarrier;

// response data from request
@property (nonatomic, strong) id result;

@property (nonatomic, readonly) NSString *identifier;

@property (nonatomic, assign) InboxAppTaskState state;

- (void)execute:(InboxAppTaskCallBack)block;

+ (InboxAppTask *)emptyBarrierTask;

@end

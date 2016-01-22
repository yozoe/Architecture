//
//  InboxAppQueueManager.h
//  B1Anywhere
//
//  Created by Hu, Peng on 12/18/15.
//  Copyright © 2015 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>


@class InboxAppTask;

@interface InboxAppQueueManager : NSObject

+ (instancetype)defaultManager;

- (void)queueTask:(InboxAppTask *)task;
- (void)dequeueTask:(InboxAppTask *)task;

@end

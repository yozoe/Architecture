//
//  InboxAppTaskForwardCenter.h
//  B1Anywhere
//
//  Created by Hu, Peng on 1/8/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class InboxAppTask;

typedef void(^InboxAppTaskForwardCenterBlock)(InboxAppTask * _Nonnull);

@interface InboxAppTaskForwardCenter : NSObject

+ (nonnull instancetype)defaultCenter;

- (void)addObserverForTask:(nonnull InboxAppTask *)task
                usingBlock:(nonnull InboxAppTaskForwardCenterBlock)block;

- (void)handleTask:(nonnull InboxAppTask *)task;

@end

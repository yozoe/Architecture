//
//  InboxAppDemoService.m
//  Architecture
//
//  Created by Hu, Peng on 1/22/16.
//  Copyright © 2016 Hu, Peng. All rights reserved.
//

#import "InboxAppDemoService.h"
#import "People.h"
@implementation InboxAppDemoService

- (NSString *)endPoint
{
    return @"peopleList";
}

- (id)handleResult:(id)result
{
    return [People instancesFromArray:result];
}
@end

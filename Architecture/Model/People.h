//
//  People.h
//  Architecture
//
//  Created by Hu, Peng on 1/22/16.
//  Copyright © 2016 Hu, Peng. All rights reserved.
//

#import "SAPBaseCoreDataObject.h"

NS_ASSUME_NONNULL_BEGIN

@interface People : SAPBaseCoreDataObject

// Insert code here to declare functionality of your managed object subclass

@end

@interface People (Service)

+ (void)fetchAllWithCompletionBlock:(void(^)(BOOL success, id result))block;

@end

NS_ASSUME_NONNULL_END

#import "People+CoreDataProperties.h"

//
//  SAPBaseCoreDataObject.h
//  B1Anywhere
//
//  Created by Hu, Peng on 1/12/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import <CoreData/CoreData.h>
#import <MagicalRecord/MagicalRecord.h>

@interface SAPBaseCoreDataObject : NSManagedObject

// lazy save APIs
+ (void)save;

- (void)deleteAndSave;

// encryption layer APIs
+ (NSArray *)highSecureKeys;

// convert related APIs

// key is key name of dictionary.
// value is property name
+ (NSDictionary *)keyMap;

// if dictionary doesn't contain all of the values in requiredKeys
// means this dictionary is invalid.
// when create instance, requiredKeys also will be used as the unique identifier of instance
// elements of requiredKeys are property names of dictionary,
// not the names of instance's properties!
+ (NSArray *)requiredKeys;

// when we want to use another value as the second option when one value is nil,
// set this map.
// key is the original dictionary key
// value is the candidate dictionary key
+ (NSDictionary *)candidateMap;

@property (nonatomic, strong, readonly) NSDictionary *toDictionary;

+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary;
+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary
                             inContext:(NSManagedObjectContext *)context;

+ (NSArray *)instancesFromArray:(NSArray *)array;
+ (NSArray *)instancesFromArray:(NSArray *)array
                      inContext:(NSManagedObjectContext *)context;

// if you nedd to do some special operation for instance, overwirte this method
+ (instancetype)extraOperationFor:(SAPBaseCoreDataObject *)instance
                   withDictionary:(NSDictionary *)dictionary
                        inContext:(NSManagedObjectContext *)context;

@end

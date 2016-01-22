//
//  SAPBaseCoreDataObject.m
//  B1Anywhere
//
//  Created by Hu, Peng on 1/12/16.
//  Copyright © 2016 SAP. All rights reserved.
//

#import "SAPBaseCoreDataObject.h"
#import "HPCommonMacro.h"
#import <objc/runtime.h>

@implementation SAPBaseCoreDataObject

#pragma mark - lazy save

+ (void)save
{
#ifndef LAZYSAVE
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
#endif
}

- (void)deleteAndSave
{
    [self MR_deleteEntity];
#ifndef LAZYSAVE
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
#endif
}

#pragma mark - encryption and decryption

const void * injectedPropertiesKey;

- (NSDictionary *)injectedProperties
{
    return objc_getAssociatedObject(self, &injectedPropertiesKey);
}

- (void)setInjectedProperties:(NSDictionary *)injectedProperties
{
    if (!injectedProperties) {
        return;
    }
    objc_setAssociatedObject(self, &injectedPropertiesKey, [injectedProperties copy], OBJC_ASSOCIATION_RETAIN);
}

+ (NSArray *)highSecureKeys
{
    return @[];
}

+ (void)initialize
{
    if ([self highSecureKeys].count > 0) {
        // Demo
        [self registerEncryptionKeys:[self highSecureKeys]];
    }
}

+ (void)registerEncryptionKeys:(NSArray *)map
{
    Class clazz = [self class];
    
    for (id property in map) {
        
        NSString *plainValue = [[@"decrypted" stringByAppendingString:[[property substringToIndex:1] uppercaseString]] stringByAppendingString:[property substringFromIndex:1]];
        NSString *originValue = [@"cached" stringByAppendingString:property];
        
        // add set method
        NSString *setSelectorName = [[[@"set" stringByAppendingString:[[property substringToIndex:1] uppercaseString]] stringByAppendingString:[property substringFromIndex:1]] stringByAppendingString:@":"];
        IMP setImp = imp_implementationWithBlock(^(id self, typeof(property) value) {
            [self willChangeValueForKey:property];
            [self setPrimitiveValue:[SAPBaseCoreDataObject encrypt:value] forKey:property];
            [self didChangeValueForKey:property];
        });
        // add get method
        class_addMethod(clazz, NSSelectorFromString(setSelectorName), setImp, "v@:@");
        
        IMP getImp = imp_implementationWithBlock(^(id self) {
            
            [self willAccessValueForKey:property];
            id value = [self primitiveValueForKey:property];
            [self didAccessValueForKey:property];
            
            NSMutableDictionary *injectedProperties = [[self injectedProperties] mutableCopy];
            
            if (![injectedProperties[originValue] isEqual:value]) {
                
                if (!injectedProperties) {
                    injectedProperties = [NSMutableDictionary dictionary];
                }
                [injectedProperties setObject:value forKey:originValue];
                [injectedProperties setObject:[SAPBaseCoreDataObject decrypt:value] forKey:plainValue];
                
                [self setInjectedProperties:injectedProperties];
            } else {
                NSLog(@"Use Cache...");
            }
            return [[self injectedProperties] objectForKey:plainValue];
        });
        
        class_addMethod(clazz, NSSelectorFromString(property), getImp, "@@:");
    }
}

+ (NSString *)encrypt:(NSString *)value
{
    // add your encryotion logic here
    return value;
}

+ (NSString *)decrypt:(NSString *)value
{
    // add your decryption logic here
    return value;
}

#pragma mark - convert related APIs

+ (NSDictionary *)keyMap
{
    return @{};
}

+ (NSDictionary *)candidateMap
{
    return @{};
}

+ (NSArray *)requiredKeys
{
    return @[];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    unsigned int count = 0;
    Class clazz = [self class];
    objc_property_t *properties = class_copyPropertyList(clazz, &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t p = *(properties + i);
        NSString *key = [NSString stringWithUTF8String:property_getName(p)];
        id value = [self primitiveValueForKey:key];
        if (!value) {
            continue;
        }
        
        if ([[[self class] highSecureKeys] containsObject:key]) {
            value = [SAPBaseCoreDataObject decrypt:value];
        }
        NSString *realKey = [clazz keyMap][key] ? [clazz keyMap][key] : key;
        [dictionary setObject:value forKey:realKey];
    }
    return dictionary;
}

+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary
{
    SAPBaseCoreDataObject *instance = [self instanceFromDictionary:dictionary inContext:nil];
    [self save];
    return instance;
}

+ (instancetype)instanceFromDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context
{
    NSString *predicateFormat = @"";
    NSMutableArray *args = @[].mutableCopy;
    
    for (NSString *key in [self requiredKeys]) {
        if (!NULL_VALIDATE(dictionary[key])) {
            return nil;
        }
        
        NSString *realKey = self.keyMap[key];
        
        // shouldn't happen
        if (!realKey) {
            continue;
        }
        
        if (predicateFormat.length > 0) {
            predicateFormat = [predicateFormat stringByAppendingFormat:@" and "];
        }
        id value   = NULL_VALIDATE(dictionary[key]);
        
        predicateFormat = [predicateFormat stringByAppendingString:realKey];
        predicateFormat = [predicateFormat stringByAppendingString:@"="];
        predicateFormat = [predicateFormat stringByAppendingString:@"%@"];
        [args addObject:value];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:args];
    
    SAPBaseCoreDataObject *instance = context ? [[self class] MR_findFirstWithPredicate:predicate inContext:context] : [[self class] MR_findFirstWithPredicate:predicate];

    if (!instance) {
        instance = context ? [[self class] MR_createEntityInContext:context] : [[self class] MR_createEntity];
    }
    
    for (NSString *key in dictionary.allKeys) {
        NSString *propertyName = [self keyMap][key];
        if (!propertyName) {
            continue;
        }
        
        NSString *value = NULL_VALIDATE(dictionary[key]);
        if (!value && self.candidateMap && [self candidateMap][key]) {
            value = NULL_VALIDATE(dictionary[[self candidateMap][key]]);
        }
        
        if ([[self highSecureKeys] containsObject:propertyName]) {
            [instance willChangeValueForKey:propertyName];
            [instance setPrimitiveValue:[SAPBaseCoreDataObject encrypt:value] forKey:propertyName];
            [instance didChangeValueForKey:propertyName];
        } else {
            [instance setPrimitiveValue:value forKey:propertyName];
        }
        
    }
    instance = [self extraOperationFor:instance withDictionary:dictionary inContext:context];
    return instance;
}

+ (NSArray *)instancesFromArray:(NSArray *)array
{
    NSArray *instances = [self instancesFromArray:array inContext:nil];
    [self save];
    return instances;
}

+ (NSArray *)instancesFromArray:(NSArray *)array inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *instances = [[NSMutableArray alloc] initWithCapacity:[array count]];
    
    for (NSDictionary *dictionary in array) {
        
        BOOL invalidData = FALSE;
        
        NSString *predicateFormat = @"";
        NSMutableArray *args = @[].mutableCopy;
        
        for (NSString *key in [self requiredKeys]) {
            
            if (!NULL_VALIDATE(dictionary[key])) {
                invalidData = TRUE;
            }
            
            NSString *realKey = self.keyMap[key];
            
            // shouldn't happen
            if (!realKey) {
                invalidData = TRUE;
            }
    
            if (predicateFormat.length > 0) {
                predicateFormat = [predicateFormat stringByAppendingFormat:@" and "];
            }
            id value   = NULL_VALIDATE(dictionary[key]);
            
            predicateFormat = [predicateFormat stringByAppendingString:realKey];
            predicateFormat = [predicateFormat stringByAppendingString:@"="];
            predicateFormat = [predicateFormat stringByAppendingString:@"%@"];
            [args addObject:value];
        }
        
        if (invalidData) {
            continue;
        }
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:args];
        
        SAPBaseCoreDataObject *instance = context ? [[self class] MR_findFirstWithPredicate:predicate inContext:context] : [[self class] MR_findFirstWithPredicate:predicate];
        
        if (!instance) {
            instance = context ? [[self class] MR_createEntityInContext:context] : [[self class] MR_createEntity];
        }
        
        for (NSString *key in dictionary.allKeys) {
            NSString *propertyName = [self keyMap][key];
            if (!propertyName) {
                continue;
            }
            NSString *value = NULL_VALIDATE(dictionary[key]);
            if (!value && self.candidateMap && [self candidateMap][key]) {
                value = NULL_VALIDATE(dictionary[[self candidateMap][key]]);
            }
            
            if ([[self highSecureKeys] containsObject:propertyName]) {
                [instance willChangeValueForKey:propertyName];
                [instance setPrimitiveValue:[SAPBaseCoreDataObject encrypt:value] forKey:propertyName];
                [instance didChangeValueForKey:propertyName];
            } else {
                [instance setPrimitiveValue:value forKey:propertyName];
            }
        }
        instance = [self extraOperationFor:instance withDictionary:dictionary inContext:context];
        [instances addObject:instance];
    }
    return [instances copy];
}

+ (instancetype)extraOperationFor:(SAPBaseCoreDataObject *)instance withDictionary:(NSDictionary *)dictionary inContext:(NSManagedObjectContext *)context
{
    return instance;
}
@end

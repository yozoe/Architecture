//
//  NSString+TCEExt.m
//  EmailDemoOC
//
//  Created by Hu, Peng on 11/5/15.
//  Copyright © 2015 Hu, Peng. All rights reserved.
//

#import "NSString+TCEExt.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (TCEExt)

- (NSString *)validate
{
    // check null
    if ([self isEqual:[NSNull null]]) {
        return nil;
    }
    return self;
}

@end

@implementation NSString (URLHelper)

- (NSDictionary *)params
{
    NSString *queryStr = [self substringFromIndex:([self rangeOfString:@"?"].location + 1)];
    if ([self rangeOfString:@"#"].location != NSNotFound) {
        queryStr = [queryStr substringToIndex:[queryStr rangeOfString:@"#"].location];
    }
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    for (NSString *paramStr in [queryStr componentsSeparatedByString:@"&"]) {
        NSArray *paramInfo = [paramStr componentsSeparatedByString:@"="];
        if (paramInfo.count < 2) {
            continue;
        }
        [params setObject:paramInfo[1] forKey:paramInfo[0]];
    }
    
    return [params copy];
}

@end

@implementation NSString (EmailUtil)

- (BOOL)isEmailAddress
{
    
    NSError *error;
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:@"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$"
                                                                    options:(NSRegularExpressionAnchorsMatchLines |
                                                                             NSRegularExpressionCaseInsensitive)
                                                                      error:&error];
    NSArray<NSTextCheckingResult *>* results = [reg matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    return results.count > 0;
}

- (NSString *)nameFromEmail
{
    return [self substringToIndex:[self rangeOfString:@"@"].location];
}
@end

@implementation NSString (RegUtil)

- (NSRange)match:(NSString *)pattern
{
    NSError *error;
    NSRegularExpression *reg = [[NSRegularExpression alloc] initWithPattern:pattern
                                                                    options:(NSRegularExpressionAnchorsMatchLines |
                                                                             NSRegularExpressionCaseInsensitive)
                                                                      error:&error];
    
    NSArray<NSTextCheckingResult *>* results = [reg matchesInString:self options:NSMatchingReportCompletion range:NSMakeRange(0, self.length)];
    
    if (results.count >0) {
        NSTextCheckingResult *result = results[0];
        return result.range;
    } else {
        return NSMakeRange(0, 0);
    }
}

@end

@implementation NSString (Digest)

- (unsigned int)UTF8Length
{
    return (unsigned int) [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString*)MD5
{
    unsigned int outputLength = CC_MD5_DIGEST_LENGTH;
    unsigned char output[outputLength];
    
    CC_MD5(self.UTF8String, [self UTF8Length], output);
    return [self toHexString:output length:outputLength];;
}

- (NSString*)toHexString:(unsigned char *)data length:(unsigned int)length
{
    NSMutableString* hash = [NSMutableString stringWithCapacity:length * 2];
    for (unsigned int i = 0; i < length; i++) {
        [hash appendFormat:@"%02x", data[i]];
        data[i] = 0;
    }
    return hash;
}

- (NSString *)toHex
{
    const char *data = [[self copy] cStringUsingEncoding:NSASCIIStringEncoding];
    
    return [self toHexString:(unsigned char *)data length:self.UTF8Length];
}
@end

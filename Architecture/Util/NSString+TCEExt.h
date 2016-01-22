//
//  NSString+TCEExt.h
//  EmailDemoOC
//
//  Created by Hu, Peng on 11/5/15.
//  Copyright © 2015 Hu, Peng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TCEExt)

@end

@interface NSString (URLUtil)

- (NSDictionary *)params;

@end

@interface NSString (EmailUtil)

- (BOOL)isEmailAddress;
- (NSString *)nameFromEmail;

@end

@interface NSString (RegUtil)

- (NSRange)match:(NSString *)pattern;

@end

@interface NSString (Digest)

- (NSString *)MD5;
- (NSString *)toHex;

@end
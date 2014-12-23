//
//  NVJSON.h
//
//  Created by Igor Shavlovsky on 20.10.11.
//  Copyright 2011 neoviso. All rights reserved.
//

#import <Foundation/Foundation.h>

//just basic functions for data extraction from dictionary

@interface NSDictionary (JSONBasedObject)

- (NSInteger)jsonIntegerForKey:(NSString*)key;
- (long long)jsonLongForKey:(NSString*)key;
- (CGFloat)jsonFloatForKey:(NSString*)key;
- (double)jsonDoubleForKey:(NSString*)key;
- (BOOL)jsonBoolForKey:(NSString*)key;
- (BOOL)jsonPhpBoolForKey:(NSString*)key;
- (NSString*)jsonStringForKey:(NSString*)key;
- (NSArray*)jsonArrayForKey:(NSString*)key;
- (NSDate*)jsonDateForKey:(NSString*)key format:(NSString*)format;
- (NSDate*)jsonDateForKey:(NSString*)key formatter:(NSDateFormatter*)formater;

@end

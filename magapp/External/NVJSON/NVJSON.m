//
//  JSONBasedObject.m
//
//  Created by Igor Shavlovsky on 20.10.11.
//  Copyright 2011 neoviso. All rights reserved.
//

#import "NVJSON.h"


@implementation NSDictionary (NVJSON)

- (NSInteger)jsonIntegerForKey:(NSString*)key {
    NSNumber *object = [self objectForKey:key];
    if ([object respondsToSelector:@selector(integerValue)]) {
		return [object integerValue];
	} else {
        return 0;
    }
}

- (long long)jsonLongForKey:(NSString*)key {
    NSNumber *object = [self objectForKey:key];
    if ([object respondsToSelector:@selector(longLongValue)]) {
		return [object longLongValue];
	} else {
        return 0;
    }
}

- (CGFloat)jsonFloatForKey:(NSString*)key {
    NSNumber *object = [self objectForKey:key];
    if ([object respondsToSelector:@selector(floatValue)]) {
		return [object floatValue];
	} else {
        return 0;
    }
}

- (double)jsonDoubleForKey:(NSString*)key {
    NSNumber *object = [self objectForKey:key];
    if ([object respondsToSelector:@selector(doubleValue)]) {
		return [object doubleValue];
	} else {
        return 0;
    }
}

- (BOOL)jsonBoolForKey:(NSString*)key {
    return [self jsonIntegerForKey:key] != 0;
}

- (BOOL)jsonPhpBoolForKey:(NSString*)key {
    BOOL result = NO;
    NSString *object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@"t"]) {
            result = YES;
        }
    }
    return result;
}

- (NSArray*)jsonArrayForKey:(NSString*)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSArray class]]) {
        return object;
    }
    if (!object || [object isKindOfClass:[NSNull class]]) {
        return [NSArray array];
    }
    return [NSArray arrayWithObject:object];
}

- (NSString*)jsonStringForKey:(NSString*)key {
    id object = [self objectForKey:key];
    if ([object isKindOfClass:[NSString class]]) {
		return object;
	} else {
        if (object == nil || [object isKindOfClass:[NSNull class]]) {
            return @"";
        } else {
            if ([object respondsToSelector:@selector(stringValue)]) {
                return [object stringValue];
            } else {
                return [object description];
            }
        }
    }
}

- (NSDate*)jsonDateForKey:(NSString*)key format:(NSString*)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    formatter.dateFormat = format;
    return [self jsonDateForKey:key formatter:formatter];
}

- (NSDate*)jsonDateForKey:(NSString*)key formatter:(NSDateFormatter*)formater {
    return [formater dateFromString:[self jsonStringForKey:key]];
}

@end

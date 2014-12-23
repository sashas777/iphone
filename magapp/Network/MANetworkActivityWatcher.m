//
//  SNNetworkActivityWatcher.m
//  ScienceNews
//
//  Created by Viktor Kalinchuk on 4/22/14.
//  Copyright (c) 2014 aaas. All rights reserved.
//

#import "MANetworkActivityWatcher.h"

@interface MANetworkActivityWatcher ()

@property (nonatomic, assign) int counter;

@end

@implementation MANetworkActivityWatcher

static MANetworkActivityWatcher *sharedInstance;
+ (instancetype)sharedWatcher {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MANetworkActivityWatcher alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.counter = 0;
    }
    return self;
}

- (void)incrementActivity {
    if (++self.counter > 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (BOOL)decrementActivity {
    if (--self.counter <= 0) {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        self.counter = 0;
    }
    return self.counter == 0;
}

@end

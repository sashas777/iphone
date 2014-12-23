//
//  SNNetworkActivityWatcher.h
//  ScienceNews
//
//  Created by Viktor Kalinchuk on 4/22/14.
//  Copyright (c) 2014 aaas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MANetworkActivityWatcher : NSObject

+ (instancetype)sharedWatcher;

- (void)incrementActivity;
- (BOOL)decrementActivity;

@end

//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMenuItem : NSObject

@property (nonatomic, strong) NSString *name;

+ (id)itemWithName:(NSString*)name;

@end

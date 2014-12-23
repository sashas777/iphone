//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MAMenuItem.h"

@implementation MAMenuItem

+ (id)itemWithName:(NSString *)name {
    MAMenuItem *item = [[MAMenuItem alloc] init];
    item.name = name;
    return item;
}

@end

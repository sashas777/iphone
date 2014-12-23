//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MABaseTableViewCell.h"

@implementation MABaseTableViewCell

static NSString *identifier = @"MABaseTableViewCell";
+ (NSString *)reuseIdentifier {
    return identifier;
}

@end

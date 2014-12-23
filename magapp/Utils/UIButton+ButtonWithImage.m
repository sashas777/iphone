//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "UIButton+ButtonWithImage.h"

@implementation UIButton (ButtonWithImage)

+ (instancetype)buttonWithImageName:(NSString *)imageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    button.bounds = CGRectMake(0.f, 0.f, image.size.width, image.size.height);
    [button setImage:image forState:UIControlStateNormal];
    return button;
}

@end

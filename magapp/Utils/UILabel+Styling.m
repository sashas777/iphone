//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "UILabel+Styling.h"

@interface UILabel (StylingPrivate)

@end

@implementation UILabel (Styling)

- (void)applyStyle:(MALabelStyle)style fontSize:(float)size {
    if (style != MALabelStyleNone) {
        self.backgroundColor = [UILabel backgroundColorForStyle:style];
        self.textColor = [UILabel textColorForStyle:style];
        self.font = [UIFont fontWithName:[UILabel fontNameForStyle:style] size:size];
    }
}

+ (UIFont *)fontForStyle:(MALabelStyle)style {
    return [UIFont fontWithName:[UILabel fontNameForStyle:style] size:[UILabel standardFontSizeForStyle:style]];
}

- (void)applyStyle:(MALabelStyle)style {
    [self applyStyle:style fontSize:[UILabel standardFontSizeForStyle:style]];
}

+ (UIColor*)textColorForStyle:(MALabelStyle)style {
    UIColor *color = nil;
    switch (style) {
        default:
            color = UIColorFromRGB(0xbfbfbf);
            break;
    }
    return color;
}

+ (UIColor *)backgroundColorForStyle:(MALabelStyle)style {
    return [UIColor clearColor];
}

+ (NSString *)fontNameForStyle:(MALabelStyle)style {
    NSString *name = nil;
    switch (style) {
        default:
            name = @"HelveticaNeue";
            break;
    }
    return name;
}

+ (float)standardFontSizeForStyle:(MALabelStyle)style {
    float size = 16.f;
    switch (style) {
        default:
            break;
    }
    return size;
}

@end

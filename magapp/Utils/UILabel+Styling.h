//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MALabelStyleNone,
} MALabelStyle;

@interface UILabel (Styling)

+ (UIColor*)textColorForStyle:(MALabelStyle)style;
+ (UIColor*)backgroundColorForStyle:(MALabelStyle)style;
+ (NSString*)fontNameForStyle:(MALabelStyle)style;
+ (float)standardFontSizeForStyle:(MALabelStyle)style;
+ (UIFont*)fontForStyle:(MALabelStyle)style;

- (void)applyStyle:(MALabelStyle)style;
- (void)applyStyle:(MALabelStyle)style fontSize:(float)size;

@end

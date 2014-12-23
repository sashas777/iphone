//
//  MAMenuItem.h
//  megapp
//
//  Created by Viktor Kalinchuk on 10/22/14.
//  Copyright (c) 2014 Viktor Kalinchuk. All rights reserved.
//

#import "MAMenuCell.h"
#import "MAMenuItem.h"
#import "UILabel+Styling.h"

@interface MAMenuCell ()

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@end

@implementation MAMenuCell

static NSString *identifier = @"MAMenuCell";
+ (NSString *)reuseIdentifier {
    return identifier;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.item = nil;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setItem:(MAMenuItem *)item {
    _item = item;
    self.nameLabel.text = self.item.name;
}

- (void)updateInterface:(BOOL)selected {
    if (selected) {
        self.contentView.backgroundColor = [UIColor orangeColor];
        self.nameLabel.textColor = [UIColor blackColor];
    } else {
        self.contentView.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [self updateInterface:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self updateInterface:highlighted];
}

@end

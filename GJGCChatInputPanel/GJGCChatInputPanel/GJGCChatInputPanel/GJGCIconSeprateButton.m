//
//  GJGCIconSeprateButton.m
//  GJGroupChat
//
//  Created by ZYVincent on 14-11-26.
//  Copyright (c) 2014年 ZYProSoft. All rights reserved.
//

#import "GJGCIconSeprateButton.h"

@implementation GJGCIconSeprateButton

- (instancetype)initWithFrame:(CGRect)frame withSelectedIcon:(UIImage *)selectIcon withNormalIcon:(UIImage *)normalIcon
{
    if (self = [super initWithFrame:frame]) {
        
        self.selectedStateImage = selectIcon;
        self.normalStateImage = normalIcon;
        self.selected = NO;
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backButton addTarget:self action:@selector(tapOnButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.backButton];
        
        self.iconView = [[GJGCIconSeprateImageView alloc]initWithFrame:self.bounds];
        self.iconView.userInteractionEnabled = NO;
        self.iconView.image = normalIcon;
        self.iconView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.iconView];
    }
    return self;
}

- (void)tapOnButton
{
    if (self.tapBlock) {
        self.tapBlock(self);
    }
}

- (void)setSelected:(BOOL)selected
{
    _selected = selected;
    
    if (_selected) {
        self.iconView.image = self.selectedStateImage;
    }else{
        self.iconView.image = self.normalStateImage;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backButton.frame = self.bounds;
    
    self.iconView.gjcf_centerX = self.bounds.size.width/2;
    self.iconView.gjcf_centerY = self.bounds.size.height/2;
}



@end

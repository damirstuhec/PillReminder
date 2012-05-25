//
//  RemindMeCell.m
//  PillReminderProject
//
//  Created by Damir Stuhec on 5/15/12.
//  Copyright (c) 2012 FERI Maribor, Slovenia. All rights reserved.
//

#import "RemindMeCell.h"

@implementation RemindMeCell

@synthesize remindMeSwitch = _remindMeSwitch;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end

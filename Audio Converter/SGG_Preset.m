//
//  SGG_Preset.m
//  Audio Converter
//
//  Created by Michael Redig on 9/18/14.
//  Copyright (c) 2014 Secret Game Group LLC. All rights reserved.
//

#import "SGG_Preset.h"

@implementation SGG_Preset

- (id)init
{
    self = [super init];
    if (self) {
		_title = @"iOS audio";
        _container = @"CAF";
		_compression = @"AAC";
		_strategy = @"VBR";
		_bitrate = 192000;
		_canDelete = NO;
		_mono = NO;
    }
    return self;
}

@end

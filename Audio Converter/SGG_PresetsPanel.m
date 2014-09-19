//
//  SGG_PresetsPanel.m
//  Audio Converter
//
//  Created by Michael Redig on 9/18/14.
//  Copyright (c) 2014 Secret Game Group LLC. All rights reserved.
//

#import "SGG_PresetsPanel.h"
#import "SGG_Preset.h"

@interface SGG_PresetsPanel() {
	
	NSMutableArray* presets;
	
	NSUserDefaults* defaults;
}

@end


@implementation SGG_PresetsPanel

-(id)init {
	
	if (self = [super init]) {
		
		presets = [[NSMutableArray alloc] init];
		defaults = [NSUserDefaults standardUserDefaults];
		
	}
	return self;
}

-(void)awakeFromNib {
	
	NSString* path = [[NSBundle mainBundle] pathForResource:@"FileTypeLibrary" ofType:@"plist"];
	
	NSDictionary* libraryDict = [NSDictionary dictionaryWithContentsOfFile:path];
	
	NSDictionary* presetsDict = libraryDict[@"Presets"];
	
	NSArray* presetsTitles = [presetsDict allKeys];
	
	for (NSString* title in presetsTitles) {
		NSDictionary* presetDict = presetsDict[title];
		
		SGG_Preset* preset = [[SGG_Preset alloc] init];
		preset.title = title;
		preset.container = presetDict[@"container"];
		preset.compression = presetDict[@"compression"];
		preset.strategy = presetDict[@"strategy"];
		preset.bitrate = [presetDict[@"bitrate"] integerValue];
		preset.canDelete = NO;
		[presets addObject:preset];
		
	}
	
	
	
}



- (IBAction)plusButtonPressed:(NSButton *)sender {
	
	SGG_Preset* preset = [[SGG_Preset alloc] init];
	preset.canDelete = YES;
	preset.title = @"New Preset";
	preset.container = _containerPopup.titleOfSelectedItem;
	preset.compression = _compressionPopup.titleOfSelectedItem;
	preset.strategy = _compressionStrategyPopup.titleOfSelectedItem;
	preset.bitrate = [_bitrateTextField integerValue];
	
	[presets addObject:preset];
	
	[_presetsTabelView reloadData];
	
	
	NSLog(@"plus pressed");
}

- (IBAction)minusButtonPressed:(NSButton *)sender {

	NSLog(@"minus Pressed");

}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
	SGG_Preset* preset = presets[row];
	
	return [preset valueForKey:@"title"];
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
	
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return presets.count;
}

@end

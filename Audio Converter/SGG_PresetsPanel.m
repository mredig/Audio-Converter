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
	
	NSInteger defaultPresets;
	
	SGG_ConverterControl* controller;
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
	controller = (SGG_ConverterControl*)_converterController;

	
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
		preset.mono = [presetDict[@"mono"] boolValue];
		preset.canDelete = NO;
		[presets addObject:preset];
		
		defaultPresets ++;
	}
	
	NSArray* savedPresets = [defaults objectForKey:@"savedPresets"];

	for (NSDictionary* dictionaryPreset in savedPresets) {
		SGG_Preset* preset = [[SGG_Preset alloc] init];
		preset.title = dictionaryPreset[@"title"];
		preset.container = dictionaryPreset[@"container"];
		preset.compression = dictionaryPreset[@"compression"];
		preset.strategy = dictionaryPreset[@"strategy"];
		preset.bitrate = [dictionaryPreset[@"bitrate"] integerValue];
		preset.mono = [dictionaryPreset[@"mono"] boolValue];
		preset.canDelete = YES;
		
		[presets addObject:preset];
	}
	
	[_presetsTabelView reloadData];
}



- (IBAction)plusButtonPressed:(NSButton *)sender {
	
	SGG_Preset* preset = [[SGG_Preset alloc] init];
	preset.canDelete = YES;
	preset.title = @"New Preset";
	preset.container = controller.containerPopup.titleOfSelectedItem;
	preset.compression = controller.compressionPopup.titleOfSelectedItem;
	preset.strategy = controller.compressionStrategy.titleOfSelectedItem;
	if (!preset.strategy) {
		preset.strategy = @"CBR";
	}
	preset.bitrate = [controller.bitRateTextField integerValue];
	preset.mono = (bool)controller.monoCheckbox.state;
	
	[presets addObject:preset];
	
	[_presetsTabelView reloadData];

	[self updateDefaults];
	
	
}

- (IBAction)minusButtonPressed:(NSButton *)sender {
	if (_presetsTabelView.selectedRow > -1) {
		NSInteger row = _presetsTabelView.selectedRow;
		[_presetsTabelView abortEditing];
		SGG_Preset* preset = presets[row];
		if (preset.canDelete == NO) {
			return;
		}
		if (row > -1) {
			[presets removeObjectAtIndex:row];
		}
		
		[_presetsTabelView reloadData];
		[self updateDefaults];
	}

}

- (IBAction)tablePressed:(NSTableView *)sender {
	if (_presetsTabelView.selectedRow > -1) {
		SGG_Preset* preset = presets[_presetsTabelView.selectedRow];
//		NSLog(@"selected element: %@", preset.title);
		
		
		[controller.containerPopup selectItemWithTitle:preset.container];
		[controller containerChanged:controller.containerPopup];
		
		[controller.compressionPopup selectItemWithTitle:preset.compression];
		[controller compressionChanged:controller.compressionPopup];
		
		[controller.compressionStrategy selectItemWithTitle:preset.strategy];
		[controller compressionStrategyChanged:controller.compressionStrategy];
		
		[controller.bitRateTextField setStringValue:[NSString stringWithFormat:@"%i", (int)preset.bitrate]];
		[controller bitRateChanged:controller.bitRateTextField];
		
		[controller.monoCheckbox setState:preset.mono];
		[controller monoButtonPressed:controller.monoCheckbox];
	}

}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
	SGG_Preset* preset = presets[row];
	
	return preset.title;
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	
	SGG_Preset* preset = presets[row];
	preset.title = object;
	
	[self updateDefaults];
	
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return presets.count;
}


-(void)updateDefaults {
	
	NSMutableArray* newSavePresets = [[NSMutableArray alloc] init];
	
	for (NSInteger i = defaultPresets; i < presets.count; i++) {
		SGG_Preset* preset = presets[i];
		
		NSArray* presetArray = @[preset.title, preset.container, preset.compression, preset.strategy, [NSNumber numberWithInteger:preset.bitrate], [NSNumber numberWithBool:preset.mono]];
		NSArray* presetKeys = @[@"title", @"container", @"compression", @"strategy", @"bitrate", @"mono"];
		
		NSDictionary* presetDictionary = [NSDictionary dictionaryWithObjects:presetArray forKeys:presetKeys];
		
		[newSavePresets addObject:presetDictionary];
	}
	

	
	[defaults setObject:newSavePresets forKey:@"savedPresets"];
	
}


@end

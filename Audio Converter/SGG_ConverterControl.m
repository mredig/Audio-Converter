//
//  SGG_ConverterControl.m
//  Audio Converter
//
//  Created by Michael Redig on 9/16/14.
//  Copyright (c) 2014 Secret Game Group LLC. All rights reserved.
//

#import "SGG_ConverterControl.h"

@interface SGG_ConverterControl() {
	
	NSMutableArray* openFilesArray;
	
}

@end


@implementation SGG_ConverterControl

-(void)awakeFromNib {
	
	[_sourceLabel setStringValue:@""];
	[_namePopup addItemsWithTitles:@[
									 @"--------------",
									 @"Khris",
									 @"Michael",
									 @"Sam",
									 @"Cody",
									 @"Kurt",
									 @"Scott",
									 ]];
	
	
	[_compressionPopup removeAllItems];

	
}

- (IBAction)openFileNamed:(id)sender {
	
	NSArray* audioTypes = [NSSound soundUnfilteredTypes];
	NSOpenPanel* openWindow = [NSOpenPanel openPanel];
	[openWindow setPrompt:@"Select"];
	[openWindow setAllowedFileTypes:audioTypes];
//	[openWindow setAllowsMultipleSelection:YES];
	
	[openWindow beginWithCompletionHandler:^(NSInteger result) {
		NSURL* url = [openWindow URLs][0];
		NSLog(@"open files: %@", url.pathComponents);
		openFilesArray = [[NSMutableArray alloc] init];
		[openFilesArray addObject:url];
		[_sourceLabel setStringValue:url.path];
		NSURL* urlTwo = [self containerPathOfPathFromPathComponents:url.pathComponents];
		
		[_destinationField setStringValue:urlTwo.path];
	}];


}

- (IBAction)saveTo:(NSButton *)sender {
	
	NSSavePanel* saveWindow = [NSSavePanel savePanel];
	[saveWindow beginWithCompletionHandler:^(NSInteger result) {
		NSURL* url = [saveWindow URL];
		NSLog(@"save to: %@", url);
		NSURL* urlTwo = [self containerPathOfPathFromPathComponents:url.pathComponents];
		
		[_destinationField setStringValue:urlTwo.path];
	}];
	
}

- (IBAction)containerChanged:(NSPopUpButton *)sender {
}

- (IBAction)compressionChanged:(NSPopUpButton *)sender {
}

- (IBAction)compressionStrategyChanged:(NSPopUpButton *)sender {
}

- (IBAction)encodeButtonPressed:(NSButton *)sender {
	
	
	
}


-(NSURL*)containerPathOfPathFromPathComponents:(NSArray*)filePathComponents {
	
	NSString* finalString = @"";
	for (int i = 0; i < filePathComponents.count - 1; i++) {
		NSString* component = filePathComponents[i];
		if (i == 0) {
			finalString = [NSString stringWithFormat:@"%@", component];
		} else {
			finalString = [NSString stringWithFormat:@"%@%@/", finalString, component];

		}
	}
	
	finalString = [NSString stringWithFormat:@"%@/", finalString];
	
	NSLog(@"%@", finalString);
	
	NSURL* url = [NSURL fileURLWithPath:finalString];
	
	return url;
}
@end

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
	
	NSArray* fileTypes;
	
	NSArray* currentContainerCodecs;
	NSString* currentContainerHuman;
	NSString* currentContainerCommand;
	NSString* currentContainerExtension;
	NSString* currentCompressionType;
	
	NSUserDefaults* defaults;
	
	bool userStarted;
}

@end


@implementation SGG_ConverterControl

-(void)awakeFromNib {
	
	defaults = [NSUserDefaults standardUserDefaults];
	
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
	[_containerPopup removeAllItems];
	[_compressionStrategy removeAllItems];
	
	NSURL* libraryPath = [[NSBundle mainBundle] URLForResource:@"FileTypeLibrary" withExtension:@"plist"];
	
	NSDictionary* libraryDict = [NSDictionary dictionaryWithContentsOfURL:libraryPath];
	
	fileTypes = libraryDict[@"FileTypes"];

	[self populateConatinerPopup];
	
	[_compressionStrategy addItemsWithTitles:@[
											   @"CBR",
											   @"ABR",
											   @"VBR Constrained",
											   @"VBR",
											   ]];
	
	userStarted = YES;
	
	[self restoreUserSettings];
}

-(void)restoreUserSettings {
	
	[_namePopup selectItemWithTitle:[defaults objectForKey:@"currentUser"]];
	
	[_encouragementCheckbox setState:[defaults boolForKey:@"encouragementEnabled"]];
	
	[_containerPopup selectItemWithTitle:[defaults objectForKey:@"currentContainer"]];
	[self populateCompressionPopup];
	
	[_compressionPopup selectItemWithTitle:[defaults objectForKey:@"currentCompression"]];
	[_compressionStrategy selectItemWithTitle:[defaults objectForKey:@"currentCompressionStrategy"]];
	
	
	NSInteger bitrate = [[defaults objectForKey:@"currentBitrate"] integerValue];
	[_bitRateTextField setStringValue:[NSString stringWithFormat:@"%i", (int)bitrate]];
		
}

-(void)populateConatinerPopup {
	
	for (int i = 0; i < fileTypes.count; i++) {
		NSDictionary* dict = fileTypes[i];
		NSString* human = dict[@"human"];
		[_containerPopup addItemWithTitle:human];
	}
	[self populateCompressionPopup];
}

-(void)populateCompressionPopup {
	currentContainerHuman = _containerPopup.selectedItem.title;
	
	[_compressionPopup removeAllItems];
	
	for (int i = 0; i < fileTypes.count; i++) {
		NSDictionary* dict = fileTypes[i];
		NSString* human = dict[@"human"];
		if ([human isEqualToString:currentContainerHuman]) {
			//
			currentContainerCodecs = dict[@"compressionTypes"];
			for (int h = 0; h < currentContainerCodecs.count; h++) {
				NSDictionary* compressionDict = currentContainerCodecs[h];
				NSString* humanReadable = compressionDict[@"human"];
				[_compressionPopup addItemWithTitle:humanReadable];
			}
			break;
		}
	}
	
	[self compressionChanged:_compressionPopup];
	
	
}

- (IBAction)nameChanged:(NSPopUpButton *)sender {
	
	[self updateDefaults];

}

- (IBAction)openFileNamed:(id)sender {
	
	NSArray* audioTypes = [NSSound soundUnfilteredTypes];
	NSOpenPanel* openWindow = [NSOpenPanel openPanel];
	[openWindow setPrompt:@"Select"];
	[openWindow setAllowedFileTypes:audioTypes];
//	[openWindow setAllowsMultipleSelection:YES];
	
	[openWindow beginWithCompletionHandler:^(NSInteger result) {
		if (result > 0) {
			NSURL* url = [openWindow URLs][0];
			openFilesArray = [[NSMutableArray alloc] init];
			[openFilesArray addObject:url];
			[_sourceLabel setStringValue:url.path];
			NSURL* urlTwo = [self containerPathOfPathFromPathComponents:url.pathComponents];
			
			[_destinationField setStringValue:urlTwo.path];
		}

	}];


}

- (IBAction)saveTo:(NSButton *)sender {
	
//	NSSavePanel* saveWindow = [NSSavePanel savePanel];
//	[saveWindow beginWithCompletionHandler:^(NSInteger result) {
//		NSURL* url = [saveWindow URL];
//		NSURL* urlTwo = [self containerPathOfPathFromPathComponents:url.pathComponents];
//		
//		[_destinationField setStringValue:urlTwo.path];
//	}];
	
	
	NSOpenPanel* openWindow = [NSOpenPanel openPanel];
	[openWindow setPrompt:@"Save To:"];
	[openWindow setCanChooseDirectories:YES];
	[openWindow setCanChooseFiles:NO];
	
	
	//	[openWindow setAllowsMultipleSelection:YES];
	
	[openWindow beginWithCompletionHandler:^(NSInteger result) {
		if (result > 0) {
			NSURL* url = [openWindow URLs][0];
			[_destinationField setStringValue:url.path];
		}
		
	}];
	
}

- (IBAction)containerChanged:(NSPopUpButton *)sender {
	
	currentContainerHuman = sender.selectedItem.title;
	
	for (NSDictionary* containerDict in fileTypes) {
		if ([containerDict[@"human"] isEqualToString:currentContainerHuman]) {
			currentContainerExtension = containerDict[@"container"];
			currentContainerCommand = containerDict[@"command"];
			break;
		}
	}
	
//	NSLog(@"ext: %@ command: %@", currentContainerExtension, currentContainerCommand);
	
	[self populateCompressionPopup];
	
	[self updateDefaults];

}

- (IBAction)compressionChanged:(NSPopUpButton *)sender {
	
	[self updateDefaults];
	
	NSString* currentCompressionTitle = _compressionPopup.titleOfSelectedItem;
	
	for (int i = 0; i < currentContainerCodecs.count; i++) {
		NSDictionary* dict = currentContainerCodecs[i];
		NSString* title = dict[@"human"];
		if ([title isEqualToString:currentCompressionTitle]) {
			//
			currentCompressionType = dict[@"actual"];
			break;
		}
	}

	
	bool isCompatible = [self compressionTypeSupportsBitrate:currentCompressionType];
	if (isCompatible) {
		[_compressionStrategy setEnabled:YES];;
		[_bitRateTextField setEnabled:YES];
	} else {
		[_compressionStrategy setEnabled:NO];;
		[_bitRateTextField setEnabled:NO];
		
	}
	
	
}

- (IBAction)compressionStrategyChanged:(NSPopUpButton *)sender {
	[self updateDefaults];
	
	

}

- (IBAction)bitRateChanged:(NSTextField *)sender {
	
	[self updateDefaults];

}

- (IBAction)encouragementChanged:(NSButton *)sender {
	[self updateDefaults];

}

-(void)updateDefaults {
	
	if (userStarted) {
		[defaults setBool:_encouragementCheckbox.state forKey:@"encouragementEnabled"];
		
		[defaults setObject:_namePopup.selectedItem.title forKey:@"currentUser"];
		
		[defaults setObject:currentContainerHuman forKey:@"currentContainer"];
		
		[defaults setObject:_compressionPopup.selectedItem.title forKey:@"currentCompression"];
		
		[defaults setObject:_compressionStrategy.selectedItem.title forKey:@"currentCompressionStrategy"];
		
		NSInteger bitrate = [_bitRateTextField.stringValue integerValue];
		[defaults setObject:[NSNumber numberWithInteger:bitrate] forKey:@"currentBitrate"];

	}
	
		
	
}



- (IBAction)encodeButtonPressed:(NSButton *)sender {
	
	NSArray* arguments = [self determineArguments];

	
	NSTask* transcode = [[NSTask alloc] init];
	[transcode setLaunchPath:@"/bin/bash"];
	[transcode setArguments:arguments];
	[_progressIndicator startAnimation:nil];
	[transcode launch];
	[transcode setTerminationHandler:^(NSTask* transcode) {
		[_progressIndicator stopAnimation:nil];
	}];
	
	NSLog(@"arguments: %@", arguments);
}

-(NSArray*)determineArguments {
	NSString* stringThing = @"-c";
	NSString* executable = @"/usr/bin/afconvert";
	NSString* destFormat, *destCodec, *destStrat, *destBitrate, *inputFile, *outputFile;
	
	destFormat = [NSString stringWithFormat:@"-f '%@'", currentContainerCommand];
	destCodec = [NSString stringWithFormat:@"-d '%@'", currentCompressionType];
	
	if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"CBR"]) {
		destStrat = @"-s 0";
	} else if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"ABR"]) {
		destStrat = @"-s 1";
	} else if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"VBR Constrained"]) {
		destStrat = @"-s 2";
	} else if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"VBR"]) {
		destStrat = @"-s 3";
	} else {
		destStrat = @"-s 3";
	}
	

	destBitrate = [NSString stringWithFormat:@"-b '%@'", _bitRateTextField.stringValue];
	
	if (![self compressionTypeSupportsBitrate:currentCompressionType]) {
		destBitrate = @"";
		destStrat = @"";
	}

	NSURL* inputURL = openFilesArray[0];
	inputFile = [NSString stringWithFormat:@"'%@'", inputURL.path];
	
	outputFile = [NSString stringWithFormat:@"'%@/%@.%@'", _destinationField.stringValue, inputURL.pathComponents[inputURL.pathComponents.count -1], currentContainerExtension];
	
//	NSLog(@"ex: %@, form: %@, cod: %@, strat: %@, bit: %@, filein: %@, fileout: %@",
//		  executable, destFormat, destCodec, destStrat, destBitrate, inputFile, outputFile);
//	return nil;
	
	NSString* command = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ -o %@", executable, destFormat, destCodec, destStrat, destBitrate, inputFile, outputFile];
	
//	return @[stringThing, executable, destFormat, destCodec, destStrat, destBitrate, inputFile, outputFile];
	return @[stringThing, command];
}

-(bool)compressionTypeSupportsBitrate:(NSString*)compressionType {
	
	NSArray* unsupportedFormats = @[
									@"alac",
									@"I8",
									@"BEI16",
									@"BEI24",
									@"BEI32",
									@"UI8",
									@"LEI16",
									@"LEI24",
									@"LEI32",
									@"LEF32",
									@"LEI64",
									
									];
	
	bool supported = YES;
	
	for (NSString* unsupported in unsupportedFormats) {
		if ([unsupported isEqualToString:compressionType]) {
			supported = NO;
		}
	}
	
	return supported;
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
	
//	NSLog(@"%@", finalString);
	
	NSURL* url = [NSURL fileURLWithPath:finalString];
	
	return url;
}
@end

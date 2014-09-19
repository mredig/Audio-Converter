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
	bool isRunning;
	
	NSPipe* outputPipe;
}

@end


@implementation SGG_ConverterControl

#pragma mark INIT AND SETUP

-(void)awakeFromNib {
	
	defaults = [NSUserDefaults standardUserDefaults];
	
	[_sourceLabel setStringValue:@""];
	
	
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
	
	
	[self restoreUserSettings];
	userStarted = YES;
}

-(void)restoreUserSettings {
	
	
	[_encouragementCheckbox setState:[defaults boolForKey:@"encouragementEnabled"]];
	
	[_monoCheckbox setState:[defaults boolForKey:@"monoEnabled"]];
	
	[_containerPopup selectItemWithTitle:[defaults objectForKey:@"currentContainer"]];
//	[self populateCompressionPopup];
	[self containerChanged:_containerPopup];
	
	[_compressionPopup selectItemWithTitle:[defaults objectForKey:@"currentCompression"]];
	[self compressionChanged:_compressionPopup];
	
	[_compressionStrategy selectItemWithTitle:[defaults objectForKey:@"currentCompressionStrategy"]];
	
	
	NSInteger bitrate = [[defaults objectForKey:@"currentBitrate"] integerValue];
	[_bitRateTextField setStringValue:[NSString stringWithFormat:@"%i", (int)bitrate]];
		
	[self enableOrDisableVariableBitrate];

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

#pragma mark INTERFACE INPUT METHODS


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
		[self canTranscode];

	}];
	[self canTranscode];


}

- (IBAction)saveTo:(id)sender {
		
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
		[self canTranscode];

	}];
	[self canTranscode];

}

- (IBAction)destinationChanged:(NSTextField *)sender {
	
	[self canTranscode];
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
	[self canTranscode];

}

- (IBAction)compressionChanged:(NSPopUpButton *)sender {
	

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

	
	[self enableOrDisableVariableBitrate];

	
	[self updateDefaults];
	[self canTranscode];
	
	
}



- (IBAction)compressionStrategyChanged:(NSPopUpButton *)sender {
	[self updateDefaults];
	[self canTranscode];

}

- (IBAction)bitRateChanged:(NSTextField *)sender {
	[self updateDefaults];
	[self canTranscode];

}

- (IBAction)encouragementChanged:(NSButton *)sender {
	[self updateDefaults];
	[self canTranscode];

}

- (IBAction)presetsButtonPressed:(NSButton *)sender {
	
	_presetsPanel.isVisible = YES;
	
}

- (IBAction)monoButtonPressed:(NSButton *)sender {
	[self updateDefaults];
	[self canTranscode];
	
}




- (IBAction)encodeButtonPressed:(NSButton *)sender {
	
	NSArray* arguments = [self determineArguments];

	[self transcodeWithArguments:arguments];

}


#pragma mark MISC

-(void)transcodeWithArguments:(NSArray*)arguments {
	
	dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
	dispatch_async(taskQueue, ^{
		
		isRunning = YES;
		
		@try {
			[_progressIndicator startAnimation:nil];
			_outputTextArea.string = @"";

			
			NSTask* transcode = [[NSTask alloc] init];
//			transcode.launchPath = @"/usr/bin/afconvert";
			transcode.launchPath = @"/bin/bash";
//			transcode.launchPath = @"/bin/echo";
			transcode.arguments = arguments;
			
			
			outputPipe = [[NSPipe alloc] init];
			[transcode setStandardOutput:outputPipe];
			[transcode setStandardError:outputPipe];

			[[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];

			NSNotificationCenter* notificationCenter = [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *note) {

				NSData* output = [[outputPipe fileHandleForReading] availableData];
				NSString* outString = [[NSString alloc ] initWithData:output encoding:NSUTF8StringEncoding];

				dispatch_sync(dispatch_get_main_queue(), ^{
					_outputTextArea.string = [_outputTextArea.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", outString]];

					NSRange range;
					range = NSMakeRange([_outputTextArea.string length], 0);
					[_outputTextArea scrollRangeToVisible:range];
				});
				
				[[outputPipe fileHandleForReading] waitForDataInBackgroundAndNotify];
			}];
			
			[transcode launch];
			
			[transcode waitUntilExit];
			
			[[NSNotificationCenter defaultCenter] removeObserver:notificationCenter];
			
			[transcode setTerminationHandler:^(NSTask* transcode) {
				[_progressIndicator stopAnimation:nil];
				if (_encouragementCheckbox.state) {
					[self encourage];
				}
			}];
			
		}
		@catch (NSException *exception) {
			NSLog(@"Problem Running Task: %@", [exception description]);
		}
		@finally {
			isRunning = NO;
			[self canTranscode];
		}
		
	});
	
	
}




-(NSArray*)determineArguments {
	NSString* stringThing = @"-c";
	NSString* executable = @"/usr/bin/afconvert -v ";
	NSString* destFormat, *destCodec, *destStrat, *destBitrate, *inputFile, *outputFile;
	
	destFormat = [NSString stringWithFormat:@"'%@'", currentContainerCommand];
	destCodec = [NSString stringWithFormat:@"'%@'", currentCompressionType];
	
	NSString* stratFlag = @" -s ";
	
	if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"CBR"]) {
		destStrat = @"0";
	} else if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"ABR"]) {
		destStrat = @"1";
	} else if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"VBR Constrained"]) {
		destStrat = @"2";
	} else if ([_compressionStrategy.titleOfSelectedItem isEqualToString:@"VBR"]) {
		destStrat = @"3";
	} else {
		destStrat = @"3";
	}
	
	NSString* bitrateFlag = @" -b ";

	destBitrate = [NSString stringWithFormat:@"'%@'", _bitRateTextField.stringValue];
	
	if (![self compressionTypeSupportsBitrate:currentCompressionType]) {
		destBitrate = @"";
		destStrat = @"";
		bitrateFlag = @"";
		stratFlag = @"";
	}

	NSURL* inputURL = openFilesArray[0];
	inputFile = [NSString stringWithFormat:@"'%@'", inputURL.path];
//	inputFile = [NSString stringWithFormat:@"%@", inputURL.path];
	
	NSString* removeExtension = inputURL.pathComponents[inputURL.pathComponents.count - 1];
	removeExtension = [removeExtension stringByDeletingPathExtension];
	
	outputFile = [NSString stringWithFormat:@"'%@/%@.%@'", _destinationField.stringValue, removeExtension, currentContainerExtension];
//	outputFile = [NSString stringWithFormat:@"%@/%@.%@", _destinationField.stringValue, removeExtension, currentContainerExtension];
	
	NSString* downmixToMono = @"--mix -c 1";
	
	if (_monoCheckbox.state == 0) {
		downmixToMono = @"";
	}
	
	NSString* command = [NSString stringWithFormat:@"%@ -f %@ -d %@ %@ %@ %@ %@ %@ %@ -o %@", executable, destFormat, destCodec, stratFlag, destStrat, bitrateFlag, destBitrate, downmixToMono, inputFile, outputFile];
	
//	return @[@" -v ", @" -f ", destFormat, @" -d ", destCodec, stratFlag, destStrat, bitrateFlag, destBitrate, inputFile, @" -o ", outputFile];
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
									@"LEF64",
									];
	
	bool supported = YES;
	
	for (NSString* unsupported in unsupportedFormats) {
		if ([unsupported isEqualToString:compressionType]) {
			supported = NO;
		}
	}
	
	return supported;
}

-(void)enableOrDisableVariableBitrate {
	
	bool isCompatible = [self compressionTypeSupportsBitrate:currentCompressionType];
	
//	NSLog(@"currentType: %@ isComp: %i", currentCompressionType, isCompatible);
	if (isCompatible) {
		[_compressionStrategy setEnabled:YES];;
		[_bitRateTextField setEnabled:YES];
	} else {
		[_compressionStrategy setEnabled:NO];;
		[_bitRateTextField setEnabled:NO];
		
	}
	
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

-(BOOL)canTranscode {
	
	if (![_sourceLabel.stringValue isEqualToString:@""] && ![_destinationField.stringValue isEqualToString:@""] && !isRunning) {
		[_encodeButton setEnabled:YES];
		return YES;
	} else {
		[_encodeButton setEnabled:NO];
		return NO;
	}
	
}

-(void)encourage {
	
	NSSound* sound = [NSSound soundNamed:@"base_encourage.mp3"];
	sound.delegate = self;
	[sound play];
	
	
}

-(void)sound:(NSSound *)sound didFinishPlaying:(BOOL)aBool {
	
	NSString* currentUser = NSFullUserName();
	NSString* filename;
	
	if ([currentUser rangeOfString:@"Michael"].location != NSNotFound) {
		filename = @"name_michael.mp3";
	} else if ([currentUser rangeOfString:@"Cody"].location != NSNotFound) {
		filename = @"name_cody.mp3";
	} else if ([currentUser rangeOfString:@"Khris"].location != NSNotFound) {
		filename = @"name_khris.mp3";
	} else if ([currentUser rangeOfString:@"Chris"].location != NSNotFound) {
		filename = @"name_khris.mp3";
	} else if ([currentUser rangeOfString:@"Kurt"].location != NSNotFound) {
		filename = @"name_kurt.mp3";
	} else if ([currentUser rangeOfString:@"Sam"].location != NSNotFound) {
		filename = @"name_sam.mp3";
	} else if ([currentUser rangeOfString:@"Scott"].location != NSNotFound) {
		filename = @"name_scott.mp3";
	} else {
		filename = @"name_default_alt.mp3";
	}

	
	NSSound* name = [NSSound soundNamed:filename];
	[name play];
}


-(void)updateDefaults {
	
	if (userStarted) {
		[defaults setBool:_encouragementCheckbox.state forKey:@"encouragementEnabled"];
		
		[defaults setBool:_monoCheckbox.state forKey:@"monoEnabled"];
				
		[defaults setObject:currentContainerHuman forKey:@"currentContainer"];
		
		[defaults setObject:_compressionPopup.selectedItem.title forKey:@"currentCompression"];
		
		[defaults setObject:_compressionStrategy.selectedItem.title forKey:@"currentCompressionStrategy"];
		
		NSInteger bitrate = [_bitRateTextField.stringValue integerValue];
		[defaults setObject:[NSNumber numberWithInteger:bitrate] forKey:@"currentBitrate"];
	}
}

@end

//
//  SGG_ConverterControl.h
//  Audio Converter
//
//  Created by Michael Redig on 9/16/14.
//  Copyright (c) 2014 Secret Game Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGG_ConverterControl : NSObject

@property (weak) IBOutlet NSPopUpButton *namePopup;
@property (weak) IBOutlet NSTextField *sourceLabel;
@property (weak) IBOutlet NSTextField *destinationField;
@property (weak) IBOutlet NSPopUpButton *containerPopup;
@property (weak) IBOutlet NSPopUpButton *compressionPopup;
@property (weak) IBOutlet NSPopUpButton *compressionStrategy;
@property (weak) IBOutlet NSTextField *bitRateTextField;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;
@property (weak) IBOutlet NSButton *encouragementCheckbox;
@property (weak) IBOutlet NSButton *encodeButton;


- (IBAction)nameChanged:(NSPopUpButton *)sender;
- (IBAction)openFileNamed:(id)sender;
- (IBAction)saveTo:(NSButton *)sender;
- (IBAction)containerChanged:(NSPopUpButton *)sender;
- (IBAction)compressionChanged:(NSPopUpButton *)sender;
- (IBAction)compressionStrategyChanged:(NSPopUpButton *)sender;
- (IBAction)bitRateChanged:(NSTextField *)sender;
- (IBAction)encouragementChanged:(NSButton *)sender;

- (IBAction)encodeButtonPressed:(NSButton *)sender;

@end

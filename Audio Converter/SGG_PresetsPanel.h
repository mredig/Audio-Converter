//
//  SGG_PresetsPanel.h
//  Audio Converter
//
//  Created by Michael Redig on 9/18/14.
//  Copyright (c) 2014 Secret Game Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SGG_ConverterControl.h"

@interface SGG_PresetsPanel : NSObject <NSTableViewDataSource>


@property (weak) IBOutlet NSTableView *presetsTabelView;
@property (weak) IBOutlet NSPopUpButton *containerPopup;
@property (weak) IBOutlet NSPopUpButton *compressionPopup;
@property (weak) IBOutlet NSPopUpButton *compressionStrategyPopup;
@property (weak) IBOutlet NSTextField *bitrateTextField;
@property (weak) IBOutlet id converterController;
@property (weak) IBOutlet NSButton *monoCheckbox;




- (IBAction)plusButtonPressed:(NSButton *)sender;
- (IBAction)minusButtonPressed:(NSButton *)sender;
- (IBAction)tablePressed:(NSTableView *)sender;

@end

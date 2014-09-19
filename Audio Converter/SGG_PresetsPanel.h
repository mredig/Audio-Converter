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
@property (weak) IBOutlet id converterController;




- (IBAction)plusButtonPressed:(NSButton *)sender;
- (IBAction)minusButtonPressed:(NSButton *)sender;
- (IBAction)tablePressed:(NSTableView *)sender;

@end

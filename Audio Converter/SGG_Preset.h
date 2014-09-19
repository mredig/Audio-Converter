//
//  SGG_Preset.h
//  Audio Converter
//
//  Created by Michael Redig on 9/18/14.
//  Copyright (c) 2014 Secret Game Group LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SGG_Preset : NSObject

@property (nonatomic) NSString* title;
@property (nonatomic) NSString* container;
@property (nonatomic) NSString* compression;
@property (nonatomic) NSString* strategy;
@property (nonatomic) NSInteger bitrate;
@property (nonatomic) BOOL canDelete;



@end

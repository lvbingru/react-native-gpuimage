//
//  RCTGPUImageView.m
//  RCTGPUImage
//
//  Created by LvBingru on 6/21/16.
//  Copyright © 2016 erica. All rights reserved.
//

#import "RCTGPUImageView.h"


@interface RCTGPUImageView()

@end

@implementation RCTGPUImageView

- (void)setFilter:(GPUImageFilter *)filter
{
    _filter = filter;
    [_filter forceProcessingAtSize:self.sizeInPixels];
    [_filter addTarget:self];
    [self updateImage];
}

- (void)setSourcePicture:(GPUImagePicture *)sourcePicture
{
    _sourcePicture = sourcePicture;
    [_sourcePicture removeAllTargets];
    [self updateImage];
}

- (void)setParams:(NSDictionary *)params
{
    for (NSString *key in params.allKeys) {
        if ([_filter respondsToSelector:NSSelectorFromString(key)]) {
            [_filter setValue:params[key] forKeyPath:key];
        }
    }
    [_sourcePicture processImage];
}

- (void)updateImage
{
    if (_sourcePicture) {
        if (_filter) {
            [_sourcePicture addTarget:_filter];
        }
        else {
            [_sourcePicture addTarget:self];
        }
        [_sourcePicture processImage];
    }
}
@end

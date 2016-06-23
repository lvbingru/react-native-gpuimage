//
//  RCTGPUImageView.m
//  RCTGPUImage
//
//  Created by LvBingru on 6/21/16.
//  Copyright © 2016 erica. All rights reserved.
//

#import "RCTGPUImageView.h"

@interface RCTGPUImageView()

@property (nonatomic, strong) GPUImageView *gpuImageView;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;

@end

@implementation RCTGPUImageView

- (id)initWithBridge:(RCTBridge *)bridge
{
    self = [super initWithBridge:bridge];
    if (self) {
        GPUImageView *gpuImageView = [GPUImageView new];
        [gpuImageView setClipsToBounds:YES];
        [self addSubview:gpuImageView];
        _gpuImageView = gpuImageView;
    }
    return self;
}

- (void)setFilter:(GPUImageFilter *)filter
{
    _filter = filter;
//    [_filter forceProcessingAtSize:self.sizeInPixels];
    [self reloadGPUImage];
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

- (UIImage *)captureImage
{
    [_filter useNextFrameForImageCapture];
    [_sourcePicture processImage];
    UIImage *image = [_filter imageFromCurrentFramebuffer];
    return image;
}

#pragma mark - private

- (void)reloadGPUImage
{
    if (_sourcePicture && _gpuImageView) {
        [_sourcePicture removeAllTargets];
        [_filter removeAllTargets];
        if (_filter) {
            [_sourcePicture addTarget:_filter];
        }
        else {
            [_sourcePicture addTarget:_gpuImageView];
        }
        if ([_filter respondsToSelector:@selector(updateSources)]) {
            [_filter performSelector:@selector(updateSources)];
        }
        [_filter addTarget:_gpuImageView];
        [_sourcePicture processImage];
    }
}

- (void)upateGPUImage:(UIImage *)image
{
    [_gpuImageView setBackgroundColor:self.backgroundColor];
    if (self.contentMode == UIViewContentModeScaleToFill) {
        _gpuImageView.fillMode = kGPUImageFillModeStretch;
    }
    else if (self.contentMode == UIViewContentModeScaleAspectFill) {
        _gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    }
    else if (self.contentMode == UIViewContentModeScaleAspectFit) {
        _gpuImageView.fillMode = kGPUImageFillModePreserveAspectRatio;
    }
    [_gpuImageView setFrame:self.bounds];
    [_gpuImageView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    
    _sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
    [self reloadGPUImage];
}

#pragma mark - overwrite
- (void)setImage:(UIImage *)image
{
    BOOL needUpdate = (image && image!=super.image);
    [super setImage:image];
    
    if (image == nil) {
        [_sourcePicture removeAllTargets];
        [_filter removeAllTargets];
    }
    if (needUpdate) {
        [self upateGPUImage:image];
    }
}

@end

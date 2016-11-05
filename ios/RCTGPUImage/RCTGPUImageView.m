//
//  RCTGPUImageView.m
//  RCTGPUImage
//
//  Created by LvBingru on 6/21/16.
//  Copyright © 2016 erica. All rights reserved.
//

#import "RCTGPUImageView.h"
#import "RCTImageSource.h"

@interface RCTGPUImageView() {
    BOOL _needReloadFilterGroup;
}

@property (nonatomic, strong) GPUImageFilterGroup *filterGroup;
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

- (void)setFilters:(NSArray *)filters
{
    _filters = filters;
    _needReloadFilterGroup = YES;
    
    [self reloadFilterGroups];
}

- (UIImage *)captureImage
{
    [_filterGroup useNextFrameForImageCapture];
    [_sourcePicture processImage];
    UIImage *image = [_filterGroup imageFromCurrentFramebuffer];
    return image;
}

#pragma mark - private

- (void)reloadGPUImage
{
    if (_sourcePicture && _gpuImageView) {
        [_sourcePicture removeAllTargets];
        [_filterGroup removeAllTargets];
        
        if (_filterGroup) {
            [_sourcePicture addTarget:_filterGroup];
            int count = [_filterGroup filterCount];
            for (int i = 0; i< count; i++) {
                GPUImageFilter *filter = [_filterGroup filterAtIndex:i];
                if ([filter respondsToSelector:@selector(updateSources)]) {
                    [filter performSelector:@selector(updateSources)];
                }
            }
            [_filterGroup addTarget:_gpuImageView];
        }
        else {
            [_sourcePicture addTarget:_gpuImageView];
        }
        [_sourcePicture processImage];
    }
}

- (void)reloadFilterGroups
{
    if (_needReloadFilterGroup) {
        _needReloadFilterGroup = NO;
        
        BOOL needUpdate = NO;
        NSInteger count = _filters.count;
        if (count != [_filterGroup filterCount]) {
            needUpdate = YES;
        }
        else {
            for (int i = 0; i< count; i++) {
                NSDictionary *filterDic = _filters[i];
                NSString *name = filterDic[@"name"];
                
                GPUImageFilter *filter = [_filterGroup filterAtIndex:i];
                if (![name isEqualToString:NSStringFromClass(filter.class)]) {
                    needUpdate = YES;
                    break;
                }
            }
        }
        
        if (needUpdate) {
            _filterGroup = [GPUImageFilterGroup new];
            NSMutableArray *filterList = [NSMutableArray new];
            for (NSDictionary *filter in _filters) {
                NSString *name = filter[@"name"];
                
                if (name) {
                    Class filterClass = NSClassFromString(name);
                    GPUImageFilter *imageFilter = [filterClass new];
                    if ([imageFilter isKindOfClass:[GPUImageFilter class]]) {
                        [filterList.lastObject addTarget:imageFilter];
                        [_filterGroup addFilter:imageFilter];
                        [filterList addObject:imageFilter];
                    }
                }
            }
            if (filterList.firstObject) {
                [_filterGroup setInitialFilters:@[filterList.firstObject]];
            }
            if (filterList.lastObject) {
                [_filterGroup setTerminalFilter:filterList.lastObject];
            }
        }
        
        for (int i = 0; i< count; i++) {
            NSDictionary *filterDic = _filters[i];
            NSDictionary *params = filterDic[@"params"];
            if (params) {
                GPUImageFilter *filter = [_filterGroup filterAtIndex:i];
                if ([filter isKindOfClass:[GPUImageTransformFilter class]]) {
                    CATransform3D transform = CATransform3DIdentity;
                    CGFloat *p = (CGFloat *)&transform;
                    NSArray *modelViewMatrix = params[@"transform3D"];
                    for (int i = 0; i < 16; ++i) {
                        *p = [[modelViewMatrix objectAtIndex:i] floatValue];
                        ++p;
                    }
                    [(GPUImageTransformFilter *)filter setTransform3D:transform];
                }
                else {
                    for (NSString *key in params.allKeys) {
                        if ([filter respondsToSelector:NSSelectorFromString(key)]) {
                            [filter setValue:params[key] forKeyPath:key];
                        }
                    }
                }
            }
        }
        [self reloadGPUImage];
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

- (void)clearGPUImage
{
    [_filterGroup removeAllTargets];
    _sourcePicture = nil;
}

#pragma mark - overwrite
- (void)setImage:(UIImage *)image
{
    BOOL needUpdate = (image && image!=super.image);
    [super setImage:image];
    
    if (image == nil) {
        [self clearGPUImage];
    }
    if (needUpdate) {
        [self upateGPUImage:image];
        if(self.onGetSize) {
            self.onGetSize(@{@"size":@{@"width":@(image.size.width), @"height":@(image.size.height)}});
        }
    }
}

- (void)setSource:(RCTImageSource *)source
{
    if (![source isEqual:super.imageSources]) {
        [self clearGPUImage];
    }
    //[super setSource:source];
}

@end

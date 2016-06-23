//
//  RCTGPUImageViewManager.m
//  RCTGPUImage
//
//  Created by LvBingru on 6/21/16.
//  Copyright © 2016 erica. All rights reserved.
//

#import "RCTGPUImageViewManager.h"
#import "RCTGPUImageView.h"
#import "RCTConvert.h"
#import "RCTImageLoader.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTUIManager.h"
#import "RCTImageStoreManager.h"

@implementation RCTGPUImageViewManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    return [[RCTGPUImageView alloc] initWithBridge:self.bridge];
}

RCT_EXPORT_VIEW_PROPERTY(blurRadius, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(capInsets, UIEdgeInsets)
RCT_REMAP_VIEW_PROPERTY(defaultSource, defaultImage, UIImage)
RCT_EXPORT_VIEW_PROPERTY(onLoadStart, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onProgress, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onError, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoad, RCTDirectEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onLoadEnd, RCTDirectEventBlock)
RCT_REMAP_VIEW_PROPERTY(resizeMode, contentMode, RCTResizeMode)
RCT_EXPORT_VIEW_PROPERTY(source, RCTImageSource)
RCT_CUSTOM_VIEW_PROPERTY(tintColor, UIColor, RCTImageView)
{
    // Default tintColor isn't nil - it's inherited from the superView - but we
    // want to treat a null json value for `tintColor` as meaning 'disable tint',
    // so we toggle `renderingMode` here instead of in `-[RCTImageView setTintColor:]`
    view.tintColor = [RCTConvert UIColor:json] ?: defaultView.tintColor;
    view.renderingMode = json ? UIImageRenderingModeAlwaysTemplate : defaultView.renderingMode;
}

RCT_EXPORT_VIEW_PROPERTY(params, NSDictionary)
RCT_CUSTOM_VIEW_PROPERTY(filter, NSString, RCTGPUImageView)
{
    NSString *filter = [RCTConvert NSString:json];
    
    if (!view.filter || ![filter isEqualToString:NSStringFromClass(view.filter.class)]) {
        
        Class filterClass = NSClassFromString(filter);
        id imageFilter = [filterClass new];
        if ([imageFilter isKindOfClass:[GPUImageFilter class]]) {
            view.filter = imageFilter;
        }
    }
}

RCT_EXPORT_METHOD(capture:(nonnull NSNumber *)reactTag
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *view = [self.bridge.uiManager viewForReactTag:reactTag];
        if ([view isKindOfClass:[RCTGPUImageView class]]) {
            RCTGPUImageView *gpuImageView = view;
            UIImage *image = [gpuImageView captureImage];
            if (image) {
                [self.bridge.imageStoreManager storeImage:image withBlock:^(NSString *imageTag) {
                    resolve(imageTag);
                }];
            }
            else {
                reject(@"-1", @"campture failed", nil);
            }
        }
        else {
            reject(@"-2", @"image is not a gpu image", nil);
        }
    });
}

@end

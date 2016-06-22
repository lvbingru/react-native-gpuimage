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
    return [[RCTGPUImageView alloc] init];
}

RCT_EXPORT_VIEW_PROPERTY(params, NSDictionary)

RCT_CUSTOM_VIEW_PROPERTY(image, NSString, RCTGPUImageView)
{
    NSString *image = [RCTConvert NSString:json];
    [self.bridge.imageLoader loadImageWithTag:image callback:^(NSError *error, UIImage *image) {
        if (image) {
            GPUImagePicture *sourcePicture = [[GPUImagePicture alloc] initWithImage:image smoothlyScaleOutput:YES];
            view.sourcePicture = sourcePicture;
        }
    }];
}

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

RCT_CUSTOM_VIEW_PROPERTY(resizeMode, RCTResizeMode, RCTGPUImageView)
{
    RCTResizeMode resizeMode = [RCTConvert RCTResizeMode:json];
    if (resizeMode == RCTResizeModeCover) {
        view.fillMode = kGPUImageFillModePreserveAspectRatioAndFill;
    }
    else if (resizeMode == RCTResizeModeContain) {
        view.fillMode = kGPUImageFillModePreserveAspectRatio;
    }
    else if (resizeMode == RCTResizeModeStretch) {
        view.fillMode = kGPUImageFillModeStretch;
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
            [gpuImageView.filter useNextFrameForImageCapture];
            [gpuImageView.sourcePicture processImage];
            UIImage *image = [gpuImageView.filter imageFromCurrentFramebuffer];
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

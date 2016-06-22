//
//  RCTGPUImageProcessor.m
//  RCTGPUImage
//
//  Created by LvBingru on 6/16/16.
//  Copyright © 2016 erica. All rights reserved.
//

#import "RCTGPUImageProcessor.h"
#import "RCTConvert.h"
#import "RCTImageLoader.h"
#import "RCTLog.h"
#import "RCTUtils.h"
#import "RCTImageStoreManager.h"
#import "GPUImage.h"

@implementation RCTGPUImageProcessor

RCT_EXPORT_MODULE()
@synthesize bridge = _bridge;

RCT_EXPORT_METHOD(processImage:(NSDictionary *)imageInfo
                  resolve:(RCTPromiseResolveBlock)resolve
                  reject:(RCTPromiseRejectBlock)reject)
{
    NSString *imageTag = [RCTConvert NSString:imageInfo[@"image"]];
    NSString *filter = [RCTConvert NSString:imageInfo[@"filter"]];
    NSDictionary *params = [RCTConvert NSDictionary:imageInfo[@"params"]];
    
    [self.bridge.imageLoader loadImageWithTag:imageTag callback:^(NSError *error, UIImage *image) {
        if (error) {
            reject([NSString stringWithFormat:@"%d",(int)error.code],error.description,nil);
            return;
        }
        
        if (image) {
            Class filterClass = NSClassFromString(filter);
            id imageFilter = [filterClass new];
            if ([imageFilter isKindOfClass:[GPUImageFilter class]]) {
                for (NSString *key in params.allKeys) {
                    if ([imageFilter respondsToSelector:NSSelectorFromString(key)]) {
                        [imageFilter setValue:params[key] forKeyPath:key];
                    }
                }
                UIImage *quickFilteredImage = [(GPUImageFilter *)imageFilter imageByFilteringImage:image];
                [self.bridge.imageStoreManager storeImage:quickFilteredImage withBlock:^(NSString *imageTag) {
                    resolve(imageTag);
                }];
            }
            else {
                reject(@"-1", @"no such filter",nil);
            }
        }
    }];
    
}
//GPUImageBrightnessFilter
@end

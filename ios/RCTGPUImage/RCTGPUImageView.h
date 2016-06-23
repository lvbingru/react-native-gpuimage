//
//  RCTGPUImageView.h
//  RCTGPUImage
//
//  Created by LvBingru on 6/21/16.
//  Copyright © 2016 erica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCTImageView.h"
#import "GPUImage.h"

@interface RCTGPUImageView : RCTImageView

@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) NSDictionary *params;

- (UIImage *)captureImage;

@end

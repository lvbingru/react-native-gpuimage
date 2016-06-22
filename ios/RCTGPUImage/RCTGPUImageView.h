//
//  RCTGPUImageView.h
//  RCTGPUImage
//
//  Created by LvBingru on 6/21/16.
//  Copyright © 2016 erica. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface RCTGPUImageView : GPUImageView

@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImagePicture *sourcePicture;
@property (nonatomic, strong) NSDictionary *params;

@end

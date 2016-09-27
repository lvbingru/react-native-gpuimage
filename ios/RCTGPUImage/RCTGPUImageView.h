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
#import "RCTComponent.h"

@interface RCTGPUImageView : RCTImageView

@property (nonatomic, strong) NSArray *filters;
@property (nonatomic, copy) RCTBubblingEventBlock onGetSize;

- (UIImage *)captureImage;

@end

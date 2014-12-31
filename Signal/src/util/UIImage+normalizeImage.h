//
//  UIImage+normalizeImage.h
//  Signal
//
//  Created by Frederic Jacobs on 26/12/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (normalizeImage)

- (UIImage *)normalizedImage;
- (UIImage *)resizedWithQuality:(CGInterpolationQuality)quality rate:(CGFloat)rate;
- (UIImage *)scaledToMaxPixels:(NSInteger)pixels;

@end

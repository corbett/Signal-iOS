//
//  UIImage+normalizeImage.m
//  Signal
//
//  Created by Frederic Jacobs on 26/12/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "UIImage+normalizeImage.h"

@implementation UIImage (normalizeImage)

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){{0, 0}, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}


- (UIImage *)resizedWithQuality:(CGInterpolationQuality)quality rate:(CGFloat)rate {
    UIImage *resized = nil;
    CGFloat width = self.size.width * rate;
    CGFloat height = self.size.height * rate;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, quality);
    [self drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
}

- (UIImage *)scaledToMaxPixels:(NSInteger)pixels {
    UIImage *resized = nil;
    CGFloat scale = 1.0/MAX(self.size.width, self.size.height);
    
    CGFloat width = self.size.width * scale;
    CGFloat height = self.size.height * scale;
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationNone);
    [self drawInRect:CGRectMake(0, 0, width, height)];
    resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resized;
    
}

@end

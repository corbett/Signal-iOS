#import <Foundation/Foundation.h>

@interface MIMETypeUtil : NSObject

+(BOOL) isSupportedVideoMIMEType;
+(BOOL) isSupportedAudioMIMEType;
+(BOOL) isSupportedImageMIMEType;

+(NSString*) getExtensionFromSupportedVideoMIMEType:(NSString*)supportedMIMEType;
+(NSString*) getExtensionFromSupportedAudioMIMEType:(NSString*)supportedMIMEType;
+(NSString*) getExtensionFromSupportedImageMIMEType:(NSString*)supportedMIMEType;


+(NSString*) getMIMETypeFromSupportedVideoExtension:(NSString*)supportedVideoExtension;
+(NSString*) getMIMETypeFromSupportedAudioExtension:(NSString*)supportedAudioExtension;
+(NSString*) getMIMETypeFromSupportedImageExtension:(NSString*)supportedImageExtension;

+(NSString*) getSupportedImageMIMETypeFromImageData:(UIImage*)image;

@end
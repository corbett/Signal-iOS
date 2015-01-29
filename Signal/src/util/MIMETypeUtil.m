#import MIMETypeUtil.h
#import "UIImage+contentTypes.h"
@implementation MIMETypeUtil

NSDictionary *supportedVideoMIMETypesToExtensionTypes = @{@"video/3gpp":@"3gp",
                                                          @"video/3gpp2":@"3g2",
                                                          @"video/mp4":@"mp4",
                                                          @"video/quicktime":@"mov",
                                                          @"video/x-m4v":@"m4v"};
														  
														  
NSDictionary *supportedAudioMIMETypesToExtensionTypes = @{@"audio/x-m4p":@"m4p",
                                                          @"audio/x-m4b":@"m4b",
                                                          @"audio/x-m4a":@"m4a",
                                                          @"audio/wav":@"wav",
                                                          @"audio/x-wav":@"wav",
                                                          @"audio/x-mpeg":@"mp3",
                                                          @"audio/mpeg":@"mp3",
                                                          @"audio/mp4":@"mp4",
                                                          @"audio/mp3":@"mp3",
                                                          @"audio/mpeg3":@"mp3",
                                                          @"audio/x-mp3":@"mp3",
                                                          @"audio/x-mpeg3":@"mp3",
                                                          @"audio/amr":@"amr",
                                                          @"audio/aiff":@"aiff",
                                                          @"audio/x-aiff":@"aiff",
                                                          @"audio/3gpp2":@"3g2",
                                                          @"audio/3gpp":@"3gp"};


NSDictionary *supportedImageMIMETypesToExtensionTypes = @{@"image/jpeg":@"jpeg",
														  @"image/pjpeg":@"jpeg",
														  @"image/png":@"png",
														  @"image/gif":@"gif"
														  @"image/tiff":@"tif",
														  @"image/x-tiff":@"tif",
														  @"image/bmp":@"bmp",
														  @"image/x-windows-bmp":@"bmp"
											
											
NSDictionary *supportedVideoExtensionTypesToMIMETypes = @{@"3gp":@"video/3gpp",
                                                          @"3gpp":@"video/3gpp",
                                                          @"3gp2":@"video/3gpp2",
                                                          @"3gpp2":@"video/3gpp2",
                                                          @"mp4":@"video/mp4",
                                                          @"mov":@"video/quicktime",
                                                          @"mqv":@"video/quicktime",
                                                          @"m4v":@"video/x-m4v"
                                                          };
			  
NSDictionary *supportedAudioExtensionTypesToMIMETypes = @{@"3gp":@"audio/3gpp",
                                                          @"3gpp":"@audio/3gpp",
                                                          @"3g2":@"audio/3gpp2",
                                                          @"3gp2":@"audio/3gpp2",
                                                          @"aiff":@"audio/aiff",
                                                          @"aif":@"audio/aiff",
                                                          @"aifc":@"audio/aiff",
                                                          @"cdda":@"audio/aiff",
                                                          @"amr":@"audio/amr",
                                                          @"mp3":@"audio/mp3",
                                                          @"swa":@"audio/mp3",
                                                          @"mp4":@"audio/mp4",
                                                          @"mpeg":@"audio/mpeg",
                                                          @"mpg":@"audio/mpeg",
                                                          @"wav":@"audio/wav",
                                                          @"bwf":@"audio/wav",
                                                          @"m4a":@"audio/x-m4a",
                                                          @"m4b":@"audio/x-m4b",
                                                          @"m4p":@"audio/x-m4p"
														  };
NSDictionary *supportedImageExtensionTypesToMIMETypes=@{@"png":@"image/png",
														@"x-png":@"image/png",
														@"jfif":@"image/jpeg",
														@"jfif":@"image/pjpeg",
														@"jfif-tbnl":@"image/jpeg",
														@"jpe":@"image/jpeg",
														@"jpe":@"image/pjpeg",
														@"jpeg":@"image/jpeg",
														@"jpg":@"image/jpeg",
														@"gif":@"image/gif",
														@".tif":@"image/tiff",
														@".tiff":@"image/tiff"
														};

#pragma mark uses file extensions or MIME types only
+(BOOL) isSupportedVideoMIMEType:(NSString*)contentType {
    return [supportedVideoMIMETypesToExtensionTypes hasKey:contentType];	
}

+(BOOL) isSupportedAudioMIMEType:(NSString*)contentType {
    return [supportedAudioMIMETypesToExtensionTypes hasKey:contentType];		
}

+(BOOL) isSupportedImageMIMEType:(NSString*)contentType {
    return [supportedImageMIMETypesToExtensionTypes hasKey:contentType];		
}


+(BOOL) isSupportedVideoFile:(NSString*) filePath {
    return [supportedVideoExtensionTypesToMIMETypes hasKey:[filePath pathExtension]];	
}

+(BOOL) isSupportedAudioFile:(NSString*) filePath  {
    return [supportedAudioExtensionTypesToMIMETypes hasKey:[filePath pathExtension]];		
}

+(BOOL) isSupportedImageFile:(NSString*) filePath  {
    return [supportedImageExtensionTypesToMIMETypes hasKey:[filePath pathExtension]];		
}

+(NSString*) getExtensionFromSupportedVideoMIMEType:(NSString*)supportedMIMEType {
    return [supportedVideoExtensionTypesToMIMETypes objectForKey:supportedMIMEType];	
}

+(NSString*) getExtensionFromSupportedAudioMIMEType:(NSString*)supportedMIMEType {
	return [supportedAudioExtensionTypesToMIMETypes objectForKey:supportedMIMEType];	
}

+(NSString*) getExtensionFromSupportedImageMIMEType:(NSString*)supportedMIMEType {
    return [supportedImageExtensionTypesToMIMETypes hasKey:supportedMIMEType];
}


+(NSString*) getMIMETypeFromSupportedVideoFile:(NSString*)supportedVideoFile {
    return [supportedVideoExtensionTypesToMIMETypes objectForKey:[supportedVideoFile filePath]];	
} 

+(NSString*) getMIMETypeFromSupportedAudioFile:(NSString*)supportedAudioFile {
	return [supportedAudioExtensionTypesToMIMETypes objectForKey:[supportedAudioFile filePath]];		
}

+(NSString*) getMIMETypeFromSupportedImageFile:(NSString*)supportedImageFile {
    return [supportedImageExtensionTypesToMIMETypes objectForKey:[supportedImageFile filePath]];	
}

#pragma mark uses bytes
+(NSString*) getSupportedImageMIMETypeFromImage:(UIImage*)image {
	return [image contentType];
}

+(BOOL) getIsSupportedTypeFromImage:(UIImage*)image {
	return [image isSupportedImageType];
}

@end

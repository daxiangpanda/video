//#import "UIImage+Enhancement.h"
//#import "VTMacros.h"
//#import <ImageIO/ImageIO.h>
//#import <GPUImage/GPUImage.h>
//
//#if __has_feature(objc_arc)
//#define toCF (__bridge CFTypeRef)
//#define fromCF (__bridge id)
//#else
//#define toCF (CFTypeRef)
//#define fromCF (id)
//#endif
//
//#define BLOCK_EXEC(block, ...)                                                 \
//  if (block) {                                                                 \
//    block(__VA_ARGS__);                                                        \
//  };
//
//@implementation UIImage (Enhancement)
//
//static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source,
//                                            size_t const i) {
//  int delayCentiseconds = 1;
//  CFDictionaryRef const properties =
//      CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
//  if (properties) {
//    CFDictionaryRef const gifProperties =
//        CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
//    if (gifProperties) {
//      NSNumber *number = fromCF CFDictionaryGetValue(
//          gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
//      if (number == NULL || [number doubleValue] == 0) {
//        number = fromCF CFDictionaryGetValue(gifProperties,
//                                             kCGImagePropertyGIFDelayTime);
//      }
//      if ([number doubleValue] > 0) {
//        // Even though the GIF stores the delay as an integer number of
//        // centiseconds, ImageIO “helpfully” converts that to seconds for us.
//        delayCentiseconds = (int)lrint([number doubleValue] * 100);
//      }
//    }
//    CFRelease(properties);
//  }
//  return delayCentiseconds;
//}
//
//static void createImagesAndDelays(CGImageSourceRef source, size_t count,
//                                  CGImageRef imagesOut[count],
//                                  int delayCentisecondsOut[count]) {
//  for (size_t i = 0; i < count; ++i) {
//    imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
//    delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
//  }
//}
//
//static int sum(size_t const count, int const *const values) {
//  int theSum = 0;
//  for (size_t i = 0; i < count; ++i) {
//    theSum += values[i];
//  }
//  return theSum;
//}
//
//static int pairGCD(int a, int b) {
//  if (a < b)
//    return pairGCD(b, a);
//  while (true) {
//    int const r = a % b;
//    if (r == 0)
//      return b;
//    a = b;
//    b = r;
//  }
//}
//
//static int vectorGCD(size_t const count, int const *const values) {
//  int gcd = values[0];
//  for (size_t i = 1; i < count; ++i) {
//    // Note that after I process the first few elements of the vector, `gcd`
//    // will probably be smaller than any remaining element.  By passing the
//    // smaller value as the second argument to `pairGCD`, I avoid making it swap
//    // the arguments.
//    gcd = pairGCD(values[i], gcd);
//  }
//  return gcd;
//}
//
//static NSArray *frameArray(size_t const count, CGImageRef const images[count],
//                           int const delayCentiseconds[count],
//                           int const totalDurationCentiseconds) {
//  int const gcd = vectorGCD(count, delayCentiseconds);
//  size_t const frameCount = totalDurationCentiseconds / gcd;
//  UIImage *frames[frameCount];
//  for (size_t i = 0, f = 0; i < count; ++i) {
//    UIImage *const frame = [UIImage imageWithCGImage:images[i]
//                                               scale:[UIScreen mainScreen].scale
//                                         orientation:UIImageOrientationUp];
//    for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
//      frames[f++] = frame;
//    }
//  }
//  return [NSArray arrayWithObjects:frames count:frameCount];
//}
//
//static void releaseImages(size_t const count, CGImageRef const images[count]) {
//  for (size_t i = 0; i < count; ++i) {
//    CGImageRelease(images[i]);
//  }
//}
//
//static UIImage *
//animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source) {
//  size_t const count = CGImageSourceGetCount(source);
//  CGImageRef images[count];
//  int delayCentiseconds[count]; // in centiseconds
//  createImagesAndDelays(source, count, images, delayCentiseconds);
//  int const totalDurationCentiseconds = sum(count, delayCentiseconds);
//  NSArray *const frames =
//      frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
//  UIImage *const animation = [UIImage
//      animatedImageWithImages:frames
//                     duration:(NSTimeInterval)totalDurationCentiseconds /
//                              100.0];
//  releaseImages(count, images);
//  return animation;
//}
//
//static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(
//    CGImageSourceRef CF_RELEASES_ARGUMENT source) {
//  if (source) {
//    UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
//    CFRelease(source);
//    return image;
//  } else {
//    return nil;
//  }
//}
//
//+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data {
//  return animatedImageWithAnimatedGIFReleasingImageSource(
//      CGImageSourceCreateWithData(toCF data, NULL));
//}
//
//+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url {
//  return animatedImageWithAnimatedGIFReleasingImageSource(
//      CGImageSourceCreateWithURL(toCF url, NULL));
//}
//
//+ (void)roundedImage:(UIImage *)image
//          expectSize:(CGSize)resize
//           fillColor:(UIColor *)color
//          completion:(void (^)(UIImage *image))completion {
//
//  dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//    UIImage *tempImage;
//
//    UIGraphicsBeginImageContextWithOptions(resize, NO, 0);
//
//    CGRect rect = CGRectMake(0, 0, resize.width, resize.height);
//
//    [color setFill];
//
//    UIRectFill(rect);
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
//
//    [path addClip];
//
//    [image drawInRect:rect];
//
//    tempImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//      BLOCK_EXEC(completion, tempImage);
//    });
//
//  });
//}
//
//+ (void)roundedImageNamed:(NSString *)name
//               expectSize:(CGSize)resize
//                fillColor:(UIColor *)color
//               completion:(void (^)(UIImage *image))completion {
//
//  dispatch_async(dispatch_get_global_queue(0, 0), ^{
//
//    UIImage *image = [UIImage imageNamed:name];
//
//    UIGraphicsBeginImageContextWithOptions(resize, NO, 0);
//
//    CGRect rect = CGRectMake(0, 0, resize.width, resize.height);
//
//    [color setFill];
//
//    UIRectFill(rect);
//
//    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
//
//    [path addClip];
//
//    [image drawInRect:rect];
//
//    image = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//      BLOCK_EXEC(completion, image);
//    });
//
//  });
//}
//
//+ (UIImage *)Base64StrToUIImage:(NSString *)encodedImageStr
//{
//    if (encodedImageStr.length < 1) {
//        return [UIImage imageWithColor:[UIColor blackColor] size:CGSizeMake(80, 90)];
//    }
//    NSData *decodedImageData   = [[NSData alloc] initWithBase64EncodedString:encodedImageStr options:NSDataBase64DecodingIgnoreUnknownCharacters];
//    UIImage *decodedImage      = [UIImage imageWithData:decodedImageData];
//    return decodedImage;
//}
//
//
//
//+ (UIImage *)combineImage:(UIImage *)base withImage:(UIImage *)upper {
//  UIImage *resultImage;
//  UIGraphicsBeginImageContext(base.size);
//  [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//  [[UIImage compressedWithImage:upper scaledToSize:base.size]
//      drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//  resultImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//  return resultImage;
//}
//
//+ (void )combineImage:(UIImage *)base withImage:(UIImage *)upper completion:(void (^)(UIImage *image))completion {
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        UIGraphicsBeginImageContext(base.size);
//        [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//        [[UIImage compressedWithImage:upper scaledToSize:base.size]
//         drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        dispatch_async(dispatch_get_main_queue(), ^{
//            BLOCK_EXEC(completion, resultImage);
//        });
//    });
//}
//
//+ (UIImage *)combineImage:(UIImage *)base withFirstImage:(UIImage *)first withSecondImage:(UIImage *)second{
//    UIImage *resultImage;
//    UIGraphicsBeginImageContext(base.size);
//    [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//    [[UIImage compressedWithImage:first scaledToSize:base.size]
//     drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//    [[UIImage compressedWithImage:second scaledToSize:base.size]
//     drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//    resultImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return resultImage;
//}
//
//
//+ (void )combineImage:(UIImage *)base withFirstImage:(UIImage *)first withSecondImage:(UIImage *)second completion:(void (^)(UIImage *image))completion {
//    
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//        UIGraphicsBeginImageContext(base.size);
//        [base drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//        [[UIImage compressedWithImage:first scaledToSize:base.size]
//         drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//        [[UIImage compressedWithImage:second scaledToSize:base.size]
//         drawInRect:CGRectMake(0, 0, base.size.width, base.size.height)];
//        UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            BLOCK_EXEC(completion, resultImage);
//        });
//    });
//    
//}
//
//
//+ (UIImage *)compressedWithImage:(UIImage *)image scaledToSize:(CGSize)size {
//  UIGraphicsBeginImageContext(size);
//  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//  return newImage;
//}
//
//+ (UIImage *)compressedWithImage:(UIImage *)image scale:(float)scale {
//    CGSize size = image.size;
//    CGFloat width = size.width;
//    CGFloat height = size.height;
//    CGFloat scaledWidth = width * scale;
//    CGFloat scaledHeight = height * scale;
//    CGSize scaleSize = CGSizeMake(scaledWidth, scaledHeight);
//    UIGraphicsBeginImageContext(scaleSize);
//    [image drawInRect:CGRectMake(0, 0, scaledWidth, scaledHeight)];
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return newImage;
//}
//
//+ (UIImage *)compressImage:(UIImage *)image {
//  // expected size
//  CGSize size;
//
//  float expectedWH = 50;
//  if (image.size.width > image.size.height) {
//    float height = expectedWH * image.size.height / image.size.width;
//    size = CGSizeMake(expectedWH, height);
//  } else {
//    float width = expectedWH * image.size.width / image.size.height;
//    size = CGSizeMake(width, expectedWH);
//  }
//
//  // compress image
//  UIGraphicsBeginImageContext(size);
//  [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//  return newImage;
//}
//
//+ (UIImage *)createBackgroundImageWithImageName:(NSString *)imageName
//                                     edgeInsets:(UIEdgeInsets)insets {
//  return [[UIImage imageNamed:imageName] resizableImageWithCapInsets:insets];
//}
//
//+ (UIImage *)circularScaleAndCropImage:(UIImage *)image size:(CGSize)size {
//  // This function returns a newImage, based on image, that has been:
//  // - scaled to fit in (CGRect) rect
//  // - and cropped within a circle of radius: rectWidth/2
//
//  CGSize cropSize = CGSizeMake(MIN(70, size.width), MIN(70, size.height));
//
//  // Create the bitmap graphics context
//  UIGraphicsBeginImageContextWithOptions(
//      CGSizeMake(cropSize.width, cropSize.height), NO, 0.0);
//  CGContextRef context = UIGraphicsGetCurrentContext();
//  CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
//  CGContextSetAllowsAntialiasing(context, true);
//  CGContextSetShouldAntialias(context, true);
//
//  // Get the width and heights
//  CGFloat imageWidth = image.size.width;
//  CGFloat imageHeight = image.size.height;
//  CGFloat rectWidth = cropSize.width;
//  CGFloat rectHeight = cropSize.height;
//
//  // Calculate the scale factor
//  CGFloat scaleFactorX = rectWidth / imageWidth;
//  CGFloat scaleFactorY = rectHeight / imageHeight;
//
//  // Calculate the centre of the circle
//  CGFloat imageCentreX = rectWidth / 2;
//  CGFloat imageCentreY = rectHeight / 2;
//
//  // Create and CLIP to a CIRCULAR Path
//  // (This could be replaced with any closed path if you want a different shaped
//  // clip)
//  CGFloat radius = rectWidth / 2;
//  CGContextBeginPath(context);
//  CGContextAddArc(context, imageCentreX, imageCentreY, radius, 0, 2 * M_PI, 0);
//  CGContextClosePath(context);
//  CGContextClip(context);
//
//  // Set the SCALE factor for the graphics context
//  // All future draw calls will be scaled by this factor
//  CGContextScaleCTM(context, scaleFactorX, scaleFactorY);
//
//  // Draw the IMAGE
//  CGRect myRect = CGRectMake(0, 0, imageWidth, imageHeight);
//  [image drawInRect:myRect];
//
//  UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//  UIGraphicsEndImageContext();
//
//  return newImage;
//}
//
//- (UIImage *)croppedImage:(CGRect)bounds {
//  CGFloat scale = MAX(self.scale, 1.0f);
//  CGRect scaledBounds =
//      CGRectMake(bounds.origin.x * scale, bounds.origin.y * scale,
//                 bounds.size.width * scale, bounds.size.height * scale);
//  CGImageRef imageRef =
//      CGImageCreateWithImageInRect([self CGImage], scaledBounds);
//  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef
//                                              scale:scale
//                                        orientation:UIImageOrientationUp];
//  CGImageRelease(imageRef);
//
//  return croppedImage;
//}
//
//+ (UIImage *_Nullable)thumbnailImageForVideo:(NSURL *_Nonnull)videoURL atTime:(NSTimeInterval)time {
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    NSParameterAssert(asset);
//    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
//    assetImageGenerator.appliesPreferredTrackTransform = YES;
//    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
//    
//    CGImageRef thumbnailImageRef = NULL;
//    CFTimeInterval thumbnailImageTime = time;
//    NSError *thumbnailImageGenerationError = nil;
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
//    
//    if(!thumbnailImageRef)
//        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
//    
//    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
//    
//    return thumbnailImage;
//}
//
//+ (UIImage *_Nonnull)imageWithColor:(UIColor *)color size:(CGSize)size {
//    UIImage *image;
//    CGRect rect = CGRectMake(0, 0, size.width, size.height);
//    UIGraphicsBeginImageContext(size);
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    CGContextSetFillColorWithColor(context, color.CGColor);
//    CGContextFillRect(context, rect);
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    return image;
//}
//
//+ (UIImage *_Nullable)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*_Nullable)image {
//    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
//    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGRect area = CGRectMake(0, 0, image.size.width, image.size.height);
//    
//    CGContextScaleCTM(ctx, 1, -1);
//    CGContextTranslateCTM(ctx, 0, -area.size.height);
//    
//    CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
//    
//    CGContextSetAlpha(ctx, alpha);
//    
//    CGContextDrawImage(ctx, area, image.CGImage);
//    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//    
//    UIGraphicsEndImageContext();
//    
//    return newImage;
//}
//
//@end

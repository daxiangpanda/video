#import <UIKit/UIKit.h>

typedef void (^CombineBlock)(UIImage *_Nullable image);


@interface UIImage (Enhancement)

///**
// UIImage (animatedGIF)
//
// This category adds class methods to `UIImage` to create an animated `UIImage`
// from an animated GIF.
// */
//
///*
// UIImage *animation = [UIImage animatedImageWithAnimatedGIFData:theData];
//
// I interpret `theData` as a GIF.  I create an animated `UIImage` using the
// source images in the GIF.
//
// The GIF stores a separate duration for each frame, in units of centiseconds
// (hundredths of a second).  However, a `UIImage` only has a single, total
// `duration` property, which is a floating-point number.
//
// To handle this mismatch, I add each source image (from the GIF) to `animation`
// a varying number of times to match the ratios between the frame durations in
// the GIF.
//
// For example, suppose the GIF contains three frames.  Frame 0 has duration 3.
// Frame 1 has duration 9.  Frame 2 has duration 15.  I divide each duration by
// the greatest common denominator of all the durations, which is 3, and add each
// frame the resulting number of times.  Thus `animation` will contain frame 0 3/3
// = 1 time, then frame 1 9/3 = 3 times, then frame 2 15/3 = 5 times.  I set
// `animation.duration` to (3+9+15)/100 = 0.27 seconds.
// */
//+ (UIImage *_Nonnull)animatedImageWithAnimatedGIFData:(NSData *_Nonnull)theData;
//
///*
// UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:theURL];
//
// I interpret the contents of `theURL` as a GIF.  I create an animated `UIImage`
// using the source images in the GIF.
//
// I operate exactly like `+[UIImage animatedImageWithAnimatedGIFData:]`, except
// that I read the data from `theURL`.  If `theURL` is not a `file:` URL, you
// probably want to call me on a background thread or GCD queue to avoid blocking
// the main thread.
// */
//+ (UIImage *_Nonnull)animatedImageWithAnimatedGIFURL:(NSURL *_Nonnull)theURL;
//
//+ (void)roundedImage:(UIImage *_Nonnull)image
//          expectSize:(CGSize)resize
//           fillColor:(UIColor *_Nonnull)color
//          completion:(void (^_Nonnull)(UIImage *_Nonnull image))completion;
//
//+ (void)roundedImageNamed:(NSString *_Nonnull)name
//               expectSize:(CGSize)size
//                fillColor:(UIColor *_Nonnull)color
//               completion:(void (^_Nonnull)(UIImage *_Nonnull image))completion;
//
//+ (UIImage *_Nonnull)compressImage:(UIImage *_Nonnull)image;
//
//+ (UIImage *_Nonnull)compressedWithImage:(UIImage *_Nonnull)image
//                            scaledToSize:(CGSize)size;
//
//+ (UIImage *_Nonnull)compressedWithImage:(UIImage *_Nonnull)image
//                                   scale:(float)scale;
//
//+ (UIImage *_Nonnull)createBackgroundImageWithImageName:(NSString *_Nonnull)imageName edgeInsets:(UIEdgeInsets)insets;
//
//+ (UIImage *_Nonnull)circularScaleAndCropImage:(UIImage *_Nonnull)image size:(CGSize)size;
//
//+ (UIImage *_Nonnull)combineImage:(UIImage *_Nonnull)base withImage:(UIImage *_Nonnull)upper;
//
//+ (void)combineImage:(UIImage *_Nonnull)base withImage:(UIImage *_Nonnull)upper completion:(_Nullable CombineBlock) completion;
//
//+ (UIImage *_Nonnull)combineImage:(UIImage *_Nonnull)base withFirstImage:(UIImage *_Nonnull)first withSecondImage:(UIImage *_Nonnull)second;
//
//- (UIImage *_Nullable)croppedImage:(CGRect)bounds;
//
//+ (UIImage *_Nullable) thumbnailImageForVideo:(NSURL *_Nonnull)videoURL atTime:(NSTimeInterval)time;
//
//+ (UIImage *_Nonnull)imageWithColor:(UIColor *_Nonnull)color size:(CGSize)size;
//
//+ (UIImage *_Nullable)Base64StrToUIImage:(NSString *_Nullable)encodedImageStr;
//
//+ (UIImage *_Nullable)imageByApplyingAlpha:(CGFloat)alpha  image:(UIImage*_Nullable)image;

@end






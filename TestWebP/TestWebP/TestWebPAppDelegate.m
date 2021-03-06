//
//  TestWebPAppDelegate.m
//  TestWebP
//
// Created by Carson McDonald on 06/01/2011.
// Copyright 2011 Carson McDonald. See LICENSE file.
//

#import "TestWebPAppDelegate.h"

#import <WebP/decode.h>

@interface TestWebPAppDelegate (Private)
- (void)displayImage:(NSString *)filePath;
@end

@implementation TestWebPAppDelegate

@synthesize testImageView;
@synthesize imagePickerView;
@synthesize imageScrollView;
@synthesize window=_window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window makeKeyAndVisible];
    
    webpImages = [[[NSBundle mainBundle] pathsForResourcesOfType:@"webp" inDirectory:nil] retain];
    [self displayImage:[webpImages objectAtIndex:0]];
    
    return YES;
}

- (void)dealloc
{
    [testImageView release];
    [_window release];
    [imagePickerView release];
    [webpImages release];
    [imageScrollView release];
    [super dealloc];
}

#pragma mark - WebP example

/*
 This gets called when the UIImage gets collected and frees the underlying image.
 */
static void free_image_data(void *info, const void *data, size_t size)
{
    free((void *)data);
}

- (void)displayImage:(NSString *)filePath 
{
    // Find the path of the selected WebP image in the bundle and read it into memory
    NSData *myData = [NSData dataWithContentsOfFile:filePath];
    
    // Get the current version of the WebP decoder
    int rc = WebPGetDecoderVersion();
    
    NSLog(@"Version: %d", rc);
    
    // Get the width and height of the selected WebP image
    int width = 0;
    int height = 0;
    WebPGetInfo([myData bytes], [myData length], &width, &height);
    
    NSLog(@"Image Width: %d Image Height: %d", width, height); 
    
    // Decode the WebP image data into a RGBA value array
    uint8_t *data = WebPDecodeRGBA([myData bytes], [myData length], &width, &height);
    
    // Construct a UIImage from the decoded RGBA value array
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, width*height*4, free_image_data);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault; 
    CGImageRef imageRef = CGImageCreate(width, height, 8, 32, 4*width, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
    UIImage *newImage = [[UIImage imageWithCGImage:imageRef] retain];
    
    // Set the image into the image view and make image view and the scroll view to the correct size
    self.testImageView.bounds = CGRectMake(0, 0, width, height);
    self.testImageView.image = newImage;
    
    [imageScrollView setContentSize:testImageView.bounds.size];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    
    [newImage release];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [webpImages count];
}

#pragma mark - UIPickerViewDelegate 

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[webpImages objectAtIndex:row] componentsSeparatedByString:@"/"] lastObject];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self displayImage:[webpImages objectAtIndex:row]];
}

@end

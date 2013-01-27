//
//  RWViewController.m
//  TestMetaData
//
//  Copyright (c) 2013 foundry. Feel free to copy.
//

#import "RWViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>

@interface RWViewController ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic,weak) IBOutlet UIImageView* imageView;
@end

@implementation RWViewController

- (void) imagePickerImage:(UIImage*)image info:(NSDictionary*)info
{
    self.imageView.image = image;
    
    NSLog (@"info %@",info);
        
    if ([[info allKeys] containsObject:UIImagePickerControllerReferenceURL]){
        NSLog (@"photolibrary pic");
        [self logMetaDataFromAssetLibrary:info];
    } else if ([[info allKeys] containsObject:UIImagePickerControllerMediaMetadata]){
        NSLog (@"camera pic");
        [self logMetaDataFromCamera:info];
    }
   [self logMetaDataFromImage:self.imageView.image];
    NSLog (@"image.imageOrientation %d",image.imageOrientation);
}

- (IBAction)imageFromBundle:(id)sender {
    NSString* path = [NSBundle pathForResource:@"IMG_2291" ofType:@"JPG" inDirectory:[[NSBundle mainBundle] resourcePath]];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [self logMetaDataFromData:data];
    
    UIImage* image = [UIImage imageNamed:@"IMG_2291.JPG"];
    [self logMetaDataFromImage:image];
    self.imageView.image = image;
    NSLog (@"image.imageOrientation %d",image.imageOrientation);
    
}

- (IBAction)imageFromURL:(id)sender {
    
    [[self spinner] startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL* url = [NSURL URLWithString:@"https://raw.github.com/foundry/UIImageMetadata/master/UIImageMetadata/IMG_2291.JPG"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self logMetaDataFromData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            UIImage *image = [[UIImage alloc] initWithData:data];
            self.imageView.image = image;
            [self logMetaDataFromImage:image];
            NSLog (@"image.imageOrientation %d",image.imageOrientation);
            [[self spinner] stopAnimating];
        });
    });
}


- (void) logMetaDataFromCamera:(NSDictionary*)info
{
    NSMutableDictionary *imageMetadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
    NSLog (@"imageMetaData %@",imageMetadata);
}

- (void) logMetaDataFromAssetLibrary:(NSDictionary*)info
{
    NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library assetForURL:assetURL
             resultBlock:^(ALAsset *asset)  {
                NSMutableDictionary *imageMetadata = nil;
                NSDictionary *metadata = asset.defaultRepresentation.metadata;
                imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:metadata];
                NSLog (@"imageMetaData %@",imageMetadata);
             }
            failureBlock:^(NSError *error) {
                NSLog (@"error %@",error);
            }];
}



- (void) logMetaDataFromData:(NSData*)data
{
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    NSLog (@"metadata from NSData %@",imageMetaData);
 
}

- (void) logMetaDataFromImage:(UIImage*)image
{
    NSData *jpeg = [NSData dataWithData:UIImageJPEGRepresentation(image, 1.0)];
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
    CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
    NSLog (@"metadata from UIImage %@",imageMetaData);
}
- (void)viewDidUnload {
    [self setSpinner:nil];
    [super viewDidUnload];
}
@end






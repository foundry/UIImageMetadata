    //
    //  CVImagePickerControl.h
    //  OpenCVSquares
    //
    //  Created by Washe / Foundry on 06/01/2013.
    //  Copyright (c) 2013 foundry. Feel free to copy.
    //
    // CVImagePickerSegmentedControl presents a 2-button segmented controller and contains all methods required to present and dismiss a camera or photolibrary picker, passing the selected image up to its delegate. The delegate should normally be a UIViewController, as we delegate the actual presenting and dismissing.

/*
 usage  CVImagePickerSegmentedControl* ipSC = [[CVImagePickerSegmentedControl alloc] init];
 [ipSC setDelegate:self];
 
 */


#import <UIKit/UIKit.h>
@class UISegmentedControl;

@protocol CVImagePickerSegmentedControlDelegate

@required
- (void) imagePickerImage:(UIImage*)image info:(NSDictionary*)info;

    //we don't need to implement these in the delegate if we are controlling the presenting and dismissing from this class, but they do need to be present in the delegate as methods to override (i.e. the delegate needs to be a UIViewController)
- (void) presentViewController:(UIViewController *)viewControllerToPresent
                      animated:(BOOL)flag
                    completion:(void (^)(void))completion;
- (void) dismissViewControllerAnimated:(BOOL)flag
                            completion:(void (^)(void))completion;
@optional
- (void) presentViewController:(UIImagePickerController*)imagePicker;
- (void) dismissViewController;

@end

@interface CVImagePickerSegmentedControl : UISegmentedControl <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, weak) IBOutlet id <CVImagePickerSegmentedControlDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> delegate;

@property (nonatomic, assign) UIModalTransitionStyle transitionStyle;
    //defaults to UIModalTransitionStyleCoverVertical if not set

@property (nonatomic, assign) BOOL imagePickerControlsPresenting;
@property (nonatomic, assign) BOOL imagePickerControlsDismissing;


@end

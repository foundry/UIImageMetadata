__UIImage Metadata__

A very basic iPhone project to explore various methods of reading (jpeg) image metadata. 

Image obtained from four sources:  

- Jpg file in the application bundle  
- Jpg file stored online  
- Photo library via a UIImagePickerController  
- Camera via a UIImagePickerController

Run the application and watch the logs to see how metadata is read from these sources.  Note that metadata read from a UIImage is a small subset of the metadata stored with the original file. 

Also take a look at the 'Orientation' metadata key (kCGImagePropertyOrientation
). Note that it _differs_ from the UIImage.imageOrientation property value. See my answer to this Stack Overflow question: [Force UIImagePickerController to take photo in portrait orientation/dimensions iOS](http://stackoverflow.com/questions/14484816/force-uiimagepickercontroller-to-take-photo-in-portrait-orientation-dimensions-i)


-----
  
__How to obtain _all_ of the metadata from a UIImage resource__

If we obtain a photo from the UIImagePickerController, we can get a detailed dictionary of metadata.

      // From the camera:

		- (void) logMetaDataFromCamera:(NSDictionary*)info
		{
		    NSDictionary *imageMetadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
		    NSLog (@"imageMetaData %@",imageMetadata);
		}
		
		
      //From the Photo Library 
      
      #import <AssetsLibrary/AssetsLibrary.h>

		- (void) logMetaDataFromAssetLibrary:(NSDictionary*)info
		{
		    
			NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
		    
			ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
			[library assetForURL:assetURL 
					 resultBlock:^(ALAsset *asset)  {
						NSDictionary *imageMetaData = asset.defaultRepresentation.metadata;
		     			NSLog (@"imageMetaData %@",imageMetadata);
		     		 }
		            failureBlock:nil];
		}
		
		//NSLog:
		
		imageMetaData {
		    ColorModel = RGB;
		    DPIHeight = 72;
		    DPIWidth = 72;
		    Depth = 8;
		    Orientation = 6;
		    PixelHeight = 2448;
		    PixelWidth = 3264;
		    "{Exif}" =     {
		        ApertureValue = "2.526069";
		        BrightnessValue = "-2.615439";
		        ColorSpace = 1;
		        ComponentsConfiguration =         (
		            1,
		            2,
		            3,
		            0
		        );
		        DateTimeDigitized = "2012:12:23 17:58:45";
		        DateTimeOriginal = "2012:12:23 17:58:45";
		        ExifVersion =         (
		            2,
		            2,
		            1
		        );
		        ExposureMode = 0;
		        ExposureProgram = 2;
		        ExposureTime = "0.06666667";
		        FNumber = "2.4";
		        Flash = 16;
		        FlashPixVersion =         (
		            1,
		            0
		        );
		        FocalLenIn35mmFilm = 35;
		        FocalLength = "4.28";
		        ISOSpeedRatings =         (
		            800
		        );
		        MeteringMode = 5;
		        PixelXDimension = 3264;
		        PixelYDimension = 2448;
		        SceneCaptureType = 0;
		        SensingMethod = 2;
		        Sharpness = 0;
		        ShutterSpeedValue = "3.906905";
		        SubjectArea =         (
		            1631,
		            1223,
		            881,
		            881
		        );
		        WhiteBalance = 0;
		    };
		    "{TIFF}" =     {
		        DateTime = "2012:12:23 17:58:45";
		        Make = Apple;
		        Model = "iPhone 4S";
		        Orientation = 6;
		        ResolutionUnit = 2;
		        Software = "5.1.1";
		        XResolution = 72;
		        YResolution = 72;
		        "_YCbCrPositioning" = 1;
		    };
		}
		
However, if we attempt to extract metadata directly from a UIImage, we get an impoverished result:  

      #import <ImageIO/ImageIO.h>

		- (NSDictionary*) logMetaDataFromImage:(UIImage*)image
		{
		    NSData *jpeg = [NSData dataWithData:UIImagePNGRepresentation(image, 1.0)];
		    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)jpeg, NULL);
		    CFDictionaryRef imageMetaData = CGImageSourceCopyPropertiesAtIndex(source,0,NULL);
		    NSLog (@"imageMetaData %@",imageMetaData);
		}
		
		//NSLog:
		
	    imageMetaData {
		    ColorModel = RGB;
		    Depth = 8;
		    Orientation = 6;
		    PixelHeight = 2448;
		    PixelWidth = 3264;
		    "{Exif}" =     {
		        ColorSpace = 1;
		        PixelXDimension = 3264;
		        PixelYDimension = 2448;
		    };
		    "{JFIF}" =     {
		        DensityUnit = 0;
		        JFIFVersion =         (
		            1,
		            1
		        );
		        XDensity = 1;
		        YDensity = 1;
		    };
		    "{TIFF}" =     {
		        Orientation = 6;
		    };
    	}

The full metadata in an image _file_ can be far richer than the data obtained from a UIImage _object_ derived from the file. If you want to retain all of the metadata, you need to read the file data object as data, not as UIImage.


This will yield the complete metadata:

	     NSString* path = [NSBundle pathForResource:@"IMG_2379" 
	                                         ofType:@"JPG" 
	                                    inDirectory:[[NSBundle mainBundle] resourcePath]];
	     NSData *data = [NSData dataWithContentsOfFile:path];
	     [self logMetaDataFromData:data];

This will yield UIImage's subset of the image metadata:
    
	    UIImage* image = [UIImage imageNamed:@"IMG_2379.JPG"];
	    [self logMetaDataFromImage:image];

Similarly, to obtain full metadata from an online image:

	    NSURL* url = [NSURL URLWithString:@"http://www.ellipsis.com/IMG_0003.JPG"];
	    NSData *data = [NSData dataWithContentsOfURL:url];
	    [self logMetaDataFromData:data];

Improverished `UIImage` subset:

	    UIImage *image = [[UIImage alloc] initWithData:data];
	    self.imageView.image = image;
	    [self logMetaDataFromImage:image];



 
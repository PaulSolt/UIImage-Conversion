UIImage Conversion Sample
-------------------------
Paul Solt 2010

Here's a sample project and code to convert between UIImage objects and RGBA8 bitmaps. The sample project is iPhone 4/iPad 3.2 compatible. 

The ImageHelper works with iPhone 4 and the Retina display using the correct scale factor with high resolution images.


Basic Example Usage showing the ability to convert back and forth between formats: 
---------------------------------------------------------------------------------

// Look at the sample project for actual usage

	NSString *path = (NSString*)[[NSBundle mainBundle] pathForResource:@"Icon4" ofType:@"png"];
	UIImage *image = [UIImage imageWithContentsOfFile:path]; 
	int width = image.size.width;
	int height = image.size.height;
	
	// Create a bitmap
	unsigned char *bitmap = [ImageHelper convertUIImageToBitmapRGBA8:image];
	
	// Create a UIImage using the bitmap
	UIImage *imageCopy = [ImageHelper convertBitmapRGBA8ToUIImage:bitmap withWidth:width withHeight:height];
	
	// Display the image copy on the GUI
	UIImageView *imageView = [[UIImageView alloc] initWithImage:imageCopy];

	// Cleanup
	free(bitmap);

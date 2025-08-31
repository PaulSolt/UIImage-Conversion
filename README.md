UIImage Conversion Sample
-------------------------
Paul Solt 2010

Here's a sample project and code to convert between UIImage objects and RGBA8 bitmaps. The sample project is iPhone 4/iPad 3.2 compatible. 

The ImageHelper works with iPhone 4 and the Retina display using the correct scale factor with high resolution images.

UPDATE: (8-31-2025)
----

If you're supporting an app created on Intel-based PC's, you'll need to set the correct endianess as ARM-based Apple Silicon is reversed.

I had to be more explicit to return to the previous behavior, since the new defaults put bytes in the reverse order.

My rendering of genetic algorithms using this logic broke when I compiled for the first time on Apple Silicon. I use this in [Artwork Evolution](https://www.artworkevolution.com/artwork-evolution-1)

<img src="[images/NumberGuessingGame.png](https://github.com/user-attachments/assets/1c7a5851-703f-485a-aec2-56815b611b3b)" alt="" style="width: 250px;"/>


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

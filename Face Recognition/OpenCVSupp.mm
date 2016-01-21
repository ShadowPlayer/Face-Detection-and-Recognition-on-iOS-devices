//
//  UIImageCVMatConversion.m
//  Face Recognition 
//
//  Created by Zheyu Zhuang on 14/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import "OpenCVSupp.h"

@implementation UIImage (openCV)

#pragma mark CV and iOS configuration section
// converting the iOS pic format UIImage to common CV::Mat format
// The Code of this seciton is modified based on openCV Website under
// opensource liscense : http://docs.opencv.org/2.4/doc/tutorials/ios/image_manipulation/image_manipulation.html

// converting to color, UIImage to Mat
- (cv::Mat)cvMatFromUIImage{ // converting to color
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    return cvMat;
}

- (cv::Mat)cvMatGreyFromUIImage{ // converting to color
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(self.CGImage);
    CGFloat cols = self.size.width;
    CGFloat rows = self.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), self.CGImage);
    CGContextRelease(contextRef);
    cv::Mat origionalGreyPicMat;
    cv::cvtColor(cvMat, origionalGreyPicMat, CV_BGR2GRAY);
    return origionalGreyPicMat;
}

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat // Class method to convert CVMat to UIImage
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

- (cv::Mat) uniformAndNormalizeImages{
    cv::Mat greyImgMat = [self cvMatGreyFromUIImage];
    cv::Mat greyImgMat_50X50, normalizedGreyImgMat_50X50;
    if (greyImgMat.rows!= 50 || greyImgMat.cols != 50) {
        // reduce the resolution of input pic for EigenFace Processing
        cv::resize(greyImgMat, greyImgMat_50X50, cvSize(50,50));
    }else{
        greyImgMat_50X50 = greyImgMat;
    }
    cv::normalize(greyImgMat_50X50,normalizedGreyImgMat_50X50,0, 255, cv::NORM_MINMAX, CV_8UC1);
    return normalizedGreyImgMat_50X50;
}

-(NSMutableDictionary *) faceDetectWithCompressScale:(int)compressScale {
    NSMutableArray *detectedFacesArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *imgAndFaces = [[NSMutableDictionary alloc] initWithCapacity:2];
    cv::CascadeClassifier faceDetector;
    if (self) {
        //*********************** Opencv Seciton ***********************
        cvSetErrMode(CV_ErrModeParent);//error handler
        //converting the origional UIImage to gray scale;
        cv::Mat origionalPicMat = [self cvMatFromUIImage];
        cv::Mat origionalGreyPicMat = [self cvMatGreyFromUIImage];
        cv::Mat scaledGrayPicMat;
        // reduce the resolution of input pic for faster processing
        cv::resize(origionalGreyPicMat, scaledGrayPicMat, cvSize(origionalGreyPicMat.cols/compressScale,origionalGreyPicMat.rows/compressScale));
        //loading haarcascade file
        NSString* cascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt2" ofType:@"xml"];
        faceDetector.load([cascadePath UTF8String]);//To convert the NSString object to std::string. UTF8String method is used to returns a null-terminated UTF-8 representation of the NSString object.
        
        //detect face
        int minimalface = scaledGrayPicMat.rows/10;
        std::vector<cv::Rect> detectedFaces;
        faceDetector.detectMultiScale(scaledGrayPicMat, detectedFaces, 1.1, 2, 0, cv::Size(minimalface, minimalface));
        int detectedNum = (int) detectedFaces.size();
        NSLog(@" \n detected Number = %d ", detectedNum);
            for(unsigned int i = 0; i < detectedFaces.size(); i++)
            {
                const cv::Rect& face = detectedFaces[i];
                // Get top-left and bottom-right corner points
                cv::Point tl(face.x*compressScale, face.y*compressScale);
                cv::Point br = tl + cv::Point(face.width*compressScale, face.height*compressScale);
                // Draw rectangle around the face
                cv::Scalar magenta = cv::Scalar(255, 0, 255);
                cv::rectangle(origionalPicMat, tl, br, magenta, 4, 8, 0);
                CGRect faceRegion = CGRectMake(face.x*compressScale, face.y*compressScale, face.width*compressScale, face.height*compressScale);
                CGImageRef ref = CGImageCreateWithImageInRect(self.CGImage, faceRegion);
                UIImage *img = [UIImage imageWithCGImage:ref];
                NSLog(@" %d Width X Height : %.2f X %.2f", i, img.size.width, img.size.height);
                [detectedFacesArray addObject:img];
            }
        UIImage *markedImage = [UIImage UIImageFromCVMat:origionalPicMat];
        [imgAndFaces setObject:markedImage forKey:@"markedImage"];
        [imgAndFaces setObject:detectedFacesArray forKey:@"detectedFaces"];
        }
        return imgAndFaces;
}

@end

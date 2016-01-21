//
//  UIImageCVMatConversion.h
//  Face Recognition 
//
//  Created by Zheyu Zhuang on 14/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//
// adding extra opencv cvmat and uiimage conversion method to UIImage class

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>

@interface UIImage (openCV)

+(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;
- (cv::Mat) uniformAndNormalizeImages;
- (cv::Mat)cvMatFromUIImage;
- (cv::Mat)cvMatGreyFromUIImage;
- (NSMutableDictionary *) faceDetectWithCompressScale:(int) compressScale;
// A method that returns the origional picture with faces marked and A array that
// contains all the deteted zoomed faces;
@end

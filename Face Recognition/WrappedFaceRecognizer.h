//
//  WrappedFaceRecognizer.h
//  Face Recognition 
//
//  Created by Zheyu Zhuang on 13/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <opencv2/opencv.hpp>
#import <UIKit/UIKit.h>
#import "OpenCVSupp.h"

@interface WrappedFaceRecognizer : NSObject

- (void) addFaceInMatToTrain:(cv::Mat) facePic


- (NSString *)predict:(UIImage *)img confidence:(double *)confidence;


@end

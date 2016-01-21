//
//  DetectedFaceCollectionViewController.h
//  Image picker view test
//
//  Created by Zheyu Zhuang on 11/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cell.h"
#import <QuartzCore/QuartzCore.h>
#import "OpenCVSupp.h"
#import <opencv2/opencv.hpp>
#import "opencv2/face.hpp"

@interface DetectedFaceCollectionViewController : UIViewController < UICollectionViewDataSource, UIBarPositioningDelegate >
@property (strong, nonatomic) NSMutableArray *imageResources;
@end

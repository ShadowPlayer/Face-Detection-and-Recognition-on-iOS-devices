//
//  WrappedFaceRecognizer.m
//  Face Recognition 
//
//  Created by Zheyu Zhuang on 13/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import "WrappedFaceRecognizer.h"
#import "opencv2/face.hpp"

@interface WrappedFaceRecognizer () {
cv::Ptr<cv::face::FaceRecognizer> faceClassifier;
}
@property (nonatomic, strong) NSMutableDictionary *labelsDictionary;
@end


@implementation WrappedFaceRecognizer


- (BOOL)serializeFaceRecognizerParamatersToFile:(NSString *)path {
    
    self->faceClassifier->save(path.UTF8String);
    
    [NSKeyedArchiver archiveRootObject:_labelsDictionary toFile:[path stringByAppendingString:@".names"]];
    
    return YES;
}

- (NSString *)predict:(UIImage*)img confidence:(double *)confidence {
    
    cv::Mat src = [img cvMatGreyFromUIImage];
    int label;
    
    self->faceClassifier->predict(src, label, *confidence);
    
    return _labelsDictionary[@(label)];
}



@end
//
//  Cell.m
//  Image picker view test
//
//  Created by Zheyu Zhuang on 11/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import "Cell.h"

@implementation Cell
-(void) roundImage {
    _faceImage.layer.cornerRadius = 10;//_faceImage.frame.size.height /2;
    _faceImage.layer.masksToBounds = YES;
    _faceImage.layer.borderWidth = 0;
    _faceImage.layer.shadowColor = [UIColor purpleColor].CGColor;
    _faceImage.layer.shadowOffset = CGSizeMake(0, 1);
    _faceImage.layer.shadowOpacity = 1;
    _faceImage.layer.shadowRadius = 1.0;
}
@end

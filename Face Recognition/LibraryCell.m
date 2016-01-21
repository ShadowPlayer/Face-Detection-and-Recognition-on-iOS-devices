//
//  LibraryCell.m
//  Face Recognition 
//
//  Created by Zheyu Zhuang on 17/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import "LibraryCell.h"

@implementation LibraryCell

// Trim the rect to round rect
-(void) roundImage {
    _libraryImage.layer.cornerRadius = 10;
    _libraryImage.layer.masksToBounds = YES;
    _libraryImage.layer.borderWidth = 0;
    _libraryImage.layer.shadowColor = [UIColor purpleColor].CGColor;
    _libraryImage.layer.shadowOffset = CGSizeMake(0, 1);
    _libraryImage.layer.shadowOpacity = 1;
    _libraryImage.layer.shadowRadius = 1.0;
}

@end

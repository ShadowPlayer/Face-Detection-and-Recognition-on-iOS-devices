//
//  LibraryCell.h
//  Face Recognition 
//
//  Created by Zheyu Zhuang on 17/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//


// the UICollectionCell configuration, nearly identical to Cell.h
#import <UIKit/UIKit.h>

@interface LibraryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *libraryImage;
-(void)roundImage;
@end

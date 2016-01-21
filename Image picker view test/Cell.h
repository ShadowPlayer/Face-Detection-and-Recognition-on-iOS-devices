//
//  Cell.h
//  Image picker view test
//
//  Created by Zheyu Zhuang on 11/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Cell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *faceImage;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
-(void)roundImage;
@end

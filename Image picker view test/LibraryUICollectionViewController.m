//
//  LibraryUICollectionViewController.m
//  Face Recognition 
//
//  Created by Zheyu Zhuang on 17/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import "LibraryUICollectionViewController.h"

@interface LibraryUICollectionViewController (){
    NSMutableArray *storedFaces;
    NSMutableArray *storedLabels;
    NSMutableDictionary *storedName_LabelDictionary;
}
@property (nonatomic) BOOL storedDataExist;
@end

@implementation LibraryUICollectionViewController

static NSString * const reuseIdentifier = @"libraryCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
    storedFaces = [[NSMutableArray alloc] init];
    storedLabels = [[NSMutableArray alloc] init];
    storedName_LabelDictionary = [[NSMutableDictionary alloc] init];
    [self retrieveData];
    
}

#pragma mark Stored Data Handling
//Retrive data, putting the ritrived data to either UIMutable Array or UIMutableDictionary
-(void) retrieveData {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    storedFaces = [self pngToUIImage:[userDefaults objectForKey:@"FacesArray"]];
    storedLabels = [NSMutableArray arrayWithArray:[userDefaults objectForKey:@"LabelsArray"]];
    storedName_LabelDictionary = [NSMutableDictionary dictionaryWithDictionary:[userDefaults objectForKey:@"nameLabelDictionary"]];
    if ([storedName_LabelDictionary count]!=0 && [storedLabels count]!=0 && [storedFaces count] !=0) {
        _storedDataExist = YES;
    }else{
        _storedDataExist = NO;
    }
}


/* Only png or jpeg formatted images can be stored in NSUserDefault, 
    converting png to UIImage after data retive complete */
-(NSMutableArray *) pngToUIImage: (NSArray *) pngArray {
    NSMutableArray *facesUIImage = [[NSMutableArray alloc] init];
    for (id obj in pngArray){
        UIImage *image= [UIImage imageWithData:obj];
        [facesUIImage addObject:image];
    }
    return facesUIImage;
}

// Find all the portraits of under the same name tag
-(NSMutableArray *) findFacesInDatabase:(NSMutableArray *) indexArray WithIndex:(NSInteger) sectionNumber{
    NSString *indexString = [NSString stringWithFormat:@"%d", (int) sectionNumber];
    NSMutableArray *facesOfSpecifiedPerson = [[NSMutableArray alloc] init];
    for (int i=0; i <[storedLabels count]; i++){
        if ([[storedLabels objectAtIndex:i] isEqualToString:indexString]) {
            [facesOfSpecifiedPerson addObject:[storedFaces objectAtIndex:i]];
        }
    }
    return facesOfSpecifiedPerson;
}


#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [storedName_LabelDictionary count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSString *indexLabel = [NSString stringWithFormat:@"%d", (int)section];
    NSCountedSet *arrayForCounting = [[NSCountedSet alloc] initWithArray:storedLabels];
    NSInteger countAtEachSection = [arrayForCounting countForObject:indexLabel];
    return countAtEachSection;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath{
    LibraryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSMutableArray *facesOfSpecifiedPerson = [self findFacesInDatabase:storedLabels WithIndex:indexPath.section];
    cell.libraryImage.image = [facesOfSpecifiedPerson objectAtIndex: indexPath.row];
    [cell roundImage];
    return cell;
}

-(UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    SectionHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"nameHeader" forIndexPath:indexPath];
    header.nameLabel.text = [storedName_LabelDictionary objectForKey:[NSString stringWithFormat:@"%d", (int)indexPath.section]];
    return header;
}

@end

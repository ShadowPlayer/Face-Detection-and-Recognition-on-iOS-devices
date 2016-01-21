//
//  DetectedFaceCollectionViewController.m
//  Image picker view test
//
//  Created by Zheyu Zhuang on 11/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import "DetectedFaceCollectionViewController.h"

cv::Ptr<cv::face::FaceRecognizer> faceModel;
static NSString * const reuseIdentifier = @"faceCell";

@interface DetectedFaceCollectionViewController (){
    NSMutableArray *storedFaces;
    NSMutableArray *storedLabels;
    NSMutableDictionary *storedName_LabelDictionary;
    NSMutableArray *recognizedFacesArray;
    std::vector<cv::Mat> faceImagesVector;
    std::vector<int> faceLabelsVector;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic) BOOL storedDataExist;
@property (nonatomic) BOOL dataLoaded;
@property (nonatomic) BOOL modelGenerated;
@property (nonatomic) NSMutableArray *updatedNameArray;
@property (nonatomic) NSMutableArray *updatedFaceArray;
@property (weak, nonatomic) IBOutlet UILabel *selectedItemCountLabel;

@end

@implementation DetectedFaceCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _collectionView.allowsMultipleSelection = YES;
    [self.collectionView setBackgroundColor:[UIColor clearColor]];
    storedFaces = [[NSMutableArray alloc] init];
    storedLabels = [[NSMutableArray alloc] init];
    storedName_LabelDictionary = [[NSMutableDictionary alloc] init];
    recognizedFacesArray = [[NSMutableArray alloc] init];
    _updatedFaceArray = [[NSMutableArray alloc] init];
    _updatedNameArray = [[NSMutableArray alloc] init];
    // Configure View Background
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:blurEffectView atIndex:0];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self
               action:@selector(BTClicked:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"Show View" forState:UIControlStateNormal];
    button.frame = CGRectMake(451, 530.0, 60, 60);
    [button setImage:[UIImage imageNamed:@"addToTrainBG"] forState:UIControlStateNormal];
    [self.view addSubview:button];
    // Do any additional setup after loading the view
//    if (!_dataLoaded) {
//        [self retrieveData];
//        _dataLoaded=YES;
//    }
    [self retrieveData];
    [self generateModel];
    if (!_modelGenerated){
        storedFaces = [[NSMutableArray alloc] init];
        storedLabels = [[NSMutableArray alloc] init];
        storedName_LabelDictionary = [[NSMutableDictionary alloc] init];
    }else{recognizedFacesArray = [self lookingUpDictionaryArray:[self predict:_imageResources]];
        // return indeces of recognized faces
    }
    _selectedItemCountLabel.text = @"Click Images Then Add";
}

-(void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [self saveData];
}

#pragma mark - Load / save data

-(void) saveData{
    // Get the standardUserDefaults object, store data arraies against a key, synchronize the defaults
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[self uiimageToPng:storedFaces] forKey:@"FacesArray"];
    [userDefaults setObject:storedLabels forKey:@"LabelsArray"];
    [userDefaults setObject:storedName_LabelDictionary forKey:@"nameLabelDictionary"];
    [userDefaults synchronize];
}

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


#pragma mark openCV FaceRecognition Section

-(NSMutableArray *) pngToUIImage: (NSArray *) pngArray {
    NSMutableArray *facesUIImage = [[NSMutableArray alloc] init];
    for (id obj in pngArray){
        UIImage *image= [UIImage imageWithData:obj];
        [facesUIImage addObject:image];
    }
    return facesUIImage;
}

-(NSMutableArray *) uiimageToPng: (NSArray *) pngArray {
    NSMutableArray *facesPNG = [[NSMutableArray alloc] init];
    for (id obj in pngArray){
        NSData *imagePNG= UIImagePNGRepresentation(obj); ;
        [facesPNG addObject:imagePNG];
    }
    return facesPNG;
}

-(void) generateModel {
    faceModel = cv::face::createEigenFaceRecognizer(80,1870);
    if (_storedDataExist) {
        for (int index = 0; index < [storedFaces count]; index++) {
            cv::Mat initializedFaces = [[storedFaces objectAtIndex:index] uniformAndNormalizeImages];
            int labelNum = [[storedLabels objectAtIndex:index] intValue];
            faceImagesVector.push_back(initializedFaces);
            faceLabelsVector.push_back(labelNum);
        }
        faceModel->train(faceImagesVector, faceLabelsVector);
        NSLog(@"Model Generated");
        _modelGenerated = YES;
    }else{
        _modelGenerated = NO;
    }
}

-(NSMutableArray *) predict:(NSMutableArray *) detectedFaces{
    NSMutableArray *nameLableArray = [[NSMutableArray alloc] init];
    for (UIImage *img in detectedFaces) {
        cv::Mat imgMat = [img uniformAndNormalizeImages];
        int returnedIntLabel = faceModel->predict(imgMat);
        [nameLableArray addObject:[NSNumber numberWithInt:returnedIntLabel]];
    }
    return nameLableArray;
}

#pragma mark Data Sorting

//// Assign One key for new added name;
-(NSMutableDictionary *) addingNewName:(NSString *) newName ToDic: (NSMutableDictionary *) dict{
    NSArray *nameExist = [dict allKeysForObject:newName];// Check if the input name already exists
        int pairNumber = (int) [[dict allKeys] count];// return how may key - value pairs
        if ([nameExist count]==0) {
            NSString *keyName = [NSString stringWithFormat:@"%d", pairNumber];// Assign a new key successive index;
            [dict setObject:newName forKey:keyName];
        }
    return dict;
}

// A function that translates Mutiple integer label to identifiable names;
-(NSMutableArray *) lookingUpDictionaryArray: (NSMutableArray *) recognizedFacesIndeces {
    NSMutableArray *nameArray = [[NSMutableArray alloc] init];
    if (_storedDataExist) {
        for (int i = 0; i<[recognizedFacesIndeces count]; i++) {
            NSString *key = [NSString stringWithFormat:@"%d", [[recognizedFacesIndeces objectAtIndex:i] intValue]];
            NSString *name = [storedName_LabelDictionary valueForKey:key];
            if (name) {
                [nameArray addObject:name];
            }else{
                [nameArray addObject:@"Unknown"];
            }
        }
    }
    return nameArray;
}

-(NSString *) lookUpIndexWithGivenName: (NSString *) givenName inDictionary :(NSDictionary *) dict{
    NSArray *nameExist = [dict allKeysForObject:givenName];// Check if the input name exists
    NSString *returnedInxexString;
    if ([nameExist count]== 0 ) {
        returnedInxexString =nil;
    }else{
        NSString *key = [nameExist objectAtIndex:0];// Assign a new key successive index;
        returnedInxexString = key;// key is the index stored with NSString format;
    }
    return returnedInxexString;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _imageResources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    Cell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected"]];
    if (_modelGenerated) {
        cell.nameLabel.text = [recognizedFacesArray objectAtIndex:(int) indexPath.row];
    }else{
        cell.nameLabel.text = @"Unknown";
    }
    //Assign Names to textFields;
    cell.nameLabel.textColor = [UIColor grayColor];
    [cell roundImage];
    UIImage *imageToLoad = [_imageResources objectAtIndex:(int)indexPath.row];
    cell.faceImage.image = imageToLoad;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
- (IBAction) BTClicked:(id)sender{
    // Popping Up a Alert comfirming adding images to model
    if ( _collectionView.indexPathsForSelectedItems.count ==0) {
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Warning"
                                      message:@"No Selected Item"
                                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"I got it"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        UIAlertController * alert=   [UIAlertController
                                      alertControllerWithTitle:@"Confirm"
                                      message:[NSString stringWithFormat:@"Adding %d Selected Faces to Database", (int)_collectionView.indexPathsForSelectedItems.count]
                                      preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction
                             actionWithTitle:@"I'm sure"
                             style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * action)
                             {
                                 for (NSIndexPath *indexPath in _collectionView.indexPathsForSelectedItems) {
                                     Cell *cell = (Cell *)[_collectionView cellForItemAtIndexPath:indexPath];
                                     cell.userInteractionEnabled = NO;
                                     cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"selected_grey"]];
                                     [storedFaces addObject:cell.faceImage.image];// update the face database
                                     storedName_LabelDictionary = [self addingNewName:cell.nameLabel.text ToDic:storedName_LabelDictionary];
                                     NSString *newIndex = [self lookUpIndexWithGivenName:cell.nameLabel.text inDictionary:storedName_LabelDictionary];
                                     [storedLabels addObject:newIndex];
                                 }
                                 
                                 if(_collectionView.indexPathsForSelectedItems.count == 0){
                                     _selectedItemCountLabel.text = @"No Item Is Added";
                                 }else if (_collectionView.indexPathsForSelectedItems.count ==1){
                                     _selectedItemCountLabel.text = @"1 Item Is Added";
                                 }else{
                                     _selectedItemCountLabel.text = [NSString stringWithFormat:@"%d Items Are Added",(int) _collectionView.indexPathsForSelectedItems.count];
                                 }
                                 
                                [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
        UIAlertAction* cancel = [UIAlertAction
                                 actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action)
                                 {
                                     [alert dismissViewControllerAnimated:YES completion:nil];
                                     
                                 }];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        }
}


@end

//
//  ViewController.m
//  Image picker view test
//
//  Created by Zheyu Zhuang on 10/01/2016.
//  Copyright © 2016 Zheyu Zhuang. All rights reserved.
//

#import "ViewController.h"

const CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
const CGFloat offsetY = 135;
const CGFloat desiredWidth = 400;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIButton *cameraBT;
@property (weak, nonatomic) IBOutlet UIButton *photoLibraryBT;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundBlur;
@property (weak, nonatomic) IBOutlet UIButton *faceDetectionBT;
@property (weak, nonatomic) IBOutlet UIButton *sceneSwitchingBT;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *showLibraryBT;
@property (nonatomic) BOOL detectionIsComplete;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (strong, nonatomic) UIImage *selectedImage;
@property (strong, nonatomic) UIImageView *imageView;
@property (nonatomic) NSMutableArray *capturedImages;
@property (strong, nonatomic) NSMutableArray *detectedFacesArray;
@property (nonatomic) UIImagePickerController *imagePickerController;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _sceneSwitchingBT.hidden = YES;
    _detectionIsComplete = NO;
    [_toolBar setBackgroundImage:[UIImage imageNamed:@"toolBarBG"] forToolbarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    _toolBar.translucent = YES;
    _backgroundBlur.contentMode = UIViewContentModeScaleAspectFill;
    [_backgroundBlur setImage:[UIImage imageNamed:@"rainy"]];
    //Adding background Blur
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        self.view.backgroundColor = [UIColor clearColor];
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view insertSubview:blurEffectView atIndex:1];
    }
    else {
        self.view.backgroundColor = [UIColor blackColor];
    }

    self.capturedImages=[[NSMutableArray alloc] init];
    self.detectedFacesArray = [[NSMutableArray alloc] init];
    
    // image preview window configering;
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((screenWidth-desiredWidth)/2,  offsetY, desiredWidth, desiredWidth/0.633)];
    [_imageView setImage:[UIImage imageNamed:@"rainy.jpg"]];
    //Using QuartzCore to make a rounded corner mask of image preview window
    _imageView.layer.cornerRadius = 5;
    _imageView.clipsToBounds = YES;

    [self.view addSubview:self.imageView];
    
    // Error Handling, if camera not avaliable.
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertController *myAlertView = [UIAlertController alertControllerWithTitle:@"Error" message:@"No Camera Available" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:myAlertView animated:YES completion:NULL];
    }
    // Deactivate the detection button when no picture shown
    _faceDetectionBT.enabled=NO;
    if (!_detectedFacesArray) {
        _sceneSwitchingBT.enabled=NO;
    }else {
        _sceneSwitchingBT.enabled = YES;
    }
    // attach 2-finger long press gesture to collectionView
    UILongPressGestureRecognizer *longPress
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(resetLongPress:)];
    longPress.delegate = self;
    [longPress setNumberOfTouchesRequired:2];
    self.imageView.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:longPress];
    
    // Attach tap gesture recognizer to the imageview to add images.
    UITapGestureRecognizer *tap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapShowPhotoLibrary:)];
    tap.delegate = self;
    _backgroundBlur.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:tap];
}

# pragma mark Tap dismiss pop up window
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    // add tap recognizer
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBehindDetected:)];
    [_tapRecognizer setNumberOfTapsRequired:1];
    _tapRecognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
    [self.view.window addGestureRecognizer:_tapRecognizer];
    _tapRecognizer.delegate = self;
    
}

- (void)tapBehindDetected:(UITapGestureRecognizer *)sender
{
    
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        CGPoint location = [sender locationInView:nil]; //Passing nil gives us coordinates in the window
        
        //Convert tap location into the local view's coordinate system. If outside, dismiss the view.
        if (![self.presentedViewController.view pointInside:[self.presentedViewController.view convertPoint:location fromView:self.view.window] withEvent:nil])
        {
            if(self.presentedViewController) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{return YES;}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer*)otherGestureRecognizer{return YES;}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {return YES;}

#pragma mark Image Picker Configering

// The selector for image preview window tapping gesture
-(IBAction)tapShowPhotoLibrary:(UITapGestureRecognizer  *)sender{
    if (sender.state == UIGestureRecognizerStateEnded) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate=self;
        //picker.allowsEditing=YES;
        picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:NULL];
    }
}
- (IBAction)showImagePickerForPhotoPicker:(id)sender // handle the photo picking from Photo Library
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate=self;
    //picker.allowsEditing=YES;
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)showImagePickerForCamera:(id)sender{ // call the camera button
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Activate the Face detecting button when images are selected
    self.faceDetectionBT.enabled=YES;
    // setting image preview position and window size
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    CGFloat scaleFactor = desiredWidth/image.size.width;
    CGFloat previewWidth = image.size.width*scaleFactor;
    CGFloat previewHeight= image.size.height*scaleFactor;
    CGFloat origionX = (screenWidth-previewWidth)/2;
    self.selectedImage = [image copy];
    [self.capturedImages addObject:image];// adding the image into the collection queue
    self.imageView.frame = CGRectMake(origionX, offsetY, previewWidth, previewHeight);
    [self finishAndUpdate];
}

- (void)finishAndUpdate // change the currently loaded Pics and update the user interface;
{
    //remove all detected faces in previous image
    [_detectedFacesArray removeAllObjects];
    // reset faceDetection Button's image
    [self.faceDetectionBT setBackgroundImage:[UIImage imageNamed:@"Analyse"] forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:NULL];
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [self.imageView setImage:[self.capturedImages objectAtIndex:0]];
            [self.backgroundBlur setImage:[self.capturedImages objectAtIndex:0]];
        }
//      Multiple picture selection left for future development;
//        else
//        {
//            // Camera took multiple pictures; use the list of images for animation.
//            self.imageView.animationImages = self.capturedImages;
//            self.imageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
//            self.imageView.animationRepeatCount = 0;   // Animate forever (show all photos).
//            [self.imageView startAnimating];
//            
//            self.backgroundBlur.animationImages = self.capturedImages;
//            self.backgroundBlur.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
//            self.backgroundBlur.animationRepeatCount = 0;   // Animate forever (show all photos).
//            [self.backgroundBlur startAnimating];
//        }
        
        // To be ready to start again, clear the captured images array.
       [self.capturedImages removeAllObjects];
    }
    [_detectedFacesArray removeAllObjects];
    self.imagePickerController = nil;
    _detectionIsComplete=NO;
    _textLabel.text =nil;
}


#pragma mark Face Detection Section

-(void) faceDetect {
    self.faceDetectionBT.hidden=YES;// Hide the detection button when processing
    NSMutableDictionary *imgAndFaces = [_selectedImage faceDetectWithCompressScale:1];
    _detectedFacesArray = [imgAndFaces valueForKey:@"detectedFaces"];
    self.imageView.image = [self orientationTester:[imgAndFaces valueForKey:@"markedImage"] referenceOritation:_selectedImage.imageOrientation];
    self.faceDetectionBT.hidden=NO;
    [_faceDetectionBT setBackgroundImage:[UIImage imageNamed:@"Done"] forState:UIControlStateNormal];
    _detectionIsComplete=YES;
    if (_detectedFacesArray.count == 0) {
        _textLabel.text = @" No Face Found ";
    }else if (_detectedFacesArray.count == 1){
    _textLabel.text = @" 1 Face Has Been Deceted ";
    }else {
        _textLabel.text = [NSString stringWithFormat:@" %d Faces Have Been Deceted ", (int)_detectedFacesArray.count];
    }
}

-(IBAction) faceDetectionBT:(id)sender{
    if (!_detectionIsComplete) {[self faceDetect];}
    if (_detectedFacesArray.count !=0) {
        [self performSegueWithIdentifier:@"drawFaces" sender:self];
    }
    NSLog(@"\n Detect completed; \n deteced %d Faces", (int)_detectedFacesArray.count);
}


//Final image orientation correction
-(UIImage *) orientationTester: (UIImage *) image referenceOritation: (UIImageOrientation) orientation {
    UIImage *rotationCorrectedImage;
    if (orientation == UIImageOrientationUp) {
        NSLog(@"Upwards");
        rotationCorrectedImage = image;
    } else if (orientation == UIImageOrientationLeft ) {
        rotationCorrectedImage = [UIImage imageWithCGImage:[image CGImage]
                                                    scale:1.0
                                              orientation: UIImageOrientationLeft];
        NSLog(@"Leftwards");
    }else if (orientation == UIImageOrientationDown){
        rotationCorrectedImage = [UIImage imageWithCGImage:[image CGImage]
                                                    scale:1.0
                                              orientation: UIImageOrientationDown];
        NSLog(@"Dowwards");
    }else if (orientation == UIImageOrientationRight){
       rotationCorrectedImage = [UIImage imageWithCGImage:[image CGImage]
                                                    scale:1.0
                                              orientation: UIImageOrientationRight];
        NSLog(@"Rightwards");
    }
    return rotationCorrectedImage;
}

#pragma mark UICollectionView Datasource
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"drawFaces"])
    {
        // load the image, to prevent it from being cached we use 'initWithContentsOfFile'
        DetectedFaceCollectionViewController *detectedViewController = (DetectedFaceCollectionViewController *)segue.destinationViewController;
        if (_detectedFacesArray.count != 0) {
                //detectedViewController.imageResources = [[NSMutableArray alloc] initWithArray:self.detectedFacesArray copyItems:YES];
                detectedViewController.imageResources = self.detectedFacesArray;
        }
    }
}

#pragma mark Reset All Stored data

-(IBAction)resetLongPress:(UILongPressGestureRecognizer *)sender{
    if (sender.state == UIGestureRecognizerStateBegan) {
    // Popping Up a Alert comfirming adding images to model
    
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Warning"
                                  message:@"Face Database Will Be Erased"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"I'm sure"
                         style:UIAlertActionStyleDestructive
                         handler:^(UIAlertAction * action)
                         {
                             NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
                             [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
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

//
//  ViewController.m
//  SogouAR
//
//  Created by fk on 2017/11/6.
//  Copyright © 2017年 fk. All rights reserved.
//

#import "ViewController.h"
#import "SGTextNode.h"
#import "SGARObject.h"

static NSInteger count = 0;

static const NSInteger TextListMAX = 10;

@interface ViewController ()


@property (weak, nonatomic) IBOutlet UILabel *cameraStatusLabel;

@property (nonatomic, strong) ARConfiguration *arSessionConfiguration;

@property (nonatomic, strong) SCNNode *wangzaiNode;


@property (nonatomic, strong) NSMutableArray <SGTextNode *>*textList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _serialQueue =  dispatch_queue_create("arWangzai.SERIAL.queue", DISPATCH_QUEUE_SERIAL);
    _planeDict = [NSMutableDictionary dictionary];
    _textList = [NSMutableArray arrayWithCapacity:TextListMAX];
    
    SCNScene *scene = [SCNScene sceneNamed:@"Model.scnassets/test.obj"];
    _wangzaiNode = scene.rootNode.childNodes[0];
    
    _objectManager = [[SGARObjectManager alloc] initWithQueue:_serialQueue];
    _objectManager.delegate = self;
    
//
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreenAction:)];
//    tapGestureRecognizer.numberOfTapsRequired = 1;
//    [self.arSCNView addGestureRecognizer:tapGestureRecognizer];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (ARWorldTrackingConfiguration.isSupported) {
        [self.view addSubview:self.arSCNView];
        [self.view sendSubviewToBack:self.arSCNView];
        [self.arSession runWithConfiguration:self.arSessionConfiguration options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
        
        [self setupFocusSquare];

    } else {
        [self updateTextManagerInfo:@"当前设备不支持AR"];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -搭建ARKit环境
- (ARConfiguration *)arSessionConfiguration {
    if (_arSessionConfiguration != nil) {
        return _arSessionConfiguration;
    }
    ARWorldTrackingConfiguration *configuration = [[ARWorldTrackingConfiguration alloc] init];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    _arSessionConfiguration = configuration;
    _arSessionConfiguration.lightEstimationEnabled = YES;
    return _arSessionConfiguration;
}

- (ARSession *)arSession {
    if(_arSession != nil) {
        return _arSession;
    }
    _arSession = [[ARSession alloc] init];
    _arSession.delegate = self;
    
    return _arSession;
}

- (ARSCNView *)arSCNView {
    if (_arSCNView != nil) {
        return _arSCNView;
    }
    _arSCNView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    _arSCNView.delegate = self;
    _arSCNView.session = self.arSession;
    _arSCNView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    
    _arSCNView.antialiasingMode = SCNAntialiasingModeMultisampling4X;
    _arSCNView.automaticallyUpdatesLighting = NO;
    _arSCNView.autoenablesDefaultLighting = NO;
    _arSCNView.preferredFramesPerSecond = 60;
    _arSCNView.contentScaleFactor = 1.3;
    UIImage *env = [UIImage imageNamed: @"Model.scnassets/spherical.jpg"];
    _arSCNView.scene.lightingEnvironment.contents = env;
    //    _arSCNView.allowsCameraControl = YES;
    
    SCNCamera *camera = _arSCNView.pointOfView.camera;
    if (camera) {
        camera.wantsHDR = YES;
        camera.wantsExposureAdaptation = YES;
        camera.exposureOffset = -1;
        camera.minimumExposure = -1;
        camera.maximumExposure = 3;
    }
    return _arSCNView;
}

- (FocusSquare *)focusSquare {
    
    if (_focusSquare) return _focusSquare;
    _focusSquare = [[FocusSquare alloc] init];
    return _focusSquare;
}

#pragma mark - events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_objectManager reactToTouchesBegan:touches withEvent:event inSceneView:self.arSCNView];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_objectManager reactToTouchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_objectManager reactToTouchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_objectManager reactToTouchesCancelled:touches withEvent:event];
}

//- (void)tapScreenAction:(UITapGestureRecognizer *)recognizer {
//
//    CGPoint tapPoint = [recognizer locationInView:self.arSCNView];
//    NSArray<ARHitTestResult *> *result = [self.arSCNView hitTest:tapPoint types:ARHitTestResultTypeExistingPlaneUsingExtent];
//
//    if (result.count == 0) return;
//
//    ARHitTestResult * hitResult = [result firstObject];
//    [self insertModel:hitResult];
//}
//
//- (void)insertModel:(ARHitTestResult *)hitResult {
//
//    ARPlaneAnchor *anchor = (ARPlaneAnchor *)hitResult.anchor;
//    SCNNode *planeNode = [_planeDict objectForKey:anchor.identifier];
//    if (planeNode) {
//        SCNVector3 position = SCNVector3Make(
//                                             hitResult.localTransform.columns[3].x,
//                                             hitResult.localTransform.columns[3].y,
//                                             hitResult.localTransform.columns[3].z
//                                             );
//        SCNNode *vaseNode = _wangzaiNode;
//        vaseNode.scale = SCNVector3Make(0.0005, 0.0005, 0.0005);
//        vaseNode.position =  position;
//        [planeNode addChildNode:vaseNode];
//    }
//}

- (IBAction)btnClick:(id)sender {
    
    
    NSURL *path = [[NSBundle mainBundle] URLForResource:@"Model.scnassets/cup/cup" withExtension:@"scn"];
    
    matrix_float4x4 cameraTransform = self.arSession.currentFrame.camera.transform;
    
    SGARObject *arObject = [[SGARObject alloc] initWithURL:path];
    arObject.scale = SCNVector3Make(0.0005, 0.0005, 0.0005);
    SCNVector3 position = self.focusSquareLastPos;
    [_objectManager loadVirtualObject:arObject toPostion:position cameraTransform:cameraTransform];
    
    if (arObject.parentNode == nil) {
        dispatch_async(_serialQueue, ^{
            [self.arSCNView.scene.rootNode addChildNode:arObject];
        });
    }
    
    return;
    
    
    count++;
    
    if (_wangzaiNode) {
        
        NSMutableString *str = [NSMutableString stringWithFormat:@"汪"];
        for (NSInteger idx = 0; idx < count; idx++) {
            [str appendString:@"汪"];
        }

        SGTextNode *textNode = [[SGTextNode alloc] initWithText:str];

        SCNVector3 minBound,maxBound;
        [_wangzaiNode.geometry getBoundingBoxMin:&minBound max:&maxBound];
        CGFloat startHeight = fabs(maxBound.y) + fabs(minBound.y);

        
        [_textList enumerateObjectsUsingBlock:^(SGTextNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SCNVector3 newPosition = SCNVector3Make(obj.position.x, obj.position.y + obj.textHeight * 70, obj.position.z);
            SCNAction *action = [SCNAction moveTo:newPosition duration:0.4];
            [obj runAction:action];
        }];
        
        textNode.position = SCNVector3Make(0, startHeight, 0);

        [_wangzaiNode addChildNode:textNode];
        
        [_textList addObject:textNode];
    }
}

#pragma mark - private
- (void)setupFocusSquare {
    
    dispatch_async(self.serialQueue, ^{
        [self.focusSquare unhide];
        [self.focusSquare removeFromParentNode];        
        [self.arSCNView.scene.rootNode addChildNode:self.focusSquare];
    });
}

- (void)updateTextManagerInfo:(NSString *)text {
    _cameraStatusLabel.text = text;
    [_cameraStatusLabel sizeToFit];
    _cameraStatusLabel.frame = CGRectMake(10, 20, _cameraStatusLabel.bounds.size.width, _cameraStatusLabel.bounds.size.height);
}

@end

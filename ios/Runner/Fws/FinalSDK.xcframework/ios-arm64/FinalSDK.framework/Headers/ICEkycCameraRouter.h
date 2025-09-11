//
//  ICEkycCameraRouter.h
//  FinalSDK
//
//  Created by Minh Nguyễn on 8/20/20.
//  Copyright © 2020 Minh Nguyễn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ICEkycCameraProtocols.h"
#import "ICEkycCameraViewController.h"

@interface ICEkycCameraRouter : NSObject<ICEkycCameraWireframeProtocol>

@property (nonatomic, weak) ICEkycCameraViewController *viewController;

+ (UIViewController *)createModule;

@end

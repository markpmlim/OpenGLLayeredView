//
//  ViewController.m
//  LayeredBackOpenGLView
//
//  Created by mark lim pak mun on 05/12/2023.
//  Copyright © 2023 Incremental Innovations. All rights reserved.
//

#import "ViewController.h"
#import "LayeredView.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //LayeredView *view = (LayeredView *)self.view;
    // The layer is already instantiated but its associated OpenGL context is still NIL.
    // NSLog(@"%@", view.layer);
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

// The system will call this method whether there is a window resize.
// An OpenGL context may not be instantiated yet the first
// time this method is called.
- (void)viewDidLayout
{
    [super viewDidLayout];
    LayeredView *view = (LayeredView *)self.view;
    [view resize];
}

@end

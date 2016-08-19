//
//  ViewController.m
//  ThreadTesting
//
//  Created by macbook on 8/19/16.
//  Copyright © 2016 macbook. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    
    NSOperationQueue *operationQueue;
   
}
@property (retain, nonatomic) IBOutlet UILabel *label1;
@property (retain, nonatomic) IBOutlet UILabel *label2;
@property (retain, nonatomic) IBOutlet UILabel *label3;
@end

@implementation ViewController
@synthesize label1, label2, label3;
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self operatorWithBlock];
    
    
}
-(void)grandDistchPath{
    dispatch_queue_t my_Queue  = dispatch_queue_create("com.phimb.testqueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(my_Queue, ^{
        [self counterTask:@"T1"];
    });
    dispatch_async(my_Queue, ^{
        [self counterTask:@"T2"];
    });
    dispatch_async(my_Queue, ^{
        [self counterTask:@"T3"];
    });
    dispatch_queue_t my_Queue_changecolor  = dispatch_queue_create("com.phimb.testqueue.changecolor", NULL);
    dispatch_async(my_Queue_changecolor, ^{
        [self colorRotatorTask];
    });
}
-(void)runWithMultiThread{
    // Create a new NSOperationQueue instance.
    operationQueue = [NSOperationQueue new];
    
    // Create a new NSOperation object using the NSInvocationOperation subclass.
    // Tell it to run the counterTask method.
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(counterTask)
                                                                              object:nil];
    // Add the operation to the queue and let it to be executed.
    [operationQueue addOperation:operation];
    //    [operation release];
    
    // The same story as above, just tell here to execute the colorRotatorTask method.
    operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                     selector:@selector(colorRotatorTask)
                                                       object:nil];
    [operationQueue addOperation:operation];
    //    [operation release];
    [operationQueue addOperationWithBlock:^{
        [self colorRotatorTask];
    }];

}

-(void)operatorWithBlock{
    operationQueue = [NSOperationQueue new];
    
    // Create a new NSOperation object using the NSInvocationOperation subclass.
    // Tell it to run the counterTask method.
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
                                                                            selector:@selector(counterTask)
                                                                              object:nil];
    // Add the operation to the queue and let it to be executed.
    [operation setCompletionBlock:^{
        NSLog(@"counterTask: has finished");
    }];
    [operationQueue addOperation:operation];
    //    [operation release];
    
    // The same story as above, just tell here to execute the colorRotatorTask method.
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        [self colorRotatorTask];

    }];
    [blockOperation setCompletionBlock:^{
        NSLog(@"colorRotatorTask: has finished");

    }];
    [operationQueue addOperation:blockOperation];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)counterTask:(NSString *)task{
    // Make a BIG loop and every 100 steps let it update the label1 UILabel with the counter's value.
//    10000000
    for (int i=0; i<100000; i++) {
        if (i % 100 == 0) {
            // Notice that we use the performSelectorOnMainThread method here instead of setting the label's value directly.
            // We do that to let the main thread to take care of showing the text on the label
            // and to avoid display problems due to the loop speed.
            [label1 performSelectorOnMainThread:@selector(setText:)
                                     withObject:[NSString stringWithFormat:@"%@ %d",task, i]
                                  waitUntilDone:YES];
            NSLog(@"++");
        }
    }
    
    // When the loop gets finished then just display a message.
    [label1 performSelectorOnMainThread:@selector(setText:) withObject:@"Thread #1 has finished." waitUntilDone:NO];
}
-(void)counterTask{
    // Make a BIG loop and every 100 steps let it update the label1 UILabel with the counter's value.
    //    10000000
    for (int i=0; i<10000000; i++) {
        if (i % 100 == 0) {
            // Notice that we use the performSelectorOnMainThread method here instead of setting the label's value directly.
            // We do that to let the main thread to take care of showing the text on the label
            // and to avoid display problems due to the loop speed.
            [label1 performSelectorOnMainThread:@selector(setText:)
                                     withObject:[NSString stringWithFormat:@"%d", i]
                                  waitUntilDone:YES];
            NSLog(@"++");
        }
    }
    
    // When the loop gets finished then just display a message.
    [label1 performSelectorOnMainThread:@selector(setText:) withObject:@"Thread #1 has finished." waitUntilDone:NO];
}
-(void)colorRotatorTask{
    // We need a custom color to work with.
    UIColor *customColor;
    
    // Run a loop with 500 iterations.
    for (int i=0; i<500; i++) {
         NSLog(@"--");
        // Create three float random numbers with values from 0.0 to 1.0.
        float redColorValue = (arc4random() % 100) * 1.0 / 100;
        float greenColorValue = (arc4random() % 100) * 1.0 / 100;
        float blueColorValue = (arc4random() % 100) * 1.0 / 100;
        
        // Create our custom color. Keep the alpha value to 1.0.
        customColor = [UIColor colorWithRed:redColorValue green:greenColorValue blue:blueColorValue alpha:1.0];
        
        // Change the label2 UILabel's background color.
        [label2 performSelectorOnMainThread:@selector(setBackgroundColor:) withObject:customColor waitUntilDone:YES];
        
        // Set the r, g, b and iteration number values on label3.
        [label3 performSelectorOnMainThread:@selector(setText:)
                                 withObject:[NSString stringWithFormat:@"Red: %.2f\nGreen: %.2f\nBlue: %.2f\Iteration #: %d", redColorValue, greenColorValue, blueColorValue, i]
                              waitUntilDone:YES];
        
        // Put the thread to sleep for a while to let us see the color rotation easily.
        [NSThread sleepForTimeInterval:0.4];
    }
    
    // Show a message when the loop is over.
    [label3 performSelectorOnMainThread:@selector(setText:) withObject:@"Thread #2 has finished." waitUntilDone:NO];
}
- (IBAction)pressedCancel:(id)sender {
    if (operationQueue) {
        [operationQueue cancelAllOperations];
    }
}

- (IBAction)applyBackgroundColor1 {
    [self.view setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1.0]];
}

- (IBAction)applyBackgroundColor2 {
    [self.view setBackgroundColor:[UIColor colorWithRed:204.0/255.0 green:255.0/255.0 blue:102.0/255.0 alpha:1.0]];
}

- (IBAction)applyBackgroundColor3 {
    [self.view setBackgroundColor:[UIColor whiteColor]];
}
@end

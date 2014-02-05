//
//  NavigationController.m
//  RemindMe
//
//  Created by   on 1/4/14.
//  Copyright (c) 2014 Columbia University. All rights reserved.
//

#import "NavigationController.h"
#import "TWMessageBarManager.h"
#import "UIColor+Custom.h"
@import iAd;


@interface NavigationController ()
@property (strong,nonatomic) ADBannerView *iAd;
@property (strong,nonatomic) Reminder *currentReminder;
@end

@implementation NavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self constructAd];
}

- (void)showReminderForReminderObjectIDURIString:(NSString *)uriString{
    NSURL *uri = [NSURL URLWithString:uriString];
    NSManagedObjectID *moID = [[DataStore instance].persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
    NSManagedObject *myMO = [[DataStore instance].managedObjectContext objectWithID:moID];
    
    if ([myMO isKindOfClass:[Reminder class]]){
        NSLog(@"found reminder");
        Reminder *myReminder = (Reminder *) myMO;
        [self showReminderForMyReminder:myReminder];
    }
    
}

- (void)showReminderForMyReminder: (Reminder *) myReminder{
    if ([MFMessageComposeViewController canSendText])
    {
        self.currentReminder = myReminder;
        MFMessageComposeViewController *mvc = [[MFMessageComposeViewController alloc] init];
        [mvc.navigationBar setTintColor:[UIColor whiteColor]];
        mvc.messageComposeDelegate = self;
        [mvc setBody:myReminder.message];
        [mvc setRecipients:@[myReminder.recipient]];
        [self presentViewController:mvc animated:YES completion:nil];
    }
    else{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Cannot Sent Texts" description:@"Your Device is not setup to send texts" type:TWMessageBarMessageTypeError];
    }
}



-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    
    if (result == MessageComposeResultSent){
        
        [controller dismissViewControllerAnimated:YES completion:^{
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Message Sent" description:[NSString stringWithFormat:@"to %@", self.currentReminder.recipientName] type:TWMessageBarMessageTypeSuccess];
            [[DataStore instance] deleteReminder:self.currentReminder];
            self.currentReminder = nil;
        }];
        


    }
    else if (result == MessageComposeResultCancelled){
        
        
        NSLog(@"Hi %@", controller.body);
        
        [[[UIAlertView alloc] initWithTitle:@"Delete Message?" message:@"This cannot be undone." delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil] show];
        [controller dismissViewControllerAnimated:YES completion:nil];

    }
    else{
    
    [controller dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        [[DataStore instance] deleteReminder:self.currentReminder];
    }
    self.currentReminder = nil;
}

#pragma mark - iAd Methods

- (void) constructAd{
    self.iAd = [[ADBannerView alloc] init];
    [self.iAd setBackgroundColor:[UIColor whiteColor]];
    CGRect iAdFrame = self.iAd.frame;
    CGFloat newOriginY = self.view.frame.size.height - iAdFrame.size.height;
    self.iAd.frame = CGRectMake(iAdFrame.origin.x, newOriginY, iAdFrame.size.width, iAdFrame.size.height);
    [self.view addSubview:self.iAd];
}

- (CGFloat) iAdHeight{
    return CGRectGetHeight(self.iAd.frame);
}

@end

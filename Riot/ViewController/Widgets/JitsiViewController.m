/*
 Copyright 2017 Vector Creations Ltd

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "JitsiViewController.h"

static const NSString *kJitsiServerUrl = @"https://jitsi.riot.im/";

@implementation JitsiViewController

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass(self.class)
                          bundle:[NSBundle bundleForClass:self.class]];
}

+ (instancetype)jitsiViewControllerForWidget:(Widget*)widget
{
    JitsiViewController *jitsiViewController = [[[self class] alloc] initWithNibName:NSStringFromClass(self.class)
                                          bundle:[NSBundle bundleForClass:self.class]];

    jitsiViewController->_widget = widget;

    return jitsiViewController;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.jitsiMeetView.delegate = self;

    // Extract the jitsi conference id from the widget url
    // @TODO: Consider doing this in a `JitsiWidget` class.
    NSString *confId;
    NSURL *url = [NSURL URLWithString:_widget.url];
    NSURLComponents *components = [[NSURLComponents new] initWithURL:url resolvingAgainstBaseURL:NO];
    NSArray *queryItems = [components queryItems];

    for (NSURLQueryItem *item in queryItems)
    {
        if ([item.name isEqualToString:@"confId"])
        {
            confId = item.value;
        }
    }

    if (confId)
    {
        // Pass the URL to jitsi-meet sdk
        NSString *jitsiUrl = [NSString stringWithFormat:@"%@%@", kJitsiServerUrl, confId];
        [self.jitsiMeetView loadURLString:jitsiUrl];
    }
    // @TODO: else
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - JitsiMeetViewDelegate

- (void)conferenceFailed:(NSDictionary *)data
{
    NSLog(@"[JitsiViewController] conferenceFailed - data: %@", data);

    // @TODO: show something to the end user
}

- (void)conferenceLeft:(NSDictionary *)data
{
    // The conference is over. Close this view controller.
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
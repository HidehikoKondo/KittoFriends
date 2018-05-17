//
//  MabeeeViewController.m
//  udonkoapps2018-mobile
//
//  Created by Hidehiko Kondo on 2018/05/16.
//

#import "MabeeeViewController.h"
@import MaBeeeSDK;

@interface MabeeeViewController ()

@end

@implementation MabeeeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{

    MaBeeeScanViewController *vc = MaBeeeScanViewController.new;
    [vc show:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

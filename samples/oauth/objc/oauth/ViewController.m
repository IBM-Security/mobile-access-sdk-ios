#import "ViewController.h"

@interface ViewController ()

// MARK: Control variables
@property (weak, nonatomic) IBOutlet UITextField *textboxUsername;
@property (weak, nonatomic) IBOutlet UITextField *textboxPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonOK;
@property (weak, nonatomic) IBOutlet UIButton *buttonRefresh;

@end

@implementation ViewController

// MARK: Variables
OAuthToken *token = nil;
NSString *hostname = @"https://sdk.securitypoc.com/mga/sps/oauth/oauth20/token";
NSString *clientId = @"IBMVerifySDK";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Pad the left and right margins of the textboxes.
    _textboxUsername.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _textboxUsername.leftViewMode = UITextFieldViewModeAlways;
    _textboxPassword.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    _textboxPassword.leftViewMode = UITextFieldViewModeAlways;
}


// MARK: Control events
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    if(![touch.view isMemberOfClass:[UITextField class]]) {
        [touch.view endEditing:YES];
    }
}

- (IBAction)onOkClick:(UIButton *)sender {
    __block UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    __block UIAlertController *alert = nil;
    
    NSString *username = _textboxUsername.text;
    NSString *password = _textboxPassword.text;         // passw0rd
    
    NSLog(@"Username: %@", username);
    NSLog(@"Password: %@", password);
    NSLog(@"Endpoint URL: %@", hostname);
    NSLog(@"ClientId: %@", clientId);
    
    OAuthContext *context = [OAuthContext sharedInstance];
    
    [context getAccessToken :hostname :clientId username:username password:password completion:^(OAuthResult *result) {
        // Process callback on main UI thread to display alert.
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(result.hasError)
            {
                alert = [UIAlertController
                         alertControllerWithTitle:@"OAuth Sample"
                         message:result.errorDescription
                         preferredStyle:UIAlertControllerStyleAlert];
            }
            else
            {
                // We got the token.
                token = result.serializeToToken;
                [token store];
                
                alert = [UIAlertController
                         alertControllerWithTitle:@"OAuth Sample"
                         message:result.serializeToJson
                         preferredStyle:UIAlertControllerStyleAlert];
            }
            
            // Show the message.
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        });
    }];
}

- (IBAction)onRefreshClick:(UIButton *)sender {
    __block UIAlertAction *okButton = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    __block UIAlertController *alert = nil;

    // Load the token.
    token = [OAuthToken retrieve];

    // If we don't have a token then show a alert.
    if (token == nil)
    {
        // Show the error message.
        alert = [UIAlertController
                 alertControllerWithTitle:@"OAuth Sample"
                 message:@"No token to refresh."
                 preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:okButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSLog(@"Endpoint URL: %@", hostname);
        NSLog(@"ClientId: %@", clientId);
        
        NSLog(@"== Old Token ==");
        NSLog(@"Access token: %@", token.accessToken);
        NSLog(@"Refresh token: %@", token.refreshToken);
        NSLog(@"Should refresh: %d", token.shouldRefresh);

        OAuthContext *context = [OAuthContext sharedInstance];
        
        [context refreshAccessToken :hostname :clientId refreshToken:token.refreshToken completion:^(OAuthResult *result) {
            
            // Process callback on main UI thread and display alert.
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if(result.hasError)
                {
                    alert = [UIAlertController
                             alertControllerWithTitle:@"OAuth Sample"
                             message:result.errorDescription
                             preferredStyle:UIAlertControllerStyleAlert];
                }
                else
                {
                    // We got the token, update it.
                    token = result.serializeToToken;
                    [token store];
                    
                    NSLog(@"== New Token ==");
                    NSLog(@"Access token: %@", token.accessToken);
                    NSLog(@"Refresh token: %@", token.refreshToken);
                    NSLog(@"Should refresh: %d", token.shouldRefresh);
                    
                    alert = [UIAlertController
                             alertControllerWithTitle:@"OAuth Sample"
                             message:result.serializeToJson
                             preferredStyle:UIAlertControllerStyleAlert];
                }
                
                // Show the message.
                [alert addAction:okButton];
                [self presentViewController:alert animated:YES completion:nil];
            });
        }];
    }
}

@end

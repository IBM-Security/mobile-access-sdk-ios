# Configuring your environment

## Download
To access the SDK you need to sign in with an IBM ID account.  Create your free [IBM ID](https://www.ibm.com/account/us-en/signup/register.html) and navigate to [Fix Central](https://ibm.biz/ibmsecuritymobileaccesssdk) to download the SDK.


## Xcode setup

[![Link to video instructions](../../res/youtube-ios.png)](https://youtube.com/watch?v=IPvXQrL1dLM)

1\. After [downloading the .zip](README.md#Download), extract the contents to a folder that is easily located.
 
2\. Start Xcode and create a new project
> Make a note of the folder location of the project.

3\. Open the folder where the SDK was extracted in step 1 and copy the "Frameworks" folder to the directory where you created the Xcode project in step 2. The "Frameworks" folder should be at the same folder level as the .xcodeproj file.

![Screenshot of folder structure](../../res/folder-structure.png)

4\. In Xcode, select the top level Project item on the left:

![Top-level Project structure](../../res/project-title.png)

And in the pane on the right select the Target application from the "Targets" section.

5\. With the General tab selected, scroll down to the section "Embedded Binaries" and hit the '+' then navigate to the Frameworks directory that was copied to your project folder, navigate into Frameworks/Release and select the IBMMobileKit.framework so that you now see:

![IBMMobileKit under Embedded Binaries and Linked Frameworks](../../res/embedded-and-linked-settings.png)

6\. With the same Target still selected, click on "Build Settings" tab along the top of the pane.

7\. In the search field, type "Import Path" and double click the following field, creating an entry "Frameworks/CommonCrypto"

![Import Paths: Frameworks/CommonCrypto](../../res/import-paths-commoncrypto.png)

8\. In the search field, type "Runpath" and double click the following field and create an entry: `$(PROJECT_DIR)/Frameworks/$(CONFIGURATION)`

![The new entry in the "Runpath Search Paths" list](../../res/runpath-search-paths.png)

9\. In the search field, type "Framework Search" and double click the following field and create an entry `$(PROJECT_DIR)/Frameworks/$(CONFIGURATION)` and remove the entry above it that ends with "Release".

![The new entry in the "Framework Search Paths" list](../../res/framework-search-paths.png)

10\. To make sure the porject is configured, open the ViewController.swift and add the following imports below the `import UIKit` line:

```swift
import IBMMobileKit
import AVFoundation
import LocalAuthentication
```

Inside the `viewDidLoad()` function, add the following lines after the `super.viewDidLoad()` line:

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    let context = HotpGeneratorContext.init(secret: "abcd", counter: 1)
    print(context?.create())
}
```

You should notice the autocomplete working, the SDK has been imported correctly.
 
11\. With those additions, simply hit the Play button, here:

![Play button to emulator](../../res/press-play.png)

After the iPhone Simulator loads, and the application starts, you should see the following printed to the Output section of Xcode:

```
IBMMobileKit.HotpGeneratorContext
init(secret:digits:algorithm:counter:)
IBMMobileKit.OtpGeneratorContext init(secret:digits:algorithm:)
IBMMobileKit.HotpGeneratorContext create()
IBMMobileKit.OtpGeneratorContext create
Optional("300079")
```

Done.

# Deploy your app

## Build phase run script
The SDK is a universal framework, therefore when deploying your app a post build script should execute to remove unused architectures.

1\. In Xcode, select the top level Project item on the left. Select the project in the `TARGETS` section.

2\. Click on the `Build Phases` tab along the top of the middle pane.

4\. Click the **+** (Add new Build Phase) located top left of the panel.

5\. Click `New Run Script Phases`.

> Ensure Run Script is last phase in the list of build phases.

6\. Paste the following script into the empty text field provided.
    
```
APP_PATH="${TARGET_BUILD_DIR}/${WRAPPER_NAME}"
    
find "$APP_PATH" -name '*.framework' -type d | while read -r FRAMEWORK
do
FRAMEWORK_EXECUTABLE_NAME=$(defaults read "$FRAMEWORK/Info.plist" CFBundleExecutable)
FRAMEWORK_EXECUTABLE_PATH="$FRAMEWORK/$FRAMEWORK_EXECUTABLE_NAME"
echo "Executable is $FRAMEWORK_EXECUTABLE_PATH"

EXTRACTED_ARCHS=()

for ARCH in $ARCHS
do
echo "Extracting $ARCH from $FRAMEWORK_EXECUTABLE_NAME"
lipo -extract "$ARCH" "$FRAMEWORK_EXECUTABLE_PATH" -o "$FRAMEWORK_EXECUTABLE_PATH-$ARCH"
EXTRACTED_ARCHS+=("$FRAMEWORK_EXECUTABLE_PATH-$ARCH")
done

echo "Merging extracted architectures: ${ARCHS}"
lipo -o "$FRAMEWORK_EXECUTABLE_PATH-merged" -create "${EXTRACTED_ARCHS[@]}"
rm "${EXTRACTED_ARCHS[@]}"

echo "Replacing original executable with thinned version"
rm "$FRAMEWORK_EXECUTABLE_PATH"
mv "$FRAMEWORK_EXECUTABLE_PATH-merged" "$FRAMEWORK_EXECUTABLE_PATH"

done
```

## Carthage frameworks

If you project is using Carthage frameworks, ensure the `carthage copy-frameworks` build phase in present.  Visit [Carthage](https://github.com/Carthage/Carthage) for more information.

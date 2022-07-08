# TriumphSDK

### Instructions
git pull and run
```
pod install
```
or
```
arch -x86_64 pod install
```
### Release
In order to tag a build for this pod and send the the podspec to the podspec repo there are several useful commands
Add the podspec repo
```
pod repo add triumph-sdk-internal-podspec https://github.com/triumpharcade/triumph-sdk-internal-podspec
```
Lint the podspec 
```
arch -x86_64 pod lib lint TriumphSDK.podspec
```

Tag a build
```
git tag '1.0.0'
git push --tags
```


This command is used to push the latest podspec to the podspec repo
```
arch -x86_64 pod repo push triumph-sdk-internal-podspec TriumphSDK.podspec 
--verbose
```
If the verification of the podspec is hanging it is possibly because it is having trouble downloading a dependancy, try deleting the cached pods cd /Users/<#your-user-directory#>/Library/Caches/CocoaPods/Pods 
and running:
```
arch -x86_64 pod repo update
```

### In This Repo
Our Triumph Async SDK code lives in this repo, our example project "Brick breaker" is also in this repo for ease of development, this is the standard development process of cocoapods. 
Running:
```
pod lib create TriumphSDK
```
Made the base for this project

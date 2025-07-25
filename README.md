# obusdk-ios-sample

![Static Badge](https://img.shields.io/badge/release-v1.2.0-blue)

This repository provides a sample app to assist you in integrating the obusdk and its APIs into your applications. 

The Extended OBU Library (EXTOL) enables your applications to connect to the On-Board Unit (OBU) in a user's car to receive Electronic Road Pricing (ERP) and Traffic related messages. It provides a set of APIs that you can use in your app to get data from the OBU. The SDK requires Bluetooth to make a connection, and on iOS, it is using Bluetooth Low Energy (BLE).

The SDK is available as an XCFramework, designed to be used for both simulators and devices. 


## Requirements
- iOS 13.0+
- Xcode 13+ 
- Swift 5 or Objective-C

The OBU SDK is available as a [CocoaPods](https://cocoapods.org/) pod. Cocoapods in an open source dependency manager for Swift and Objective-C projects.

## Getting Started
To get started with the SDK, you will need an SDK Account key, which can be obtained by registering at [DataMall](https://datamall.lta.gov.sg/content/datamall/en/request-for-api.html). After submitting the form, you will receive two emails:

i. The first email will contain the DataMall API Access Key, which you need to access the DataMall APIs.<br/>
ii. The second email will contain the SDK Account Key for the SDK.

Add the SDK key sdkKey = "<SDK Account Key>" in [ViewController](obusdk-ios-sample/ViewController.swift)

## SDK Integration
To integrate the OBU SDK, you will need to install [cocoapods](https://cocoapods.org/)

```
sudo gem install cocoapods
```
Then, create a podfile
```
pod init
```

Add the pod to your app's podfile:

```
platform :ios, '13.0'
use_frameworks!

pod 'extol'
```
Then, install it by running:

```
pod install
```

After the pod is installed, navigate to your project directory and open the .xcworkspace file in Xcode. Then, select a simulator or connect a device and build/run the app.

## Changelog 
All changes are documented in [CHANGELOG.md](CHANGELOG.md).

## License
The SDK is distributed under the terms of use described in the [License](LICENSE) file in this repository.

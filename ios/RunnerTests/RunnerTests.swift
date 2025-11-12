import Flutter
import UIKit
import XCTest

class RunnerTests: XCTestCase {

  func testExample() {
    // If you add code to the Runner application, consider adding tests here.
    // See https://developer.apple.com/documentation/xctest for more information about using XCTest.
  }

  func testAppDelegate() {
    // Test that AppDelegate can be instantiated
    let appDelegate = AppDelegate()
    XCTAssertNotNil(appDelegate, "AppDelegate should not be nil")
  }

  func testFirebaseConfiguration() {
    // Test that Firebase configuration file exists
    let bundle = Bundle(for: RunnerTests.self)
    let path = bundle.path(forResource: "GoogleService-Info", ofType: "plist")
    XCTAssertNotNil(path, "GoogleService-Info.plist should exist in bundle")
  }

}

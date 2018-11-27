//
//  SnapshotTests.swift
//  RendererExampleTests
//
//  Created by JP Wright on 26/11/18.
//  Copyright © 2018 Contentful. All rights reserved.
//

@testable import RendererExample
import ContentfulRichTextRenderer
import Contentful
import XCTest
import Foundation
// https://github.com/pointfreeco/swift-snapshot-testing
import SnapshotTesting
import KIF

func jsonData(_ fileName: String) -> Data {

    let bundle = Bundle(for: SnapshotTests.self)
    let urlPath = bundle.path(forResource: fileName, ofType: "json")!
    let data = try! Data(contentsOf: URL(fileURLWithPath: urlPath))
    return data
}

// https://www.stephencelis.com/2017/09/snapshot-testing-in-swift
class SnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        KIF.KIFEnableAccessibility()
    }

    // Note, both FBSnapshotTestCase and the SnapshotTesting libs do not snapshot the screen 100% correctly
    // Both embedded assets and images do not appear in the snapshot of the UITextView for some reason...
    // But it's better than nothing as all other formatting of the string is maintained in the snapshot.
    func testComplexListSnapshot() {

        // For some reason, if we setup the view hierarchy in the test target, layout happens differently than in main target...
        // Hack: use KIf to safely wait while the thing renders before taking the snapshot
        let viewController = (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController as! ViewController
        tester.waitForView(withAccessibilityLabel: "cat")

        assertSnapshot(matching: viewController.textView)
        assertSnapshot(matching: viewController.textStorage, as: .dump)
    }
}

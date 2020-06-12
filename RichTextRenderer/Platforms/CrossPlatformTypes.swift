// RichTextRenderer

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

public typealias Color = UIColor
public typealias Font = UIFont
public typealias FontDescriptor = UIFontDescriptor
public typealias MutableParagraphStyle = NSMutableParagraphStyle
public typealias View = UIView
#else
import Cocoa
import AppKit

public typealias Color = NSColor
public typealias Font = NSFont
public typealias FontDescriptor = NSFontDescriptor
public typealias MutableParagraphStyle = NSMutableParagraphStyle
public typealias View = NSView
#endif

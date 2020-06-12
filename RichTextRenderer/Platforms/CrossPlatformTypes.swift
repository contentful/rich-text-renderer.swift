// RichTextRenderer

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit

public typealias Color = UIColor
public typealias Font = UIFont
public typealias FontDescriptor = UIFontDescriptor
public typealias View = UIView
public typealias MutableParagraphStyle = NSMutableParagraphStyle
#else
public typealias Color = NSColor
public typealias Font = NSFont
public typealias FontDescriptor = NSFontDescriptor
public typealias View = NSView
#endif

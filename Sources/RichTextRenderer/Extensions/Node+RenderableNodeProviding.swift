// RichTextRenderer

import Contentful

extension BlockQuote: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .blockQuote(self)
    }
}

extension Heading: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .heading(self)
    }
}

extension HorizontalRule: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .horizontalRule(self)
    }
}

extension Table: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .table(self)
    }
}

extension TableRow: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .tableRow(self)
    }
}

extension TableRowCell: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .tableRowCell(self)
    }
}

extension TableRowHeaderCell: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .tableRowHeaderCell(self)
    }
}

extension Hyperlink: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .hyperlink(self)
    }
}

extension ListItem: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .listItem(self)
    }
}

extension OrderedList: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .orderedList(self)
    }
}

extension Paragraph: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .paragraph(self)
    }
}

extension ResourceLinkBlock: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .resourceLinkBlock(self)
    }
}

extension ResourceLinkInline: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .resourceLinkInline(self)
    }
}

extension Text: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .text(self)
    }
}

extension UnorderedList: RenderableNodeProviding {
    public var renderableNode: RenderableNode {
        .unorderedList(self)
    }
}


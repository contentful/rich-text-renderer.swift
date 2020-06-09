// ContentfulRichTextRenderer

extension Dictionary where Key == CodingUserInfoKey {
    var styleConfiguration: RendererConfiguration {
        return self[.rendererConfiguration] as! RendererConfiguration
    }
}

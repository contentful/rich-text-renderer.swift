class SimpleTableView: UIView, ResourceLinkBlockViewRepresentable {
    var context: [CodingUserInfoKey : Any] = [:]
    private let stackView: UIStackView
    private var rows: [SimpleTableViewRow]
    private var measuredWidth: CGFloat = 0
    private var measuredHeight: CGFloat = 0

    func layout(with width: CGFloat) {
        guard width > 0 && !rows.isEmpty else {
            measuredWidth = 0
            measuredHeight = 0
            invalidateIntrinsicContentSize()
            return
        }

        var totalHeight: CGFloat = 0
        for row in rows {
            row.layout(with: width)
            totalHeight += row.intrinsicContentSize.height
        }

        measuredWidth = width
        measuredHeight = totalHeight
        self.frame.size = CGSize(width: measuredWidth, height: measuredHeight)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        // Return the measured width and height
        return CGSize(width: measuredWidth, height: measuredHeight)
    }

    init(rows: [SimpleTableViewRow]) {
        self.rows = rows
        self.stackView = UIStackView(arrangedSubviews: rows)
        super.init(frame: .zero)

        setContentCompressionResistancePriority(.required, for: .vertical)

        stackView.axis = .vertical
        stackView.spacing = 0
        addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = UIColor(red: 177/255, green: 193/255, blue: 203/255, alpha: 1).cgColor
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

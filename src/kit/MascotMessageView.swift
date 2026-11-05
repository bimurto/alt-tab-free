import Cocoa

final class MascotView: NSImageView {
    private static let artwork = NSImage(named: "mascot")

    init() {
        super.init(frame: .zero)
        image = Self.artwork
        imageScaling = .scaleProportionallyUpOrDown
        setAccessibilityElement(false)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Class only supports programmatic initialization")
    }
}

/// The mascot, with a title and a message in a speech bubble beside it.
final class MascotMessageView: NSStackView {
    init(title: String, message: String) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let mascot = MascotView()
        mascot.wantsLayer = true
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
        shadow.shadowBlurRadius = 4
        shadow.shadowOffset = NSSize(width: 0, height: -1)
        mascot.shadow = shadow
        mascot.translatesAutoresizingMaskIntoConstraints = false
        mascot.widthAnchor.constraint(equalToConstant: 76).isActive = true
        mascot.heightAnchor.constraint(equalToConstant: 76).isActive = true
        let heading = Self.label(title, .systemFont(ofSize: 18, weight: .semibold), .labelColor)
        let detail = Self.label(message, .systemFont(ofSize: 13), .secondaryLabelColor)
        let bubble = NSStackView(views: [heading, detail])
        bubble.orientation = .vertical
        bubble.alignment = .leading
        bubble.spacing = SpeechBubbleView.lineSpacing
        let balloon = SpeechBubbleView()
        balloon.pointsRight = userInterfaceLayoutDirection == .rightToLeft
        balloon.translatesAutoresizingMaskIntoConstraints = false
        balloon.addContent(bubble)
        addArrangedSubview(mascot)
        addArrangedSubview(balloon)
        spacing = 10
    }

    private static func label(_ text: String, _ font: NSFont, _ color: NSColor) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = font
        label.textColor = color
        label.isSelectable = false
        return label
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("Class only supports programmatic initialization")
    }
}

final class SpeechBubbleView: NSView {
    static let lineSpacing = CGFloat(4)
    private static let cornerRadius = CGFloat(24)
    private static let contentPadding = CGFloat(18)
    private static let tailWidth = CGFloat(10)
    private static let outlineInset = CGFloat(1)
    var pointsRight = false { didSet { needsDisplay = true } }

    func addContent(_ view: NSView) {
        let inset = Self.outlineInset + Self.contentPadding
        let insets = NSEdgeInsets(top: inset, left: inset + (pointsRight ? 0 : Self.tailWidth),
            bottom: inset, right: inset + (pointsRight ? Self.tailWidth : 0))
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.leftAnchor.constraint(equalTo: leftAnchor, constant: insets.left),
            view.rightAnchor.constraint(equalTo: rightAnchor, constant: -insets.right),
            view.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -insets.bottom),
        ])
    }

    override func layout() {
        super.layout()
        needsDisplay = true
    }

    override func draw(_: NSRect) {
        let path = bubblePath()
        NSColor.controlBackgroundColor.setFill()
        path.fill()
        NSColor.separatorColor.setStroke()
        path.lineWidth = 1
        path.stroke()
    }

    /// One closed silhouette, with no edge crossing the mouth of the tail.
    private func bubblePath() -> NSBezierPath {
        let r = bounds.insetBy(dx: Self.outlineInset, dy: Self.outlineInset)
        let left = r.minX + Self.tailWidth
        let radius = max(0, min(Self.cornerRadius, (r.height - 20) / 2))
        let arc = radius * 0.5522847498
        let p = NSBezierPath()
        p.move(to: NSPoint(x: left + radius, y: r.minY))
        p.line(to: NSPoint(x: r.maxX - radius, y: r.minY))
        p.curve(to: NSPoint(x: r.maxX, y: r.minY + radius),
            controlPoint1: NSPoint(x: r.maxX - radius + arc, y: r.minY),
            controlPoint2: NSPoint(x: r.maxX, y: r.minY + radius - arc))
        p.line(to: NSPoint(x: r.maxX, y: r.maxY - radius))
        p.curve(to: NSPoint(x: r.maxX - radius, y: r.maxY),
            controlPoint1: NSPoint(x: r.maxX, y: r.maxY - radius + arc),
            controlPoint2: NSPoint(x: r.maxX - radius + arc, y: r.maxY))
        p.line(to: NSPoint(x: left + radius, y: r.maxY))
        p.curve(to: NSPoint(x: left, y: r.maxY - radius),
            controlPoint1: NSPoint(x: left + radius - arc, y: r.maxY),
            controlPoint2: NSPoint(x: left, y: r.maxY - radius + arc))
        p.line(to: NSPoint(x: left, y: r.midY + 8))
        p.line(to: NSPoint(x: r.minX, y: r.midY))
        p.line(to: NSPoint(x: left, y: r.midY - 8))
        p.line(to: NSPoint(x: left, y: r.minY + radius))
        p.curve(to: NSPoint(x: left + radius, y: r.minY),
            controlPoint1: NSPoint(x: left, y: r.minY + radius - arc),
            controlPoint2: NSPoint(x: left + radius - arc, y: r.minY))
        p.close()
        if pointsRight {
            p.transform(using: AffineTransform(m11: -1, m12: 0, m21: 0, m22: 1, tX: bounds.width, tY: 0))
        }
        return p
    }
}

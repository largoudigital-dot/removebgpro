import UIKit

/// A customizable UIKit button that displays an image with shadow, corner radius, and border.
/// Solves the standard UIKit issue where shadow and 'masksToBounds' (corner radius) are mutually exclusive
/// by using a layered container approach.
class StyledImageButton: UIButton {
    
    // MARK: - Subviews
    private let contentContainer = UIView()
    private let customImageView = UIImageView()
    
    // MARK: - Properties: Corner Radius
    var cornerRadius: CGFloat = 0 {
        didSet { updateStyles() }
    }
    
    // MARK: - Properties: Shadow
    var shadowColor: UIColor = .black {
        didSet { updateStyles() }
    }
    var shadowOpacity: Float = 0.5 {
        didSet { updateStyles() }
    }
    var shadowOffset: CGSize = CGSize(width: 0, height: 4) {
        didSet { updateStyles() }
    }
    var shadowRadius: CGFloat = 4 {
        didSet { updateStyles() }
    }
    
    // MARK: - Properties: Border
    var borderColor: UIColor = .clear {
        didSet { updateStyles() }
    }
    var borderWidth: CGFloat = 0 {
        didSet { updateStyles() }
    }
    
    // MARK: - Properties: Image
    var image: UIImage? {
        get { customImageView.image }
        set { customImageView.image = newValue }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        // 1. Container configuration (Handles Shadow)
        contentContainer.isUserInteractionEnabled = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)
        
        // 2. ImageView configuration (Handles Image, Corner Radius, and Border)
        customImageView.contentMode = .scaleAspectFill
        customImageView.clipsToBounds = true
        customImageView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(customImageView)
        
        // 3. Constraints
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            customImageView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            customImageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            customImageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            customImageView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateStyles()
    }
    
    private func updateStyles() {
        // Apply styling to contentContainer (The Shadow)
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        layer.shadowRadius = shadowRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
        
        // Apply styling to customImageView (Rounded Corners & Border)
        customImageView.layer.cornerRadius = cornerRadius
        customImageView.layer.borderColor = borderColor.cgColor
        customImageView.layer.borderWidth = borderWidth
    }
}

// MARK: - Usage Example
/*
let button = StyledImageButton(frame: CGRect(x: 100, y: 100, width: 60, height: 60))
button.image = UIImage(named: "profile_thumb")
button.cornerRadius = 15
button.shadowColor = .black
button.shadowOpacity = 0.3
button.shadowOffset = CGSize(width: 0, height: 5)
button.shadowRadius = 10
button.borderColor = .white
button.borderWidth = 2
*/

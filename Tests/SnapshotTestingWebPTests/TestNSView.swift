#if os(macOS)
    import AppKit

    /// Creates a complex test view for macOS snapshot testing
    /// This view contains gradients, shadows, cards, and text for realistic compression testing
    func createTestNSView() -> NSView {
        let containerView = NSView(frame: CGRect(x: 0, y: 0, width: 500, height: 600))
        containerView.wantsLayer = true
        containerView.layer?.backgroundColor = NSColor(calibratedRed: 0.95, green: 0.95, blue: 0.97, alpha: 1.0).cgColor

        // Header with gradient
        let headerView = createHeaderView()
        containerView.addSubview(headerView)

        // Profile section
        let profileView = createProfileSection()
        profileView.frame.origin = CGPoint(x: 20, y: containerView.bounds.height - 220)
        containerView.addSubview(profileView)

        // Stats section
        let statsView = createStatsSection()
        statsView.frame.origin = CGPoint(x: 20, y: containerView.bounds.height - 310)
        containerView.addSubview(statsView)

        // Action buttons
        let buttonsView = createActionButtons()
        buttonsView.frame.origin = CGPoint(x: 20, y: containerView.bounds.height - 370)
        containerView.addSubview(buttonsView)

        // Featured cards
        let cardsView = createFeaturedCards()
        cardsView.frame.origin = CGPoint(x: 20, y: containerView.bounds.height - 500)
        containerView.addSubview(cardsView)

        // Activity section
        let activityView = createActivitySection()
        activityView.frame.origin = CGPoint(x: 20, y: 20)
        containerView.addSubview(activityView)

        return containerView
    }

    private func createHeaderView() -> NSView {
        let headerView = NSView(frame: CGRect(x: 0, y: 450, width: 500, height: 150))
        headerView.wantsLayer = true

        // Gradient background
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = headerView.bounds
        gradientLayer.colors = [
            NSColor(calibratedRed: 0.3, green: 0.5, blue: 0.9, alpha: 1.0).cgColor,
            NSColor(calibratedRed: 0.6, green: 0.4, blue: 0.8, alpha: 1.0).cgColor,
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        headerView.layer?.addSublayer(gradientLayer)

        // Decorative circles
        let circle1 = CAShapeLayer()
        circle1.path = CGPath(ellipseIn: CGRect(x: -30, y: -30, width: 100, height: 100), transform: nil)
        circle1.fillColor = NSColor.white.withAlphaComponent(0.1).cgColor
        headerView.layer?.addSublayer(circle1)

        let circle2 = CAShapeLayer()
        circle2.path = CGPath(ellipseIn: CGRect(x: 400, y: 50, width: 120, height: 120), transform: nil)
        circle2.fillColor = NSColor.white.withAlphaComponent(0.08).cgColor
        headerView.layer?.addSublayer(circle2)

        let circle3 = CAShapeLayer()
        circle3.path = CGPath(ellipseIn: CGRect(x: 200, y: -20, width: 80, height: 80), transform: nil)
        circle3.fillColor = NSColor.white.withAlphaComponent(0.12).cgColor
        headerView.layer?.addSublayer(circle3)

        return headerView
    }

    private func createProfileSection() -> NSView {
        let profileView = NSView(frame: CGRect(x: 0, y: 0, width: 460, height: 100))
        profileView.wantsLayer = true

        // Avatar
        let avatarView = NSView(frame: CGRect(x: 0, y: 20, width: 80, height: 80))
        avatarView.wantsLayer = true
        avatarView.layer?.cornerRadius = 40
        avatarView.layer?.backgroundColor = NSColor(calibratedRed: 0.3, green: 0.5, blue: 0.9, alpha: 1.0).cgColor
        avatarView.layer?.borderWidth = 3
        avatarView.layer?.borderColor = NSColor.white.cgColor
        avatarView.layer?.shadowColor = NSColor.black.cgColor
        avatarView.layer?.shadowOffset = CGSize(width: 0, height: 2)
        avatarView.layer?.shadowRadius = 4
        avatarView.layer?.shadowOpacity = 0.2
        profileView.addSubview(avatarView)

        // Avatar initials
        let initialsLabel = NSTextField(labelWithString: "JD")
        initialsLabel.font = NSFont.boldSystemFont(ofSize: 28)
        initialsLabel.textColor = .white
        initialsLabel.alignment = .center
        initialsLabel.frame = CGRect(x: 0, y: 25, width: 80, height: 30)
        avatarView.addSubview(initialsLabel)

        // Online indicator
        let onlineIndicator = NSView(frame: CGRect(x: 60, y: 20, width: 16, height: 16))
        onlineIndicator.wantsLayer = true
        onlineIndicator.layer?.cornerRadius = 8
        onlineIndicator.layer?.backgroundColor = NSColor(calibratedRed: 0.2, green: 0.8, blue: 0.4, alpha: 1.0).cgColor
        onlineIndicator.layer?.borderWidth = 2
        onlineIndicator.layer?.borderColor = NSColor.white.cgColor
        profileView.addSubview(onlineIndicator)

        // Name
        let nameLabel = NSTextField(labelWithString: "John Doe")
        nameLabel.font = NSFont.boldSystemFont(ofSize: 22)
        nameLabel.textColor = NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        nameLabel.frame = CGRect(x: 100, y: 60, width: 200, height: 30)
        profileView.addSubview(nameLabel)

        // Username
        let usernameLabel = NSTextField(labelWithString: "@johndoe")
        usernameLabel.font = NSFont.systemFont(ofSize: 14)
        usernameLabel.textColor = NSColor.secondaryLabelColor
        usernameLabel.frame = CGRect(x: 100, y: 40, width: 100, height: 20)
        profileView.addSubview(usernameLabel)

        // Bio
        let bioLabel = NSTextField(labelWithString: "Swift Developer & WebP Enthusiast")
        bioLabel.font = NSFont.systemFont(ofSize: 13)
        bioLabel.textColor = NSColor.secondaryLabelColor
        bioLabel.frame = CGRect(x: 100, y: 20, width: 300, height: 20)
        profileView.addSubview(bioLabel)

        // Verified badge
        let verifiedBadge = NSView(frame: CGRect(x: 200, y: 65, width: 20, height: 20))
        verifiedBadge.wantsLayer = true
        verifiedBadge.layer?.cornerRadius = 10
        verifiedBadge.layer?.backgroundColor = NSColor(calibratedRed: 0.2, green: 0.6, blue: 1.0, alpha: 1.0).cgColor
        profileView.addSubview(verifiedBadge)

        let checkLabel = NSTextField(labelWithString: "\u{2713}")
        checkLabel.font = NSFont.boldSystemFont(ofSize: 12)
        checkLabel.textColor = .white
        checkLabel.alignment = .center
        checkLabel.frame = CGRect(x: 0, y: 2, width: 20, height: 16)
        verifiedBadge.addSubview(checkLabel)

        return profileView
    }

    private func createStatsSection() -> NSView {
        let statsView = NSView(frame: CGRect(x: 0, y: 0, width: 460, height: 70))
        statsView.wantsLayer = true
        statsView.layer?.backgroundColor = NSColor.white.cgColor
        statsView.layer?.cornerRadius = 12
        statsView.layer?.shadowColor = NSColor.black.cgColor
        statsView.layer?.shadowOffset = CGSize(width: 0, height: 2)
        statsView.layer?.shadowRadius = 8
        statsView.layer?.shadowOpacity = 0.1

        let stats = [
            ("1.2K", "Followers"),
            ("348", "Following"),
            ("56", "Projects"),
            ("4.9", "Rating"),
        ]

        let statWidth: CGFloat = 115
        for (index, stat) in stats.enumerated() {
            let statContainer = NSView(
                frame: CGRect(x: CGFloat(index) * statWidth, y: 10, width: statWidth, height: 50)
            )

            let valueLabel = NSTextField(labelWithString: stat.0)
            valueLabel.font = NSFont.boldSystemFont(ofSize: 18)
            valueLabel.textColor = NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
            valueLabel.alignment = .center
            valueLabel.frame = CGRect(x: 0, y: 25, width: statWidth, height: 25)
            statContainer.addSubview(valueLabel)

            let titleLabel = NSTextField(labelWithString: stat.1)
            titleLabel.font = NSFont.systemFont(ofSize: 12)
            titleLabel.textColor = NSColor.secondaryLabelColor
            titleLabel.alignment = .center
            titleLabel.frame = CGRect(x: 0, y: 5, width: statWidth, height: 18)
            statContainer.addSubview(titleLabel)

            statsView.addSubview(statContainer)

            // Divider
            if index < stats.count - 1 {
                let divider = NSView(
                    frame: CGRect(x: CGFloat(index + 1) * statWidth - 0.5, y: 15, width: 1, height: 40)
                )
                divider.wantsLayer = true
                divider.layer?.backgroundColor = NSColor.separatorColor.cgColor
                statsView.addSubview(divider)
            }
        }

        return statsView
    }

    private func createActionButtons() -> NSView {
        let buttonsView = NSView(frame: CGRect(x: 0, y: 0, width: 460, height: 44))

        // Follow button
        let followButton = NSView(frame: CGRect(x: 0, y: 0, width: 220, height: 44))
        followButton.wantsLayer = true
        followButton.layer?.cornerRadius = 22
        followButton.layer?.backgroundColor = NSColor(calibratedRed: 0.3, green: 0.5, blue: 0.9, alpha: 1.0).cgColor

        let followLabel = NSTextField(labelWithString: "Follow")
        followLabel.font = NSFont.boldSystemFont(ofSize: 15)
        followLabel.textColor = .white
        followLabel.alignment = .center
        followLabel.frame = CGRect(x: 0, y: 12, width: 220, height: 20)
        followButton.addSubview(followLabel)
        buttonsView.addSubview(followButton)

        // Message button
        let messageButton = NSView(frame: CGRect(x: 240, y: 0, width: 220, height: 44))
        messageButton.wantsLayer = true
        messageButton.layer?.cornerRadius = 22
        messageButton.layer?.backgroundColor = NSColor.white.cgColor
        messageButton.layer?.borderWidth = 2
        messageButton.layer?.borderColor = NSColor(calibratedRed: 0.3, green: 0.5, blue: 0.9, alpha: 1.0).cgColor

        let messageLabel = NSTextField(labelWithString: "Message")
        messageLabel.font = NSFont.boldSystemFont(ofSize: 15)
        messageLabel.textColor = NSColor(calibratedRed: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
        messageLabel.alignment = .center
        messageLabel.frame = CGRect(x: 0, y: 12, width: 220, height: 20)
        messageButton.addSubview(messageLabel)
        buttonsView.addSubview(messageButton)

        return buttonsView
    }

    private func createFeaturedCards() -> NSView {
        let cardsContainer = NSView(frame: CGRect(x: 0, y: 0, width: 460, height: 110))

        let cards = [
            ("Swift Package", NSColor(calibratedRed: 0.9, green: 0.4, blue: 0.3, alpha: 1.0)),
            ("iOS App", NSColor(calibratedRed: 0.3, green: 0.7, blue: 0.5, alpha: 1.0)),
            ("Framework", NSColor(calibratedRed: 0.5, green: 0.4, blue: 0.8, alpha: 1.0)),
            ("CLI Tool", NSColor(calibratedRed: 0.9, green: 0.6, blue: 0.2, alpha: 1.0)),
        ]

        let cardWidth: CGFloat = 105
        let spacing: CGFloat = 10

        for (index, card) in cards.enumerated() {
            let cardView = NSView(
                frame: CGRect(x: CGFloat(index) * (cardWidth + spacing), y: 0, width: cardWidth, height: 110)
            )
            cardView.wantsLayer = true
            cardView.layer?.cornerRadius = 12
            cardView.layer?.backgroundColor = card.1.cgColor
            cardView.layer?.shadowColor = NSColor.black.cgColor
            cardView.layer?.shadowOffset = CGSize(width: 0, height: 2)
            cardView.layer?.shadowRadius = 4
            cardView.layer?.shadowOpacity = 0.15

            let titleLabel = NSTextField(labelWithString: card.0)
            titleLabel.font = NSFont.boldSystemFont(ofSize: 12)
            titleLabel.textColor = .white
            titleLabel.alignment = .center
            titleLabel.frame = CGRect(x: 5, y: 10, width: cardWidth - 10, height: 30)
            titleLabel.lineBreakMode = .byWordWrapping
            titleLabel.maximumNumberOfLines = 2
            cardView.addSubview(titleLabel)

            // Icon placeholder
            let iconView = NSView(frame: CGRect(x: (cardWidth - 40) / 2, y: 55, width: 40, height: 40))
            iconView.wantsLayer = true
            iconView.layer?.cornerRadius = 8
            iconView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.3).cgColor
            cardView.addSubview(iconView)

            cardsContainer.addSubview(cardView)
        }

        return cardsContainer
    }

    private func createActivitySection() -> NSView {
        let activityView = NSView(frame: CGRect(x: 0, y: 0, width: 460, height: 90))
        activityView.wantsLayer = true
        activityView.layer?.backgroundColor = NSColor.white.cgColor
        activityView.layer?.cornerRadius = 12
        activityView.layer?.shadowColor = NSColor.black.cgColor
        activityView.layer?.shadowOffset = CGSize(width: 0, height: 2)
        activityView.layer?.shadowRadius = 8
        activityView.layer?.shadowOpacity = 0.1

        let titleLabel = NSTextField(labelWithString: "Recent Activity")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
        titleLabel.frame = CGRect(x: 15, y: 60, width: 200, height: 20)
        activityView.addSubview(titleLabel)

        let activities = [
            ("WebP encoding completed", "2 min ago", NSColor(calibratedRed: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)),
            (
                "New compression preset saved", "1 hour ago",
                NSColor(calibratedRed: 0.3, green: 0.5, blue: 0.9, alpha: 1.0)
            ),
        ]

        for (index, activity) in activities.enumerated() {
            let yOffset = 35 - CGFloat(index) * 25

            let indicator = NSView(frame: CGRect(x: 15, y: yOffset + 4, width: 8, height: 8))
            indicator.wantsLayer = true
            indicator.layer?.cornerRadius = 4
            indicator.layer?.backgroundColor = activity.2.cgColor
            activityView.addSubview(indicator)

            let activityLabel = NSTextField(labelWithString: activity.0)
            activityLabel.font = NSFont.systemFont(ofSize: 12)
            activityLabel.textColor = NSColor(calibratedRed: 0.15, green: 0.15, blue: 0.2, alpha: 1.0)
            activityLabel.frame = CGRect(x: 30, y: yOffset, width: 280, height: 18)
            activityView.addSubview(activityLabel)

            let timeLabel = NSTextField(labelWithString: activity.1)
            timeLabel.font = NSFont.systemFont(ofSize: 11)
            timeLabel.textColor = NSColor.secondaryLabelColor
            timeLabel.alignment = .right
            timeLabel.frame = CGRect(x: 320, y: yOffset, width: 120, height: 18)
            activityView.addSubview(timeLabel)
        }

        return activityView
    }
#endif

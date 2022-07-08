// Copyright © TriumphSDK. All rights reserved.
// swiftlint:disable all

import TriumphCommon

extension SwiftMessage {
    func quitGameWarning(model: SwiftMessageModel) {
        Task {
            await MainActor.run {
                let view = MessageView.viewFromNib(layout: .centeredView)
                view.configureTheme(.warning)
                view.configureDropShadow()
                view.backgroundView.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
                view.button?.setTitle("Forfeit Game", for: .normal)
                view.button?.setTitleColor(#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1), for: .normal)
                view.buttonTapHandler = { button in
                    if let action = model.action {
                        action(button)
                    }
                    NotificationCenter.default.post(name: .stopMatchingHaptics, object: nil)
                    SwiftMessages.hide()
                }
                view.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                view.bodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                view.configureIcon(withSize: CGSize(width: 50, height: 50), contentMode: .scaleAspectFill)
                view.iconImageView?.image = UIImage(systemName: "exclamationmark.octagon.fill")
                view.button?.isHidden = false
                view.titleLabel?.setText(model.title)
                view.bodyLabel?.setText(model.message)
                SwiftMessages.show(config: swiftMessageTopPremenantConfig, view: view)
            }
        }
    }
    
    func blitzInfoMessage(model: SwiftMessageModel) {
        Task {
            await MainActor.run {
                let view = MessageView.viewFromNib(layout: .centeredView)
                view.configureTheme(.info)
                view.configureDropShadow()
                view.backgroundView.backgroundColor = .lead
                view.button?.isHidden = true
                view.titleLabel?.setText(model.title)
                view.bodyLabel?.setText(model.message)
                view.iconLabel?.text = "⚡️"
                view.configureContent(title: model.title, body: model.message, iconText: .string("⚡️"))
                view.titleLabel?.textColor = .white
                view.bodyLabel?.textColor = .white
                view.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                view.bodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                SwiftMessages.show(config: swiftMessageTopPremenantConfig, view: view)
            }
        }
    }
    
    func missionCompletedMessage(model: SwiftMessageModel) {
        Task {
            await MainActor.run {
                let view = MessageView.viewFromNib(layout: .centeredView)
                view.configureTheme(.info)
                view.configureDropShadow()
                view.backgroundView.backgroundColor = .lead
                view.button?.isHidden = true
                view.titleLabel?.setText(model.title)
                view.bodyLabel?.setText(model.message)
//                view.iconLabel?.text = model.emoji ?? "⛳️"
//                if let emoji = model.emoji {
//                    view.iconLabel?.setText(.string(emoji))
//                } else if let attrEmoji = model.attributedEmoji {
//                    view.iconLabel?.setText(attrEmoji)
//                } else {
//                    view.iconLabel?.setText(.string("⛳️"))
//                }
                view.iconLabel?.setText(model.emoji ?? .string("⛳️"))
                
                view.configureContent(title: model.title, body: model.message, iconText: model.emoji ?? .string("⛳️"))
                view.titleLabel?.textColor = .white
                view.bodyLabel?.textColor = .white
                view.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                view.bodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                SwiftMessages.show(config: swiftMessageTopTemporaryConfig, view: view)
            }
        }
    }
    
    func firstLoginMessage(model: SwiftMessageModel) {
        Task {
            await MainActor.run {
                let view = MessageView.viewFromNib(layout: .centeredView)
                view.configureTheme(.info)
                view.configureDropShadow()
                view.backgroundView.backgroundColor = .lead
                view.button?.isHidden = true
                view.titleLabel?.setText(model.title)
                view.bodyLabel?.setText(model.message)
                view.iconLabel?.text = "👋"
                view.configureContent(title: model.title, body: model.message, iconText: .string("👋"))
                view.titleLabel?.textColor = .white
                view.bodyLabel?.textColor = .white
                view.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                view.bodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                SwiftMessages.show(config: swiftMessageTopPremenantConfig, view: view)
            }
        }
    }
    
    func noTicketsMessage(model: SwiftMessageModel) {
        Task {
            await MainActor.run {
                let view = MessageView.viewFromNib(layout: .centeredView)
                view.configureTheme(.info)
                view.configureDropShadow()
                view.backgroundView.backgroundColor = .lead
                view.button?.isHidden = true
                view.titleLabel?.setText(model.title)
                view.bodyLabel?.setText(model.message)
                view.iconLabel?.text = "🎟️"
                view.configureContent(title: model.title, body: model.message, iconText: .string("🎟️"))
                view.titleLabel?.textColor = .white
                view.bodyLabel?.textColor = .white
                view.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
                view.bodyLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                SwiftMessages.show(config: swiftMessageTopPremenantConfig, view: view)
            }
        }
    }
}

extension SwiftMessage {
    func showQuitGameWarning(completion: @escaping () -> Void) {
        let model = SwiftMessageModel(
            title: .string("Warning"),
            message: .string("Exiting will result in an automatic forfeit. Tap outside this message to dismiss.")
        ) { _ in
            completion()
        }
        quitGameWarning(model: model)
    }
    
    func showHotStreakInfoMessage() {
        let messageModel = SwiftMessageModel(
            title: .string("Hot Streak"),
            message: .string("Win five paid 1 vs 1 tournaments in a row and receive a bonus!")
        )
        showMessage(messageModel)
    }
    
    func showHotStreakWonMessage() {
        let messageModel = SwiftMessageModel(
            title: .string("You Won"),
            message: .string("Here's your hot streak bonus - keep up the great work!")
        )
        showMessage(messageModel)
    }
    
    func showMissionCompletedMessage(mission: MissionModel) {
        if let reward = mission.rewardReceived[dependencies.appInfo.id] {
            var message = "You completed \(mission.title.capitalized). Here's \(reward.formatCurrency()) on us -- keep up the great work!"
            if mission.rewardType == .tree {
                message = "You completed \(mission.title.capitalized). We've planted \(reward) tree\(reward != 1 ? "s": "") for you! \n\n This is not a joke. We've actually planted \(reward == 1 ? "a real tree": "real trees")!"
            } else if mission.rewardType == .token {
                message = "You completed \(mission.title.capitalized). Here's \(reward) tokens on us -- keep up the great work!"
            }
            let model = SwiftMessageModel(
                title: .string("Mission Complete"),
                message: .string(message),
                emoji: .string(mission.emoji)
            )
            showMessage(model)
            missionCompletedMessage(model: model)
        }
    }
    
    func showMissionDescriptionMessage(mission: MissionModel) {
        if let description = mission.description {
            var message = description
            if let progress = mission.missionProgress,
               let completion = mission.missionCompletion {
                let percentCompletion = Int((Double(progress) / Double(completion)) * 100)
                message += "\n\n\(percentCompletion)% complete"
            }
            let model = SwiftMessageModel(
                title: .string(mission.title.capitalized),
                message: .string(message),
                emoji: .string(mission.emoji)
            )
            missionCompletedMessage(model: model)
        }
    }
    
    func showWelcomeRewardClaimedMessage(unclaimedBalance: Int) {
        let model = SwiftMessageModel(
            title: .string("Mission Complete"),
            message: .string("You've signed up for Triumph. Here's \(unclaimedBalance.formatCurrency()) on us -- keep up the great work!"),
            emoji: .string("👋")
        )
        missionCompletedMessage(model: model)
    }
    
    func showReferralCompletedSwiftMessage() {
        let model = SwiftMessageModel(
            title: .string("Mission Complete"),
            message: .string("You completed Referral. Here's $5 on us -- keep up the great work!"),
            emoji: .string("🤝")
        )
        showMessage(model)
    }
    
    func showAsyncGameDescriptionMessage() {
        let model = SwiftMessageModel(
            title: .string("Waiting for Opponent"),
            message: .string("We're searching for an opponent now. You'll be matched with someone at a similar skill level."),
            emoji: .string("🔎")
        )
        missionCompletedMessage(model: model)
    }
    
    func showNewGameRewardMessage(gameId: String, reward: Int) {
        var message = "You've downloaded \(gameId.capitalized). Here's \(reward) tokens on us -- keep up the great work!"
        let model = SwiftMessageModel(
            title: .string("Mission Complete"),
            message: .string(message),
            emoji: .string("🎉")
        )
        showMessage(model)
    }
    
    func showTokenInfoSwiftMessage() {
        let model = SwiftMessageModel(
            title: .string("Tokens"),
            message: .string("Use tokens as cash to enter tournaments. They subsidize your buy-in"),
            emoji: .attributedString(NSMutableAttributedString.largeToken)
        )
        missionCompletedMessage(model: model)
    }
    
    func showBlitzModeInfoMessage() {
        let model = SwiftMessageModel(
            title: .string("Blitz Mode"),
            message: .string("When you pass a score on the lefthand side, your prize jumps to the associated value on the righthand side. \n\n Prizes and scores are calculated from a rolling average of previous games. \n\n Change your buy-in at the top to raise the stakes.")
        )
        blitzInfoMessage(model: model)
    }
    
    func showFirstLoginMessage(completion: @escaping () -> Void) {
        Task {
            await MainActor.run {
                let verifyCard = MessageView.viewFromNib(layout: .centeredView)
                verifyCard.configureDropShadow()
                verifyCard.configureTheme(backgroundColor: .lead, foregroundColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                verifyCard.heightAnchor.constraint(equalToConstant: 300).isActive = true
                verifyCard.titleLabel?.text = "👋 Welcome 👋"
                Task {
                    let balance = (Double(await dependencies.sharedSession.user?.balance ?? 100)/100).formatCurrency()
                    await MainActor.run {
                        verifyCard.bodyLabel?.text = "Here's a gift to get you started. To the victor goes the spoils!"
                        verifyCard.titleLabel?.font = UIFont.systemFont(ofSize: 32, weight: .bold)
                        verifyCard.bodyLabel?.font = UIFont.systemFont(ofSize: 19, weight: .regular)

                        verifyCard.button?.setTitle("Claim \(balance)", for: .normal)
                        verifyCard.button?.titleLabel?.font = UIFont.systemFont(ofSize: 21, weight: .bold)
                        verifyCard.button?.setTitleColor(.white, for: .normal)
                        verifyCard.button?.backgroundColor = TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR
                        verifyCard.buttonTapHandler = { _ in
                            UINotificationFeedbackGenerator().notificationOccurred(.success)
                            SwiftMessages.hide()
                            completion()
                        }
                        verifyCard.button?.translatesAutoresizingMaskIntoConstraints = false
                        verifyCard.button?.leftAnchor.constraint(equalTo: verifyCard.leftAnchor, constant: 35).isActive = true
                        verifyCard.button?.rightAnchor.constraint(equalTo: verifyCard.rightAnchor, constant: -35).isActive = true
                        verifyCard.button?.centerXAnchor.constraint(equalTo: verifyCard.centerXAnchor).isActive = true
                        verifyCard.button?.bottomAnchor.constraint(equalTo: verifyCard.bottomAnchor,constant: -60).isActive = true
                        verifyCard.button?.heightAnchor.constraint(equalToConstant: 50).isActive = true
                        verifyCard.button?.layer.cornerRadius = 25
                        verifyCard.button?.layer.doGlowAnimation(withColor: TriumphSDK.colors.TRIUMPH_PRIMARY_COLOR)
                        SwiftMessages.show(config: switMessageBottomPermenantConfig, view: verifyCard)
                    }
                }
            }
        }
    }
}

//
//  MyMessageController.swift
//  Cheetos-iOS
//
//  Created by 김민우 on 8/28/25.
//
import UIKit


final class MyMessageController: UIViewController {

    private let bubble = UIView()
    private let label = UILabel()
    private let timeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func configure(message: MyMessage) {
        label.text = message.content ?? ""
        if let ts = message.createdAt {
            timeLabel.text = Self.hhmm(ts)
        } else {
            timeLabel.text = nil
        }
    }

    private func setupUI() {
        view.backgroundColor = .clear

        bubble.layer.cornerRadius = 18
        bubble.layer.masksToBounds = true
        bubble.backgroundColor = .systemBlue

        label.numberOfLines = 0
        label.textColor = .white

        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.8)

        view.addSubview(bubble)
        bubble.addSubview(label)
        bubble.addSubview(timeLabel)

        [bubble, label, timeLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            // 오른쪽 정렬
            bubble.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bubble.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 60),
            bubble.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            bubble.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),

            label.topAnchor.constraint(equalTo: bubble.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: bubble.leadingAnchor, constant: 12),
            label.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -12),

            timeLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 6),
            timeLabel.trailingAnchor.constraint(equalTo: bubble.trailingAnchor, constant: -10),
            timeLabel.bottomAnchor.constraint(equalTo: bubble.bottomAnchor, constant: -8),
        ])
    }

    private static func hhmm(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    }
}


// MARK: View
final class MessageHostingCell: UITableViewCell {
    static let reuseID = "MessageHostingCell"

    private weak var hostedVC: UIViewController?

    func embed(_ vc: UIViewController, into parent: UIViewController) {
        unembedIfNeeded()

        parent.addChild(vc)
        contentView.addSubview(vc.view)
        vc.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vc.view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            vc.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            vc.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            vc.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
        ])
        vc.didMove(toParent: parent)
        hostedVC = vc
    }

    func unembedIfNeeded() {
        guard let vc = hostedVC else { return }
        vc.willMove(toParent: nil)
        vc.view.removeFromSuperview()
        vc.removeFromParent()
        hostedVC = nil
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        unembedIfNeeded()
    }
}

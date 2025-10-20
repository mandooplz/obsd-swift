//
//  FortuneController.swift
//  Cheetos-iOS
//
//  Created by 김민우 on 8/28/25.
//
import UIKit


// MARK: View
final class FortuneController: UIViewController {

    private let bubble = UIView()
    private let label = UILabel()
    private let timeLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    func configure(fortune: Fortune) {
        let text = fortune.content ?? "불러오는 중..."
        label.text = text
        if let ts = fortune.createdAt {
            timeLabel.text = Self.hhmm(ts)
        } else {
            timeLabel.text = nil
        }
    }

    private func setupUI() {
        view.backgroundColor = .clear

        bubble.layer.cornerRadius = 18
        bubble.layer.masksToBounds = true
        bubble.backgroundColor = .secondarySystemBackground

        label.numberOfLines = 0
        label.textColor = .label

        timeLabel.font = .systemFont(ofSize: 11)
        timeLabel.textColor = .secondaryLabel

        view.addSubview(bubble)
        bubble.addSubview(label)
        bubble.addSubview(timeLabel)

        [bubble, label, timeLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        NSLayoutConstraint.activate([
            // 왼쪽 정렬
            bubble.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bubble.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -60),
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

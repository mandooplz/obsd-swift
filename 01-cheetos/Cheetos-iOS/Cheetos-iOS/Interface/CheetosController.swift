//
//  CheetosViewController.swift
//  Cheetos-iOS
//
//  Created by 김민우 on 8/28/25.
//
import UIKit
import Observation


// 루트 화면
final class CheetosController: UIViewController {
    // object
    private let cheetosRef: Cheetos = Cheetos()
    init() {
        super.init(nibName: nil, bundle: nil)
        self.title = "운세 메신저"
    }

    // body
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let topButton = UIButton(type: .system)
    private let inputBar = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)

    // Insets
    private let barTopSpacing: CGFloat = 8   // distance between table and input bar
    private let bottomPadding: CGFloat = 26  // extra space so last timestamp isn't hidden

    private let inputBarHeight: CGFloat = 52

    private var inputBottomConstraint: NSLayoutConstraint!
    private var isTrackingInstalled = false

    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // 초기설정
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        applyEmptyStateIfNeeded()
    }

    private func applyEmptyStateIfNeeded() {
        if cheetosRef.messages.isEmpty {
            let empty = EmptyStateView()
            tableView.backgroundView = empty
        } else {
            tableView.backgroundView = nil
        }
    }
    
    private func updateBottomInsets(extraKeyboard: CGFloat) {
        // base inset: input bar height + spacing above it + a little padding + safe area
        let base = inputBarHeight + barTopSpacing + bottomPadding + view.safeAreaInsets.bottom
        let inset = base + extraKeyboard
        tableView.contentInset.bottom = inset
        tableView.scrollIndicatorInsets.bottom = inset
    }

    private final class EmptyStateView: UIView {
        private let label = UILabel()
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            label.text = "메시지가 없습니다.\n상단 버튼을 눌러 운세를 받아보세요!"
            label.textColor = .secondaryLabel
            label.font = .systemFont(ofSize: 16, weight: .regular)
            label.textAlignment = .center
            label.numberOfLines = 0
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: centerXAnchor),
                label.centerYAnchor.constraint(equalTo: centerYAnchor),
                label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 24),
                label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -24),
            ])
        }
        required init?(coder: NSCoder) { fatalError() }
    }

    private func setupUI() {
        // table
        tableView.register(MessageHostingCell.self, forCellReuseIdentifier: MessageHostingCell.reuseID)
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        tableView.keyboardDismissMode = .interactive
        
        let baseInset: CGFloat = 60 // 입력바 높이 + 여유
        tableView.contentInset.bottom = baseInset
        tableView.scrollIndicatorInsets.bottom = baseInset
        
        tableView.dataSource = self
        tableView.delegate = self
        
        

        // navigation bar (+) with context menu
        let fortuneAction = UIAction(title: "오늘의 운세 받기", image: UIImage(systemName: "sparkles")) { [weak self] _ in
            self?.didTapFortune()
        }
        if #available(iOS 14.0, *) {
            let menu = UIMenu(title: "", children: [fortuneAction])
            navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: nil, menu: menu)
        } else {
            // Fallback: tap on + triggers action directly (no menu)
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapFortune))
        }

        // 입력바
        inputBar.backgroundColor = .secondarySystemBackground
        inputBar.layer.cornerRadius = 16
        inputBar.layer.masksToBounds = true

        textField.placeholder = "메시지 입력"
        textField.borderStyle = .none
        textField.returnKeyType = .send
        textField.delegate = self

        sendButton.setTitle("전송", for: .normal)
        sendButton.setContentHuggingPriority(.required, for: .horizontal)
        sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)

        // 키보드에 가려지지 않도록 테이블 인셋(입력바 높이만큼)
        updateBottomInsets(extraKeyboard: 0)

        view.addSubview(tableView)
        view.addSubview(inputBar)
        inputBar.addSubview(textField)
        inputBar.addSubview(sendButton)
        view.bringSubviewToFront(inputBar)
    }

    private func setupConstraints() {
        [tableView, topButton, inputBar, textField, sendButton].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }

        inputBottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8)

        NSLayoutConstraint.activate([
            // 테이블
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // 입력바 (고정 높이!)
            inputBottomConstraint,
            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            inputBar.heightAnchor.constraint(equalToConstant: inputBarHeight),

            // 입력바 내부 상·하 제약을 명확히 (세로로 늘어나지 않게!)
            textField.topAnchor.constraint(equalTo: inputBar.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: inputBar.bottomAnchor, constant: -8),
            textField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 12),

            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.leadingAnchor.constraint(equalTo: textField.trailingAnchor, constant: 8),
            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),
        ])
    }

    @objc private func didTapFortune() {
        Task { [weak self] in
            guard let self else { return }

            await cheetosRef.newFortune()
            let newRow = cheetosRef.messages.count - 1
            guard newRow >= 0 else { return }
            let indexPath = IndexPath(row: newRow, section: 0)

            await MainActor.run {
                self.applyEmptyStateIfNeeded()
                UIView.performWithoutAnimation {
                    self.tableView.insertRows(at: [indexPath], with: .none)
                    self.tableView.layoutIfNeeded()
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    DispatchQueue.main.async {
                        self.scrollToBottom(animated: false)
                    }
                }
            }

            // Fetch가 필요한 Fortune은 내용 도착 후 해당 행만 즉시 리로드 (애니메이션 없음)
            if let last = cheetosRef.messages.last as? Fortune.ID, let f = last.ref, f.isLoading {
                await f.fetch()
                await MainActor.run {
                    if newRow < self.cheetosRef.messages.count {
                        UIView.performWithoutAnimation {
                            self.tableView.reloadRows(at: [IndexPath(row: newRow, section: 0)], with: .none)
                        }
                    }
                }
            }
        }
    }

    @objc private func didTapSend() {
        let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }

        // 1) 즉시 텍스트필드 비우고 키보드 포커스 유지/해제는 취향에 따라
        textField.text = ""

        Task { [weak self] in
            guard let self else { return }

            // 2) 모델 갱신
            cheetosRef.textInput = text
            await cheetosRef.createMyMessage()

            // 3) 데이터 소스가 이미 갱신되었으므로 바로 UI 갱신 (애니메이션 지연 제거)
            let newRow = cheetosRef.messages.count - 1
            guard newRow >= 0 else { return }
            let indexPath = IndexPath(row: newRow, section: 0)

            await MainActor.run {
                self.applyEmptyStateIfNeeded()

                // 지연의 주범이 되는 performBatchUpdates/completion 제거
                UIView.performWithoutAnimation {
                    self.tableView.insertRows(at: [indexPath], with: .none)
                    self.tableView.layoutIfNeeded()
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    DispatchQueue.main.async {
                        self.scrollToBottom(animated: false)
                    }
                }
            }
        }
    }

    

    private func scrollToBottom(animated: Bool) {
        let rows = cheetosRef.messages.count
        guard rows > 0 else { return }
        let idx = IndexPath(row: rows - 1, section: 0)
        tableView.scrollToRow(at: idx, at: .bottom, animated: animated)
    }

    // Keyboard
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ note: Notification) {
        guard
            let ui = note.userInfo,
            let frame = ui[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = ui[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveRaw = ui[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        let kb = max(0, frame.height - view.safeAreaInsets.bottom)
        inputBottomConstraint.constant = -8 - kb

        // 테이블 인셋 업데이트
        self.updateBottomInsets(extraKeyboard: kb)

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curveRaw << 16)) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
            DispatchQueue.main.async {
                self.scrollToBottom(animated: false)
            }
        }
    }

    @objc private func keyboardWillHide(_ note: Notification) {
        guard
            let ui = note.userInfo,
            let duration = ui[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
            let curveRaw = ui[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt
        else { return }

        inputBottomConstraint.constant = -8
        self.updateBottomInsets(extraKeyboard: 0)

        UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: curveRaw << 16)) {
            self.view.layoutIfNeeded()
            self.scrollToBottom(animated: false)
        }
    }
}


// TableView 구성
extension CheetosController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { cheetosRef.messages.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let idAny = cheetosRef.messages[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: MessageHostingCell.reuseID, for: indexPath) as! MessageHostingCell
        cell.selectionStyle = .none
        cell.unembedIfNeeded()

        if let fID = idAny as? Fortune.ID, let f = fID.ref {
            let vc = FortuneController()
            vc.configure(fortune: f)
            cell.embed(vc, into: self)
        } else if let mID = idAny as? MyMessage.ID, let m = mID.ref {
            let vc = MyMessageController()
            vc.configure(message: m)
            cell.embed(vc, into: self)
        } else {
            let vc = PlaceholderMessageController(text: "메시지를 표시할 수 없습니다.")
            cell.embed(vc, into: self)
        }
        return cell
    }
}


// TextInput 구성
extension CheetosController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}



final class PlaceholderMessageController: UIViewController {
    private let label = UILabel()
    init(text: String) {
        super.init(nibName: nil, bundle: nil)
        label.text = text
    }
    required init?(coder: NSCoder) { fatalError() }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
        ])
    }
}

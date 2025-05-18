//
//  TrackerCell.swift
//  Tracker
//
//  Created by Захар Панченко on 30.04.2025.
//

import UIKit

class TrackerCell: UICollectionViewCell {
    static let identifier = "TrackerCell"
    
    private let emojiLabel = UILabel()
    private let titleLabel = UILabel()
    private let daysCountLabel = UILabel()
    private let plusButton = UIButton()
    private let colorView = UIView()
    
    private var trackerId: UUID?
    private var isCompleted = false
    private var canBeCompleted = true
    private var completionHandler: ((UUID, Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        colorView.layer.cornerRadius = 12
        colorView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(colorView)
        
        emojiLabel.font = .systemFont(ofSize: 14)
        emojiLabel.textAlignment = .center
        emojiLabel.backgroundColor = .white.withAlphaComponent(0.3)
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.clipsToBounds = true
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.addSubview(emojiLabel)
        
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        colorView.addSubview(titleLabel)
        
        daysCountLabel.font = .systemFont(ofSize: 12, weight: .medium)
        daysCountLabel.textColor = .black
        daysCountLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(daysCountLabel)
        
        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
        plusButton.tintColor = .white
        plusButton.backgroundColor = colorView.backgroundColor
        plusButton.layer.cornerRadius = 17
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(plusButton)
        
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: colorView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: colorView.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: colorView.bottomAnchor, constant: -12),
            
            daysCountLabel.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            
            plusButton.topAnchor.constraint(equalTo: colorView.bottomAnchor, constant: 8),
            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            plusButton.widthAnchor.constraint(equalToConstant: 34),
            plusButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }
    
    func configure(
        with tracker: Tracker,
        completedDays: Int,
        isCompleted: Bool,
        canBeCompleted: Bool,
        completion: @escaping (UUID, Bool) -> Void
    ) {
        trackerId = tracker.id
        completionHandler = completion
        self.isCompleted = isCompleted
        
        emojiLabel.text = tracker.emoji
        titleLabel.text = tracker.title
        colorView.backgroundColor = tracker.color
        plusButton.backgroundColor = tracker.color
        
        daysCountLabel.text = "\(completedDays) \(dayString(for: completedDays))"
        
        let image = isCompleted ? UIImage(systemName: "checkmark") : UIImage(systemName: "plus")
        plusButton.setImage(image, for: .normal)
        plusButton.alpha = isCompleted ? 0.5 : 1
    }
    
    private func dayString(for count: Int) -> String {
        let remainder = count % 10
        switch remainder {
        case 1 where count != 11:
            return "день"
        case 2...4 where !(12...14 ~= count):
            return "дня"
        default:
            return "дней"
        }
    }
    
    private func updateButtonAppearance() {
        if isCompleted {
             plusButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
             plusButton.alpha = 0.5
         } else {
             plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
             plusButton.alpha = canBeCompleted ? 1.0 : 0.3
         }
         plusButton.isEnabled = canBeCompleted
     }
    
    func updateDaysCount(_ count: Int) {
        daysCountLabel.text = "\(count) \(dayString(for: count))"
    }
    
    func updateCompletionStatus(isCompleted: Bool, canBeCompleted: Bool) {
        self.isCompleted = isCompleted
        self.canBeCompleted = canBeCompleted
        updateButtonAppearance()
    }
    
    @objc private func plusButtonTapped() {
        guard let trackerId = trackerId else { return }
        isCompleted.toggle()
        updateButtonAppearance()
        completionHandler?(trackerId, isCompleted)
    }
}

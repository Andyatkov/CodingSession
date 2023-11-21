//
//  PhotoCollectionViewCell.swift
//  CodingSession
//
//  Created by ADyatkov on 21.11.2023.
//

import UIKit

final class PhotoCollectionViewCell: UICollectionViewCell {

    // MARK: - Subviews
    private lazy var thumbImageView: UIImageView = {
        let thumbImageView = UIImageView()
        thumbImageView.contentMode = .scaleAspectFill
        thumbImageView.clipsToBounds = true
        return thumbImageView
    }()
    private let durationLabel = UILabel()

    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubviews()
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MAKR: - Private Methods
    private func layout() {
        thumbImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        durationLabel.snp.makeConstraints { make in
            make.leading.equalTo(Constants.DurationLabel.leftOffset)
            make.bottom.equalTo(Constants.DurationLabel.bottomOffset)
        }
    }

    private func addSubviews() {
        [thumbImageView, durationLabel].forEach({
            contentView.addSubview($0)
        })
    }

    // MARK: - Public Methods
    func configure(viewModel: PhotoCollectionViewModel) {
        durationLabel.text = viewModel.title
        thumbImageView.image = viewModel.image
    }

}

// MARK: - Constants
private enum Constants {
    enum DurationLabel {
        static let leftOffset: CGFloat = 8
        static let bottomOffset: CGFloat = -8
    }
}

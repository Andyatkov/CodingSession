//
//  ViewController.swift
//  CodingSession
//
//  Created by Pavel Ilin on 01.11.2023.
//

// Это вопрос код стайлу, но лично мне нравиться вверху держать внешние либы, а затем эпловские
import Combine
import SnapKit
import Accelerate
import UIKit

final class PhotosViewController: UIViewController {

    // MARK: - Subviews
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = Constants.minimumLineSpacing
        layout.minimumInteritemSpacing = Constants.minimumInteritemSpacing
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.delegate = self
        return collectionView
    }()
    private lazy var loaderView: UIActivityIndicatorView = {
        let loaderView = UIActivityIndicatorView()
        loaderView.startAnimating()
        loaderView.hidesWhenStopped = true
        return loaderView
    }()
    private lazy var errorLabel: UILabel = {
        let errorLabel = UILabel()
        errorLabel.font = .boldSystemFont(ofSize: Constants.fontSize)
        errorLabel.textColor = .red
        errorLabel.isHidden = true
        return errorLabel
    }()

    // MARK: - Private Properties
    private lazy var dataSource: PhotosDataSource = {
        let dataSource = PhotosDataSource(collectionView: collectionView)
        return dataSource
    }()
    private var viewModel: PhotosViewModel
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init/Deinit
    init(viewModel: PhotosViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        binding()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        addSubviews()
        layout()
        viewModel.viewDidLoad()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection != nil else { return }
        collectionView.collectionViewLayout.invalidateLayout()
    }

    // MARK - Private Methods
    private func addSubviews() {
        [collectionView, loaderView, errorLabel].forEach({
            view.addSubview($0)
        })
    }

    private func layout() {
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        loaderView.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }

        errorLabel.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
        }
    }

    private func binding() {
        viewModel.$snapshot
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] snapshot in
                guard let self else {
                    return
                }
                self.loaderView.stopAnimating()
                self.errorLabel.isHidden = true
                self.dataSource.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)

        viewModel.$outputEvent
            .dropFirst()
            .filter({ $0 != nil })
            .receive(on: DispatchQueue.main)
            .sink { [weak self] event in
                guard let self else {
                    return
                }
                self.loaderView.stopAnimating()
                switch event {
                case .photoAccess:
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = Constants.Error.noAccess
                case .fetchVideoError:
                    self.errorLabel.isHidden = false
                    self.errorLabel.text = Constants.Error.fetchVideos
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
    }

}

extension PhotosViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }

}

// MARK: - Constants
private enum Constants {
    static let minimumLineSpacing: CGFloat = .zero
    static let minimumInteritemSpacing: CGFloat = .zero
    static let fontSize: CGFloat = 21
    static let cellIdentifier: String = "PhotoCollectionViewCell"
    enum Error {
        static let noAccess =  "No access photo library"
        static let fetchVideos = "Error fetch videos"
    }
}

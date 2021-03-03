import ReactiveSwift
import SnapKit
import UIKit

class GiphyDisplayViewController: BaseViewController<GiphyDataViewModel> {
    
    private let searchBar = UISearchBar()
    private let promptLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets.zero
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
    }()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initAndConstrainViews()
        self.bindTargets()
        
        self.collectionView.delegate = self
        self.collectionView.prefetchDataSource = self
        self.collectionView.dataSource = self
        self.collectionView.register(GiphyCollectionViewCell.self, forCellWithReuseIdentifier: GiphyCollectionViewCell.reuseId)
        
        self.collectionView.backgroundColor = .systemBackground
        self.view.backgroundColor = .systemBackground
        self.promptLabel.backgroundColor = .systemBackground
        
        self.searchBar.returnKeyType = .done
        self.promptLabel.text = Constants.Ui.promptText
        self.promptLabel.textAlignment = .center
        self.promptLabel.numberOfLines = 0
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing)))
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    //MARK: Binding and Views
    /**
     Set up observing of the viewmodel by the views and connect to `searchResult` producer to drive collectionView
     */
    private func bindTargets() {
        // Subscribe to incoming text inorder to map it to the request for seamless searching.
        self.disposable += self.viewModel.searchTerm <~ self.searchBar.reactive.continuousTextValues.merge(with: searchBar.reactive.textValues)
        self.disposable += self.searchBar.reactive.resignFirstResponder <~ self.searchBar.reactive.searchButtonClicked
        self.disposable += self.promptLabel.reactive.isHidden <~ self.viewModel.isNotEmpty
        self.disposable += self.viewModel.searchResult
            .take(duringLifetimeOf: self)
            .observe(on: UIScheduler())
            .observeResult { [weak self] result in
                switch result {
                case let .success(innerResult):
                    switch innerResult {
                    case .value:
                        self?.collectionView.reloadData()
                        self?.collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
                    default:
                        break
                    }
                }
            }
        self.disposable += viewModel.errorSignal.observe { [weak self] _ in
            self?.presentDefaultErrorAlert()
        }
    }
    
    /**
     Add the subviews into the view hierarchy and pinning inside of the parent view
     */
    private func initAndConstrainViews() {
        view.addSubview(self.searchBar)
        view.addSubview(self.collectionView)
        view.addSubview(self.promptLabel)
        
        self.searchBar.snp.remakeConstraints { [weak self] makeSearchBar in
            guard let self = self else { return }
            makeSearchBar.top.left.right.equalTo(self.view.safeAreaLayoutGuide)
            makeSearchBar.height.equalTo(Constants.Ui.searchBarHeight)
            
        }
        
        self.collectionView.snp.remakeConstraints { [weak self] makeCollectionView in
            guard let self = self else { return }
            makeCollectionView.bottom.left.right.equalTo(self.view.safeAreaLayoutGuide)
            makeCollectionView.top.equalTo(self.searchBar.snp.bottom)
        }
        
        self.promptLabel.snp.remakeConstraints { [weak self] makePrompt in
            guard let self = self else { return }
            makePrompt.centerX.equalTo(self.collectionView)
            makePrompt.centerY.equalTo(self.collectionView).dividedBy(2)
        }
    }
    
    @objc func endEditing() {
        view.endEditing(false)
    }
}

//MARK: UICollectionViewDataSource Methods

extension GiphyDisplayViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.gifCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GiphyCollectionViewCell.reuseId, for: indexPath) as! GiphyCollectionViewCell
        cell.viewModel = self.viewModel.cellViewModel(for: indexPath.row)
        return cell
    }
}

//MARK: UICollectionViewDataSourcePrefetching Methods

extension GiphyDisplayViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.map { $0.row }.forEach { _ = self.viewModel.cellViewModel(for: $0) }
        
        ///Checking to see if we are approaching the end of our current data.
        if indexPaths.contains(where: { $0.row + 1 == self.viewModel.gifCount}) {
            self.disposable += self.viewModel.nextPage()
                .start(on: QueueScheduler(qos: .background))
                .observe(on: UIScheduler())
                .startWithCompleted {
                    self.collectionView.reloadData()
                }
                        
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        indexPaths.map { $0.row }.forEach { self.viewModel.cellViewModel(for: $0).disposable.dispose() }
    }
}

//MARK: UICollectionViewDelegateFlowLayout Methods

extension GiphyDisplayViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        /// Taking the width of the `collectionView`, then using it to determine the size of the cell. In landscape divide by 2 to create two columns of cells, skip this in protrait to keep 1 column.
        let padding: CGFloat = Constants.Ui.cellMargin
        let width = self.collectionView.bounds.width
        let collectionViewSize = width - padding
        
        switch (UIDevice.current.orientation) {
        case .landscapeLeft, .landscapeRight:
            return CGSize(width: collectionViewSize/2, height: collectionViewSize/2)
        default:
            return CGSize(width: collectionViewSize, height: collectionViewSize)
        }
    }
}

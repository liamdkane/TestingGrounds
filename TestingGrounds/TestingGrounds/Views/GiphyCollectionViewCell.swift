import ReactiveSwift
import SnapKit
import UIKit
import WebKit
import YYImage

class GiphyCollectionViewCell: BaseCollectionViewCell<GiphyCellViewModel> {
    
    let gifView = YYAnimatedImageView()
    let activityIndicator = UIActivityIndicatorView()
    
    override var viewModel: GiphyCellViewModel? {
        didSet {
            guard let viewModel = self.viewModel else { return }
            self.disposables += self.gifView.reactive.image <~ viewModel.image
            self.disposables += self.activityIndicator.reactive.isAnimating <~ viewModel.isLoading
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initAndConstrainViews()
    }
    
    /**
     Add the subviews into the view hierarchy and pinning inside of the parent view
     */
    func initAndConstrainViews() {
        self.contentView.addSubview(self.gifView)
        self.contentView.addSubview(self.activityIndicator)
        
        self.gifView.snp.remakeConstraints { makeGifView in
            makeGifView.top.bottom.left.right.equalToSuperview()
        }
        
        self.activityIndicator.snp.remakeConstraints { makeActivityIndicator in
            makeActivityIndicator.centerX.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.gifView.image = nil
    }
}

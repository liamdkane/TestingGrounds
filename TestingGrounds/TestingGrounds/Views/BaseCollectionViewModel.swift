import ReactiveSwift
import UIKit


/*
 
 Just some boiler code I've gotten accostumed to having when working to help ensure the proper clean up of disposables, view model, whatever else needs to be going into all of the cells. Though i recognise there is only one for this challenge :).
 
 */


open class BaseCollectionViewCell<T: BaseViewModel>: UICollectionViewCell {
    
    static var reuseId: String {
        String(describing: self)
    }
    
    var viewModel: T?
    
    var disposables = CompositeDisposable()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        self.disposables.dispose()
        self.disposables = CompositeDisposable()
        self.viewModel = nil
    }
}

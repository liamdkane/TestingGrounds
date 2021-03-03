import ReactiveSwift
import UIKit


/*
 
 Just some boiler code I've gotten accostumed to having when working to help ensure the proper clean up of disposables, initialisers with a view model, whatever else needs to be going into all of the view controllers. Though i recognise there is only one for this challenge :).
 
 */

open class BaseViewController<T: BaseViewModel>: UIViewController {
    var viewModel: T!
    var disposable: CompositeDisposable = CompositeDisposable()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    public init(withViewModel viewModel: T) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    private func commonInit() {
        self.viewModel = T()
    }
    
    deinit {
        self.disposable.dispose()
    }
    
    func presentDefaultErrorAlert() {
        let alert = UIAlertController(title: Constants.Ui.errorTitle,
                                      message: Constants.Ui.errorMessage,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Constants.Ui.actionTitle, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

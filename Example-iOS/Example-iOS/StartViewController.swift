//
//  Copyright © 2020 Contentful. All rights reserved.
//

import UIKit

final class StartViewController: UIViewController {

    @IBAction private func presentModally() {
        let viewController = ViewController()
        self.present(viewController, animated: true, completion: nil)
    }

    @IBAction private func presentInNavigationController() {
        let viewController = ViewController()
        viewController.title = "Betonowy Dom."
        let navigationController = UINavigationController(rootViewController: viewController)
        self.present(navigationController, animated: true, completion: nil)
    }
}

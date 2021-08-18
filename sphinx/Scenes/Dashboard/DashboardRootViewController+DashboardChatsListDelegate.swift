import UIKit



extension DashboardRootViewController: DashboardChatsListDelegate {
    
    func viewController(
        _ viewController: UIViewController,
        didSelectChat chat: Chat
    ) {
        loadContactsAndSyncMessages()
        presentChatDetailsVC(for: chat)
        updateCurrentViewControllerData(shouldForceReload: true)
    }
    
    
    func viewControllerDidRefreshChats(
        _ viewController: UIViewController,
        using refreshControl: UIRefreshControl
    ) {
        loadContactsAndSyncMessages()
        refreshControl.endRefreshing()
    }
}
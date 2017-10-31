//
//  FeedViewController.swift
//  More2Life
//
//  Created by Porter Hoskins on 7/29/17.
//  Copyright © 2017 More2Life. All rights reserved.
//

import UIKit
import Shared
import CoreData
import Alamofire
import MapKit
import AVFoundation
import AVKit
import Pay
import Storefront
import SafariServices

protocol FeedDetailing {
    var feedItem: FeedItem? { get set }
}

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView?
    
    var observer: NSObjectProtocol?
	
	var halfModalTransitioningDelegate: HalfModalTransitioningDelegate?
    
    var _fetchedResultsController: NSFetchedResultsController<FeedItem>?
    var fetchedResultsController: NSFetchedResultsController<FeedItem> {
        get {
            if let fetchedResultsController = _fetchedResultsController {
                return fetchedResultsController
            }
            
            let fetchRequest: NSFetchRequest<FeedItem> = FeedItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == true", #keyPath(FeedItem.isActive))
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FeedItem.createdAt), ascending: false)]
            
            let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: Shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
            
            do {
                try fetchedResultsController.performFetch()
            } catch {
                print("Error fetching feed items on feed \(error)")
            }
            
            _fetchedResultsController = fetchedResultsController
            return fetchedResultsController
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView?.estimatedRowHeight = 473
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        refresh(sender: nil)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControlEvents.valueChanged)
        tableView?.refreshControl = refreshControl
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        observer = NotificationCenter.default.addObserver(forName: .productsImported, object: nil, queue: OperationQueue.main) { [weak self] _ in
            self?.tableView?.reloadData()
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc func refresh(sender: UIRefreshControl?) {
        let group = DispatchGroup()
        
        group.enter()
        FeedItem.import(in: Shared.viewContext) { _ in
            group.leave()
        }
        
        group.enter()
        Client.shared.importProducts() {
            group.leave()
        }
        
        group.notify(queue: .main) { [weak self] in
            sender?.endRefreshing()
            self?.tableView?.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender else { return }
        
        switch segue.destination {
        case let viewController as AVPlayerViewController:
            guard let item = sender as? StoryFeedItem, let url = URL(string: item.videoURL ?? "") else { break }
            let player = AVPlayer(url: url)
            player.play()
            viewController.player = player
        default:
            switch sender {
            case let sender as FeedItem:
                var feedDetailViewController = segue.destination as? FeedDetailing
                feedDetailViewController?.feedItem = sender
            default:
                break
            }
        }
    }
    
	@IBAction func buyTapped(_ sender: Any) {
        guard let feedItem = sender as? FeedItem else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let buyModalViewController: BuyModalViewController = storyboard.instantiateViewController()        
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: buyModalViewController)
        
        buyModalViewController.modalPresentationStyle = .custom
        buyModalViewController.transitioningDelegate = self.halfModalTransitioningDelegate
        buyModalViewController.mode = .action(feedItem: feedItem)
        
        present(buyModalViewController, animated: true, completion: nil)
	}
    
    @IBAction func giveTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let buyModalViewController: BuyModalViewController = storyboard.instantiateViewController()
        self.halfModalTransitioningDelegate = HalfModalTransitioningDelegate(viewController: self, presentingViewController: buyModalViewController)
        
        buyModalViewController.modalPresentationStyle = .custom
        buyModalViewController.transitioningDelegate = self.halfModalTransitioningDelegate
        buyModalViewController.mode = .donate
        
        present(buyModalViewController, animated: true, completion: nil)
    }
}

extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feedItem = fetchedResultsController.object(at: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: feedItem.type.reuseIdentifier, for: indexPath) as! FeedItemTableViewCell
        
        cell.titleLabel?.text = feedItem.title
        cell.typeLabel?.text = feedItem.type.localizedDescription.uppercased()
		cell.typeLabel?.textColor = feedItem.type.titleColor
        cell.typeColorView?.backgroundColor = feedItem.type.backgroundColor
        cell.priceButton?.borderColor = feedItem.buttonOverlayColor
        
        // Preview Image
        if let imageURL = feedItem.previewImageURL {
            cell.request = FeedItem.previewImage(with: imageURL, for: feedItem, in: Shared.backgroundContext) { [weak cell] image, request in
                guard request?.url?.absoluteString == cell?.request?.request?.url?.absoluteString else { return }
                
                if Thread.isMainThread {
                    cell?.previewImageView?.image = image
                } else {
                    DispatchQueue.main.async {
                        cell?.previewImageView?.image = image
                    }
                }
            }
        }
        
        // Video Button
        if let feedItem = feedItem as? StoryFeedItem, feedItem.videoURL != nil {
            cell.playButton?.isHidden = false
            cell.playVideo = { [weak self] in
                self?.performSegue(withIdentifier: "playVideo", sender: feedItem)
            }
        }
        
        // Price Button
        if let feedItem = feedItem as? ListingFeedItem, let price = feedItem.price {
            cell.priceButton?.isHidden = false
            cell.priceButton?.setTitle(price, for: .normal)
            cell.buy = { [weak self] in
                self?.buyTapped(feedItem)
            }
        }
		
		// Donate Button
		if let feedItem = feedItem as? DonationFeedItem {
			cell.priceButton?.isHidden = false
			cell.priceButton?.setTitle(feedItem.type.localizedCallToActionTitle, for: .normal)
			cell.buy = { [weak self] in
				self?.buyTapped(feedItem)
			}
		}
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detail", sender: fetchedResultsController.object(at: indexPath))
    }
}

extension FeedViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.reloadData()
    }
}

class FeedItemTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var typeLabel: UILabel?
    @IBOutlet weak var previewImageView: UIImageView?
    @IBOutlet weak var typeColorView: UIView?
	@IBOutlet weak var priceButton: PriceButton?
    @IBOutlet weak var playButton: UIButton?
    
    var playVideo: () -> () = {  }
    var buy: () -> () = {  }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        priceButton?.isHidden = true
        playButton?.isHidden = true
    }
    
    var request: DataRequest? {
        didSet {
            oldValue?.cancel()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        if previewImageView?.isHidden == true {
            previewImageView?.isHidden = false
        }
        
        previewImageView?.image = nil
        
        priceButton?.isHidden = true
    
        playButton?.isHidden = true
        playVideo = {  }
        
        request = nil
    }
    
    @IBAction func playTapped(_ sender: Any) {
        playVideo()
    }
    
    @IBAction func buyTapped(_ sender: Any) {
        buy()
    }
}

extension FeedItemType {
    var backgroundColor: UIColor {
        switch self {
        case .story:
            return Color.lightPurple.uiColor
        case .listing:
            return Color.lightGreen.uiColor
        case .event:
            return Color.lightRed.uiColor
		case .donation:
			return Color.lightGreen.uiColor
        case .unknown:
            return .gray
        }
    }
	
	var titleColor: UIColor {
		switch self {
		case .story:
			return Color.darkPurple.uiColor
		case .listing:
			return Color.darkGreen.uiColor
		case .event:
			return Color.darkRed.uiColor
		case .donation:
			return Color.darkGreen.uiColor
		case .unknown:
			return .gray
		}
	}
    
    var reuseIdentifier: String {
        return String(describing: FeedItemTableViewCell.self)
    }
}

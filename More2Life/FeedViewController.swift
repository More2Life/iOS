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

let imageCache = NSCache<NSString, UIImage>()
let priceFormatter: NumberFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    return numberFormatter
}()

protocol FeedDetailing {
    var feedItem: FeedItem? { get set }
}

class FeedViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView?
    
    
    
    var _fetchedResultsController: NSFetchedResultsController<FeedItem>?
    var fetchedResultsController: NSFetchedResultsController<FeedItem> {
        get {
            if let fetchedResultsController = _fetchedResultsController {
                return fetchedResultsController
            }
            
            let fetchRequest: NSFetchRequest<FeedItem> = FeedItem.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "%K == true", #keyPath(FeedItem.isActive))
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(FeedItem.index), ascending: false)]
            
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
    }
    
    func refresh(sender: UIRefreshControl?) {
        FeedItem.import(in: Shared.viewContext) { _ in
            sender?.endRefreshing()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let sender = sender else { return }
        
        switch segue.destination {
        case let viewController as AVPlayerViewController:
            guard let item = sender as? VideoFeedItem, let url = URL(string: item.videoURL ?? "") else { break }
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
        cell.typeColorView?.backgroundColor = feedItem.type.color
        
        switch feedItem {
        case let feedItem as ImagePreviewable:
            guard let imageURL = feedItem.previewImageURL else { break }
            
            if let image = imageCache.object(forKey: imageURL as NSString) {
                cell.previewImageView?.image = image
            } else {
                cell.request = Alamofire.request(imageURL).validate(contentType: ["image/*"]).response { response in
                    guard response.error == nil, let data = response.data, let image = UIImage(data: data) else {
                        /*
                         If the cell went off-screen before the image was downloaded, we cancel it and
                         an NSURLErrorDomain (-999: cancelled) is returned. This is a normal behavior.
                         */
                        if let error = response.error {
                            print("Error fetching image in feed cell \(error) for \(imageURL)")
                        }
                        return
                    }
                    
                    imageCache.setObject(image, forKey: imageURL as NSString)
                    
                    if response.request?.url?.absoluteString == cell.request?.request?.url?.absoluteString {
                        DispatchQueue.main.async {
                            cell.previewImageView?.image = image
                        }
                    }
                }
            }
            
            if feedItem is VideoFeedItem {
                cell.playButton?.isHidden = false
                cell.playVideo = { [weak self] in
                    self?.performSegue(withIdentifier: "playVideo", sender: feedItem)
                }
                
                cell.previewImageViewRatioConstraint?.isActive = false
                cell.videoPreviewImageViewRatioConstraint?.isActive = true
            } else {
                cell.videoPreviewImageViewRatioConstraint?.isActive = false
                cell.previewImageViewRatioConstraint?.isActive = true
            }
        default:
            cell.previewImageView?.isHidden = true
        }
        
        if let feedItem = feedItem as? ListingFeedItem {
            cell.priceView?.isHidden = false
            cell.priceLabel?.text = priceFormatter.string(from: NSNumber(value: feedItem.product?.price ?? 0))
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let feedItem = fetchedResultsController.object(at: indexPath)
        
        switch feedItem.type {
//        case .video:
//            performSegue(withIdentifier: "video", sender: feedItem)
        default:
            break
        }
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
    @IBOutlet weak var priceView: UIView?
    @IBOutlet weak var priceLabel: UILabel?
    @IBOutlet weak var playButton: UIButton?
    @IBOutlet var previewImageViewRatioConstraint: NSLayoutConstraint?
    @IBOutlet var videoPreviewImageViewRatioConstraint: NSLayoutConstraint?
    
    var playVideo: () -> () = { _ in }
    
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
        
        priceView?.isHidden = true
    
        playButton?.isHidden = true
        playVideo = { _ in }
        
        request = nil
    }
    
    @IBAction func playTapped(_ sender: Any) {
        playVideo()
    }
}

extension FeedItemType {
    var color: UIColor {
        switch self {
        case .video:
            return Color.purple.uiColor
        case .listing:
            return Color.red.uiColor
        case .event:
            return Color.yellow.uiColor
        case .unknown:
            return .gray
        }
    }
    
    var reuseIdentifier: String {
        return String(describing: FeedItemTableViewCell.self)
    }
}

protocol ImagePreviewable {
    var previewImageURL: String? { get }
}

extension VideoFeedItem: ImagePreviewable { }
extension ListingFeedItem: ImagePreviewable { }
extension EventFeedItem: ImagePreviewable { }

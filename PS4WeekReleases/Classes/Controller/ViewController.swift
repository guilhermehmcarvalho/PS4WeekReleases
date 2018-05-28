//
//  ViewController.swift
//  PS4WeekReleases
//
//  Created by Guilherme Carvalho on 20/05/2018.
//  Copyright © 2018 gcarvalho. All rights reserved.
//

import UIKit
import VegaScrollFlowLayout
import NVActivityIndicatorView

// MARK: - Configurable constants
private let itemHeight: CGFloat = 304
private let lineSpacing: CGFloat = 20
private let xInset: CGFloat = 20
private let topInset: CGFloat = 10

class ViewController: UIViewController {
	
	fileprivate let cellId = "ReleaseDateCell"
	let releaseDateService = ReleaseDateService()
	@IBOutlet weak var collectionView: UICollectionView!
	fileprivate var releases: [ReleaseDate] = []
	@IBOutlet weak var activityIndicator: NVActivityIndicatorView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		let nib = UINib(nibName: cellId, bundle: nil)
		collectionView.register( nib, forCellWithReuseIdentifier: cellId)
		collectionView.contentInset.bottom = itemHeight
		configureCollectionViewLayout()
		//setUpNavBar()
		
		releaseDateService.delegate = self
		activityIndicator.type = .pacman
		activityIndicator.color = UIColor.App.yellow
		activityIndicator.startAnimating()
		releaseDateService.getPlaystationWeek()
    }

	private func setUpNavBar() {
		navigationItem.title = "New This Week"
		navigationController?.view.backgroundColor = UIColor.black
		if #available(iOS 11.0, *) {
			navigationController?.navigationBar.prefersLargeTitles = true
		}
	}
	
	override func viewWillAppear(_ animated: Bool) {
		setUpNavBar()
	}
	
	private func configureCollectionViewLayout() {
		guard let layout = collectionView.collectionViewLayout as? VegaScrollFlowLayout else { return }
		layout.minimumLineSpacing = lineSpacing
		layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
		let itemWidth = UIScreen.main.bounds.width - 2 * xInset
		layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
		collectionView.collectionViewLayout.invalidateLayout()
	}
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId,
                                                         for: indexPath) as? ReleaseDateCell {
            let release = releases[indexPath.row]
            cell.configureWith(release)

            return cell
        }

        return collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath)
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return releases.count
	}

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let url = releases[indexPath.row].game.getOficialWebsite() else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

extension ViewController: ReleaseDateServiceDelegate {
	func getPlaystationWeekDidComplete(releaseDates: [ReleaseDate]) {
		releases = releaseDates
		activityIndicator.stopAnimating()
		self.collectionView.reloadData()
	}
	
	func getPlaystationWeekDidComplete(failure: ServiceFailureType) {
		print(failure)
		activityIndicator.stopAnimating()
	}
}

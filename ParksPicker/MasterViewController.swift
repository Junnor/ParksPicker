//
//  MasterViewController.swift
//  ParksPicker
/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE. 
 */ 


import UIKit

private let reuseIdentifier = "ParkCell"

class MasterViewController: UICollectionViewController {
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    fileprivate var parksDataSource = ParksDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isToolbarHidden = true
        // edit
        navigationItem.leftBarButtonItem = editButtonItem
        
        let width = collectionView!.frame.width / 3
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: width, height: width)
        
        // Sticky Headers
        layout.sectionHeadersPinToVisibleBounds = true
        
        // Refresh Control
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(MasterViewController.refreshControlDidFire), for: .valueChanged)
        collectionView?.refreshControl = refreshControl
    }
    
    // editing
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        addButton.isEnabled = !editing
        collectionView?.allowsMultipleSelection = editing
        
        let indexPaths = collectionView!.indexPathsForVisibleItems
        
        for indexPath in indexPaths {
            collectionView?.deselectItem(at: indexPath, animated: true)
            let cell = collectionView!.cellForItem(at: indexPath) as? ParkCell
            cell?.editing = editing
        }
        
        if !editing {
            navigationController?.setToolbarHidden(true, animated: animated)
        }
    }
    
    func refreshControlDidFire() {
        addButtonTapped(nil)
        collectionView?.refreshControl?.endRefreshing()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MasterToDetail" {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.park = sender as? Park
        }
    }
    
    // delete
    @IBAction func deleteButtonTapped(_ sender: UIBarButtonItem) {
        // delete with normal effect
        //        let indexPaths = collectionView!.indexPathsForSelectedItems!
        //        parksDataSource.deleteItemsAtIndexPaths(indexPaths)
        //        collectionView?.deleteItems(at: indexPaths)
        
        // delete with custom layout effect
        let indexPaths = collectionView!.indexPathsForSelectedItems!
        let layout = collectionViewLayout as! ParksViewFlowLayout
        layout.disapparingIndexPaths = indexPaths
        
        parksDataSource.deleteItemsAtIndexPaths(indexPaths)
        
        UIView.animate(withDuration: 0.65,
                       delay: 0.0,
                       options: UIViewAnimationOptions(),
                       animations: {
                        self.collectionView!.deleteItems(at: indexPaths)
        }) { (_) in
            layout.disapparingIndexPaths = nil
        }
    }
    
    // add
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem?) {
        let indexPath = parksDataSource.indexPathForNewRandomPark()
        let layout = collectionViewLayout as! ParksViewFlowLayout
        layout.appearingIndexPath = indexPath
        
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.0, options: UIViewAnimationOptions(), animations: { () -> Void in
            
            self.collectionView!.insertItems(at: [indexPath as IndexPath])
            
        }, completion: { (finished: Bool) -> Void in
            layout.appearingIndexPath = nil
        })
        
    }
    
}

// MARK: UICollectionViewDataSource
extension MasterViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return parksDataSource.numberOfSections
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return parksDataSource.numberOfParksInSection(section)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderView
        
        if let title = parksDataSource.titleForSectionAtIndexPath(indexPath) {
            sectionHeaderView.title = title
            sectionHeaderView.icon = UIImage(named: title)
        }
        return sectionHeaderView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ParkCell
        
        if let park = parksDataSource.parkForItemAtIndexPath(indexPath) {
            cell.park = park
            cell.editing = isEditing
        }
        
        return cell
    }
}

// MARK: UICollectionViewDelegate
extension MasterViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if !isEditing {
            if let nationalPark = parksDataSource.parkForItemAtIndexPath(indexPath) {
                performSegue(withIdentifier: "MasterToDetail", sender: nationalPark)
            }
        } else {
            navigationController?.setToolbarHidden(false, animated: true)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if isEditing {
            if collectionView.indexPathsForVisibleItems.count == 0 {
                navigationController?.setToolbarHidden(true, animated: true)
            }
        }
    }
    
}

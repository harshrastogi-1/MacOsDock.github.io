import UIKit

class DockViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    var collectionView: UICollectionView!
    let dockItems = ["1", "2", "3", "4", "5", "6"] // Placeholder dock items

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create Dock Background
        let dockBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        dockBackground.layer.cornerRadius = 20
        dockBackground.layer.masksToBounds = true
        dockBackground.layer.shadowColor = UIColor.black.cgColor
        dockBackground.layer.shadowOpacity = 0.2
        dockBackground.layer.shadowOffset = CGSize(width: 0, height: 2)
        dockBackground.layer.shadowRadius = 5
        dockBackground.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dockBackground)

        // Create Dock Icons (UICollectionView)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 10
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.backgroundColor = .clear
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        dockBackground.contentView.addSubview(collectionView)

        // Layout Constraints
        NSLayoutConstraint.activate([
            dockBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dockBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            dockBackground.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50),
            dockBackground.heightAnchor.constraint(equalToConstant: 80),

            collectionView.leadingAnchor.constraint(equalTo: dockBackground.leadingAnchor, constant: 10),
            collectionView.trailingAnchor.constraint(equalTo: dockBackground.trailingAnchor, constant: -10),
            collectionView.topAnchor.constraint(equalTo: dockBackground.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: dockBackground.bottomAnchor),
        ])
    }

    // MARK: - Collection View Delegate & Data Source

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dockItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        cell.layer.cornerRadius = 10
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.2) {
                cell.transform = CGAffineTransform.identity
            }
        }
    }
}

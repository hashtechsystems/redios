//
//  AuthorizePaymentViewController.swift
//  REDE
//
//  Created by Avishek on 22/08/22.
//

import UIKit
import AnimatedCardInput
import SVProgressHUD
protocol AuthorizePaymentDelegate{
    func creditCardData(data: CreditCardData?)
}

class AuthorizePaymentViewController: BaseViewController {
    
    @IBOutlet weak var viewScanner: UIView!
    var delegate: AuthorizePaymentDelegate?
    var isSaveCard = false
    private let cardView: CardView = {
        let view = CardView(
            cardNumberDigitsLimit: 16,
            cardNumberChunkLengths: [4, 4, 4, 4],
            CVVNumberDigitsLimit: 3
            
        )

        view.frontSideCardColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        view.backSideCardColor = #colorLiteral(red: 0.2156862745, green: 0.2156862745, blue: 0.2156862745, alpha: 1)
        view.selectionIndicatorColor = .orange
        view.frontSideTextColor = .white
        view.CVVBackgroundColor = .white
        view.backSideTextColor = .black
        view.isSecureInput = true

        view.numberInputFont = UIFont.systemFont(ofSize: 24, weight: .semibold)
        view.nameInputFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.validityInputFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        view.CVVInputFont = UIFont.systemFont(ofSize: 20, weight: .semibold)

        return view
    }()

    private let inputsView: CardInputsView = {
        let view = CardInputsView(cardNumberDigitLimit: 16)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isSecureInput = true
        return view
    }()

    private let buttonSave : UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Save Card", for: .normal)
        button.setImage(UIImage(named: "unchecked"), for: .normal)
        button.setImage(UIImage(named: "checkbox"), for: .selected)
        button.setTitleColor(.black, for: .normal)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        return button
    }()
    private let retrieveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("   Done   ", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(retrieveTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navbar.isRightButtonHidden = true
        self.navbar.setOnClickLeftButton {
            self.dismiss(animated: true)
        }

        cardView.creditCardDataDelegate = inputsView
        inputsView.creditCardDataDelegate = cardView

        [
            cardView,
            inputsView,
            buttonSave,
            retrieveButton
            
        ].forEach(viewScanner.addSubview)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: viewScanner.topAnchor, constant: 60),
            cardView.leadingAnchor.constraint(equalTo: viewScanner.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: viewScanner.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            inputsView.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            inputsView.leadingAnchor.constraint(equalTo: viewScanner.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            inputsView.trailingAnchor.constraint(equalTo: viewScanner.safeAreaLayoutGuide.trailingAnchor, constant: -16),

            buttonSave.heightAnchor.constraint(equalToConstant: 44),
            buttonSave.centerXAnchor.constraint(equalTo: viewScanner.centerXAnchor),
            buttonSave.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 24),
            
            retrieveButton.heightAnchor.constraint(equalToConstant: 44),
            retrieveButton.centerXAnchor.constraint(equalTo: viewScanner.centerXAnchor),
            retrieveButton.topAnchor.constraint(equalTo: buttonSave.bottomAnchor, constant: 24),
        ])
        
        inputsView.isHidden = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cardView.currentInput = .cardNumber
    }

    @objc private func saveButtonTapped(_ sender : UIButton){
        sender.isSelected = !sender.isSelected
        isSaveCard = !isSaveCard
    }
    @objc private func retrieveTapped() {
        let data = cardView.creditCardData
        
        if data.cardNumber.isEmpty {
            self.showAlert(title: "RED E", message: "Please enter your card number")
        }
        else if data.validityDate.isEmpty {
            self.showAlert(title: "RED E", message: "Please enter validty date")
        }
        else if data.CVVNumber.isEmpty {
            self.showAlert(title: "RED E", message: "Please enter CVV")
        }
        else{
            if isSaveCard{
                SVProgressHUD.show()
                saveCardDetails()
            }else{
                self.delegate?.creditCardData(data: data)
                self.dismiss(animated: true)
            }
            
        }
    }
    
    func saveCardDetails(){
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
        let data = cardView.creditCardData
        let arr = data.validityDate.components(separatedBy: "/")
        guard arr.count == 2, let month = arr.first, let year = arr.last else{
            return
        }
        NetworkManager().SaveCardDetails(cardNumber: data.cardNumber, year: year, month: month) { response, error in
            if error != nil {
                
            }else{
                DispatchQueue.main.async {
                    self.delegate?.creditCardData(data: data)
                    self.dismiss(animated: true)
                }
                

            }
        }
    }
}

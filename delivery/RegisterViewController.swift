import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {

    // MARK: - UI Components
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Crear Cuenta"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Nombre completo"
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(frame: CGRect(x: 14, y: 15, width: 20, height: 20))
        iconView.image = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .systemGray
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconContainerView.addSubview(iconView)
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
        return textField
    }()

    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Correo electrónico"
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(frame: CGRect(x: 14, y: 15, width: 20, height: 20))
        iconView.image = UIImage(systemName: "envelope.fill")?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .systemGray
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconContainerView.addSubview(iconView)
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
        return textField
    }()

    private let passwordField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Contraseña"
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let iconView = UIImageView(frame: CGRect(x: 14, y: 15, width: 20, height: 20))
        iconView.image = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .systemGray
        let iconContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconContainerView.addSubview(iconView)
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
        return textField
    }()

    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Registrarse", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        button.layer.shadowColor = UIColor.systemBlue.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.color = .white
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        registerButton.addTarget(self, action: #selector(registerUser), for: .touchUpInside)
        registerButton.addSubview(spinner)
        
        view.addSubview(titleLabel)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(registerButton)
        
        setupConstraints()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            nameField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 40),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            nameField.heightAnchor.constraint(equalToConstant: 50),
            
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 16),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            registerButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 32),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            registerButton.heightAnchor.constraint(equalToConstant: 54),
            
            spinner.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor)
        ])
    }

    @objc func registerUser() {
        guard let name = nameField.text, !name.isEmpty,
              let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showError(message: "Por favor, llena todos los campos.")
            return
        }

        registerButton.setTitle("", for: .normal)
        spinner.startAnimating()
        registerButton.isEnabled = false

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.spinner.stopAnimating()
                self.registerButton.setTitle("Registrarse", for: .normal)
                self.registerButton.isEnabled = true
                self.showError(message: error.localizedDescription)
                return
            }
            
            // Save to Firestore
            if let user = authResult?.user {
                let db = Firestore.firestore(database: "delivery")
                db.collection("users").document(user.uid).setData([
                    "nombre": name,
                    "email": email,
                    "uid": user.uid
                ]) { error in
                    self.spinner.stopAnimating()
                    self.registerButton.setTitle("Registrarse", for: .normal)
                    self.registerButton.isEnabled = true
                    
                    if let error = error {
                        self.showError(message: "Error guardando datos: \(error.localizedDescription)")
                    } else {
                        // Mostrar alerta de éxito
                        let alert = UIAlertController(title: "¡Éxito!", message: "Cuenta creada exitosamente.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Aceptar", style: .default, handler: { _ in
                            self.dismiss(animated: true)
                        }))
                        self.present(alert, animated: true)
                    }
                }
            }
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}

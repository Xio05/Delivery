import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController: UIViewController {

    // MARK: - UI Components
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "shippingbox.fill") // Delivery theme
        imageView.tintColor = .systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Bienvenido de nuevo"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ingresa tus datos para continuar"
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emailField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Correo electrónico"
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 12
        textField.keyboardType = .emailAddress
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        // Icon
        let iconView = UIImageView(frame: CGRect(x: 14, y: 15, width: 20, height: 20))
        iconView.image = UIImage(systemName: "envelope.fill")?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .systemGray
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
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
        
        // Icon
        let iconView = UIImageView(frame: CGRect(x: 14, y: 15, width: 20, height: 20))
        iconView.image = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysTemplate)
        iconView.tintColor = .systemGray
        let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        iconContainerView.addSubview(iconView)
        textField.leftView = iconContainerView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Iniciar sesión", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 14
        
        // Shadow for premium look
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
    
    private let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¿No tienes cuenta? Regístrate aquí", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        
        // Dismiss keyboard on tap
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - UI Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        loginButton.addTarget(self, action: #selector(loginUsuario), for: .touchUpInside)
        loginButton.addSubview(spinner) // Add spinner to button for inline loading
        
        registerButton.addTarget(self, action: #selector(goToRegister), for: .touchUpInside)
        
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Logo
            logoImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 80),
            logoImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Subtitle
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            
            // Email Field
            emailField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 40),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            emailField.heightAnchor.constraint(equalToConstant: 50),
            
            // Password Field
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 16),
            passwordField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            passwordField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            passwordField.heightAnchor.constraint(equalToConstant: 50),
            
            // Login Button
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 32),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            loginButton.heightAnchor.constraint(equalToConstant: 54),
            
            // Spinner (centered inside button)
            spinner.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            
            // Register Button
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 16),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func goToRegister() {
        let registerVC = RegisterViewController()
        present(registerVC, animated: true)
    }

    // MARK: - Actions

    @objc func loginUsuario() {
        // animación botón
        UIView.animate(withDuration: 0.1, animations: {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.loginButton.transform = .identity
            }
        }

        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else { return }

        // start loading (hide text, show spinner)
        loginButton.setTitle("", for: .normal)
        spinner.startAnimating()
        loginButton.isEnabled = false

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            
            // detener loading
            self.spinner.stopAnimating()
            self.loginButton.setTitle("Iniciar sesión", for: .normal)
            self.loginButton.isEnabled = true
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.showError(message: "E-mail o contraseña incorrectos.")
                return
            }
            
            print("Login exitoso 🚀")
        }
    }
    
    private func showError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}



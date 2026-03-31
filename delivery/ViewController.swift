import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    let emailField = UITextField()
    let passwordField = UITextField()
    let loginButton = UIButton()
    let spinner = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground

        // EMAIL
        emailField.placeholder = "Correo"
        emailField.borderStyle = .roundedRect
        
        // PASSWORD
        passwordField.placeholder = "Contraseña"
        passwordField.borderStyle = .roundedRect
        passwordField.isSecureTextEntry = true
        
        // BOTÓN
        loginButton.setTitle("Iniciar sesión", for: .normal)
        loginButton.backgroundColor = .systemBlue
        loginButton.layer.cornerRadius = 10
        
        loginButton.addTarget(self, action: #selector(loginUsuario), for: .touchUpInside)

        // POSICIONES (centrado)
        emailField.frame = CGRect(x: 40, y: 300, width: view.frame.width - 80, height: 45)
        passwordField.frame = CGRect(x: 40, y: 360, width: view.frame.width - 80, height: 45)
        loginButton.frame = CGRect(x: 40, y: 430, width: view.frame.width - 80, height: 50)

        // SPINNER (loading)
        spinner.center = view.center

        // AGREGAR A LA VISTA
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(loginButton)
        view.addSubview(spinner)
    }

    // 🔐 LOGIN CON ANIMACIÓN
    @objc func loginUsuario() {
        
        // animación botón
        UIView.animate(withDuration: 0.1, animations: {
            self.loginButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.loginButton.transform = .identity
            }
        }

        guard let email = emailField.text,
              let password = passwordField.text else { return }

        // loading
        spinner.startAnimating()
        loginButton.isEnabled = false

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            // detener loading
            self.spinner.stopAnimating()
            self.loginButton.isEnabled = true
            
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            print("Login exitoso 🚀")
        }
    }
}

# 📱 Tekiyo ID - Récapitulatif Complet du Projet

## 🎯 Vue d'ensemble

**Tekiyo ID** est une application iOS native développée en SwiftUI pour la gestion d'identité décentralisée avec preuve d'humanité via Face ID et blockchain.

### Technologies utilisées
- **SwiftUI** - Framework UI déclaratif
- **Combine** - Programmation réactive
- **CoreMotion** - Détection de mouvement (gyroscope)
- **LocalAuthentication** - Face ID / Touch ID
- **AVFoundation** - Caméra et capture photo
- **Vision** - Détection de visage en temps réel
- **CoreLocation** - Géolocalisation
- **MapKit** - Recherche de lieux
- **CryptoKit** - Hachage SHA256 pour QR codes

---

## 📁 Architecture du Projet

### Structure MVVM
```
Tekiyo ID/
├── Core/
│   ├── Components/        # Composants réutilisables
│   ├── Extensions/        # Extensions Swift
│   ├── Managers/          # Singletons et services
│   └── Typography.swift   # Styles de texte globaux
│
├── Features/
│   ├── Onboarding/        # Écrans de démarrage
│   ├── Authentication/    # Face ID
│   ├── Identity/          # Formulaire et capture photo
│   ├── Messaging/         # Messages et chat
│   ├── Wallet/            # Portefeuille et transactions
│   └── Profile/           # Profil utilisateur
│
└── Assets.xcassets/       # Images et icônes
```

---

## 🚀 Flux d'onboarding

### 1. StartView
- Écran de lancement avec logo Tekiyo
- Bouton "Commencer" pour démarrer

### 2. IntroductionView
- Explication du concept
- Détection du mouvement de l'iPhone (gyroscope)
- L'utilisateur doit incliner l'iPhone pour passer à l'étape suivante
- **Debug**: Boutons skip disponibles en mode DEBUG

### 3. FaceIDSetupView
- Configuration de Face ID
- Demande de permission biométrique
- Animation et feedback haptique
- **Debug**: Boutons pour simuler succès/skip

### 4. IdentitySetupView
- Formulaire d'identité en plusieurs étapes :
  - Nom
  - Prénom
  - Date de naissance (DatePicker)
  - Nationalité (avec suggestions)
  - Métier
  - Ville (avec MapKit pour suggestions temps réel)
- Validation des champs à chaque étape
- Navigation step-by-step

### 5. PhotoCaptureView
- Caméra frontale en live
- Cercle bleu pointillé (253px) pour cadrer le visage
- Détection de visage en temps réel avec Vision framework
- Validation : visage présent, centré, bien éclairé
- Indicateurs visuels : cercle vert si OK, rouge si KO
- Message d'aide en temps réel
- Boutons : "Importer depuis la galerie" et "Continuer"

### 6. FingerprintCreationView
- Animation de l'icône SF Symbol `checkmark.seal.text.page.fill`
- Dégradé bleu (002FFF 100% → 0%)
- Texte fixe : "Création de ton empreinte.."
- Sous-titre : "Ton visage reste sur ton appareil..."
- Navigation automatique après 3-4 secondes

### 7. IdentityCompleteView
- Carte d'identité avec photo
- QR code circulaire (CircularCodeView)
- Tekiyo ID généré (format: 3A1B-7E21)
- Username généré
- Bouton "Afficher mon profil Tekiyo"

---

## 📱 Application principale (Post-onboarding)

### Architecture TabBar (4 onglets)

#### 🏠 Home (house.fill)
- **PlaceholderTabView** "Accueil"
- En attente de développement futur

#### 🆔 Tekiyo ID (square.grid.3x3.fill)
- **ProfileView** - Écran profil principal
- Header : avatar (43x43px) + bouton recherche
- Localisation temps réel : "☀️ Paris"
- Greeting : "Bonjour Marie!"
- QR code circulaire (194x194px, dots 9x9px)
- Trust score : 10 barres (3 rouges actives, 27%)
- Dernière vérification
- Activités récentes (overlay au tap)
- Section Liens : 12 réseaux sociaux en grille

#### 🔔 Notifications (bell.fill)
- **MessageListView** - Messages et notifications
- Segmented control natif (Messages / Notifications)
- Section "Événements" avec badge count (1)
- Liste de conversations :
  - Marie D. (online, unread)
  - Thomas S. (unread)
  - Julie F. (transaction 50€)
  - BNP (verified badge)
- Navigation vers **ChatView** au tap

#### 💰 Wallet (wallet.pass.fill)
- **WalletView** - Portefeuille
- Balance totale : 12,754.84 €
- Boutons actions : Envoyer, Recevoir, Ajouter
- Historique groupé par date :
  - Aujourd'hui
  - Hier
  - Dates spécifiques (Jeudi 18/02)
- Transactions avec montants colorés (+ vert, - blanc)

---

## 💬 Système de Messaging

### MessageListView
- **Segmented Control** : Messages / Notifications (Picker natif)
- **Section Événements** avec badge (1)
- **ConversationRow** pour chaque conversation :
  - Avatar circulaire (56x56px)
  - Online indicator (point vert)
  - Nom + verified badge (si applicable)
  - Preview du dernier message
  - Timestamp
  - Unread dot (bleu)

### ChatView
- **Header** :
  - Bouton retour
  - Avatar contact (40x40px)
  - Nom + statut "En ligne"
- **Messages scrollables** :
  - MessageBubble pour textes
  - TransactionBubble pour paiements TekiyoPay
  - Avatar du contact à gauche (32x32px)
  - Bulles user (droite, bleu) vs contact (gauche, gris)
- **Input field** :
  - Bouton + (plus.circle.fill)
  - TextField natif
  - Bouton send (arrow.up.circle.fill) ou mic (mic.fill)

### TransactionBubble
- Label "TekiyoPay"
- Montant 50€ en grand
- Avatar du sender

---

## 💳 Système Wallet

### WalletView
- **Balance header** :
  - "Total"
  - Montant : 12,754.84 €
  - Bouton expand
- **Action buttons** :
  - Envoyer (arrow.up.right)
  - Recevoir (arrow.down.left)
  - Ajouter (+)
- **Historique** :
  - Groupé par date (Aujourd'hui, Hier, dates)
  - TransactionRow pour chaque transaction :
    - Avatar (44x44px)
    - Nom + heure
    - Montant (+ vert / - blanc)

---

## 🎨 Design System

### Couleurs
- **Background principal** : `Color(hex: "111111")` (OLED black)
- **Texte primaire** : `.primary` (adaptatif dark/light)
- **Texte secondaire** : `.secondary`
- **Accents** :
  - Bleu : `Color.blue` (natif)
  - Vert : `Color.green` (success, crédit)
  - Rouge : Pour trust score actif

### Typographie
- **Font système** : SF Pro Display
- **Styles natifs** :
  - `.headline` - Titres principaux
  - `.title2`, `.title3` - Sections
  - `.subheadline` - Sous-titres
  - `.body` - Corps de texte
  - `.caption` - Métadonnées
- **Custom tracking** : -6% (kerning) pour titres importants

### Composants UI
- **Frosted Glass** : `.ultraThinMaterial`
- **Corner radius** : `.continuous` style pour courbes Apple
- **Segmented Control** : Picker natif avec `.segmented`
- **TabBar** : Icônes seulement (sans texte)
- **Buttons** : `.plain` buttonStyle
- **Colors** : Système adaptatif (`.systemBackground`, `.systemGray6`)

---

## 🔧 Core Components

### LargeCircularCodeView
- QR code circulaire style App Clip
- 194x194px, dots 9x9px
- Génération via SHA256 hash de l'URL
- ~100 dots en spirale
- Dot highlight au centre avec ring blanc
- Animation opacity + scale à l'apparition
- URL : tekiyo.fr

### WalletWidget
- 342x291px, border radius 60px
- Frosted glass background
- Balance + 3 boutons actions
- Typographie SF Pro Display
- Padding 8px global

### CameraPreview
- AVCaptureVideoPreviewLayer
- Intégration SwiftUI via UIViewRepresentable
- Preview temps réel de la caméra

### FaceDetectionOverlay
- Cercle pointillé (253px)
- Couleur dynamique : vert (OK) / rouge (KO) / bleu (défaut)
- Message d'aide en temps réel
- Vision framework pour détection

---

## 🗂️ Modèles de données

### IdentityData
```swift
struct IdentityData: Codable, Equatable {
    let nom: String
    let prenom: String
    let dateNaissance: Date
    let nationalite: String
    let metier: String
    let ville: String
}
```

### Message
```swift
struct Message: Identifiable, Equatable {
    let id: String
    let senderId: String
    let text: String
    let timestamp: Date
    let isFromCurrentUser: Bool
}
```

### Conversation
```swift
struct Conversation: Identifiable, Equatable {
    let id: String
    let user: ConversationUser
    let lastMessage: String
    let timestamp: Date
    let isUnread: Bool
}
```

### Transaction
```swift
struct Transaction: Identifiable, Equatable {
    let id: String
    let user: TransactionUser
    let amount: Double
    let type: TransactionType // credit / debit
    let timestamp: Date
}
```

---

## 🎯 ViewModels

### IntroductionViewModel
- Détection gyroscope (CoreMotion)
- Gestion des étapes d'intro
- Feedback haptique

### FaceIDViewModel
- Gestion LocalAuthentication
- États : idle, authenticating, success, failure
- Permission biométrique

### IdentityViewModel
- Validation formulaire step-by-step
- Gestion des étapes : nom, prénom, date, nationalité, métier, ville
- `isStepComplete()` pour chaque étape

### PhotoCaptureViewModel
- Gestion caméra (CameraManager)
- Validation photo avec Vision
- États : setup, ready, capturing, success, error

### MessageListViewModel
- Segmented control (Messages / Notifications)
- Liste conversations avec données mock
- Badge événements

### ChatViewModel
- Gestion messages
- Envoi de messages
- Support TransactionBubble

### WalletViewModel
- Balance
- Transactions groupées par date
- Actions : send, receive, add

### ProfileViewModel
- Localisation temps réel (LocationManager)
- Permission géolocalisation
- Ville de l'utilisateur

---

## 🔐 Managers & Services

### HapticManager (Singleton)
- `success()`, `error()`, `warning()`
- `impact(style:)` - light, medium, heavy
- `selection()`
- Feedback haptique unifié

### BiometricAuthManager (Singleton)
- `authenticateUser()` async
- Gestion Face ID / Touch ID
- Messages d'erreur localisés

### CameraManager
- Configuration AVCaptureSession
- Photo capture
- Preview layer
- Gestion permissions

### LocationManager
- CLLocationManager
- Demande permission
- Géocodage reverse (coordonnées → ville)
- Publication ville via @Published

### RealtimeFaceDetector
- AVCaptureVideoDataOutput
- VNDetectFaceRectanglesRequest
- Détection temps réel
- Thread-safe avec NSLock

---

## 🛠️ Extensions

### Color+Hex
```swift
init(hex: String)
// Support: RGB (12-bit), RGB (24-bit), ARGB (32-bit)
```

### View+DebugRender
```swift
func debugRenders(_ label: String) -> some View
// Logging des re-renders en DEBUG
```

### AppTypography
```swift
func appTypography(fontSize: CGFloat) -> some View
// Tracking -6%, lineSpacing ajusté
```

---

## 🔄 Navigation Flow

### Onboarding complet
```
StartView
  → IntroductionView (gyroscope)
    → FaceIDSetupView
      → IdentitySetupView (formulaire multi-step)
        → PhotoCaptureView
          → FingerprintCreationView (animation 3-4s)
            → IdentityCompleteView
              → ProfileTabContainerView
```

### Navigation dans l'app
- **TabView** avec 4 onglets
- **MessageListView → ChatView** : NavigationLink
- **ProfileView → ActivitiesOverlay** : Sheet overlay
- **TransactionBubble → WalletView** : Changement de tab (futur)

---

## 📊 États et gestion

### @Published states
- `@Published var isLoading: Bool`
- `@Published var errorMessage: String?`
- `@Published var currentStep: Step`
- `@Published var selectedSegment: Segment`

### @StateObject ViewModels
- ViewModels injectés via `@StateObject`
- Singleton Managers via `.shared`

### Combine pipelines
- Réactivité avec `@Published`
- Observers dans Views via `@StateObject`

---

## 🎨 Optimisations

### Performance
- `.drawingGroup()` pour vues complexes
- LazyVStack/LazyVGrid pour listes
- Éviter re-renders inutiles (@State stable)
- `.animation(.easeOut, value:)` ciblée

### Énergie
- Limitation reactive updates
- Stable `@Binding` et `@State`
- Pas d'animations infinies par défaut
- `.debugRenders()` pour monitoring

---

## 🧪 Mode DEBUG

### Bypass pour développement Mac
- **IntroductionView** : Boutons skip steps / FaceID
- **FaceIDSetupView** : Boutons simuler succès / passer
- Point d'entrée direct sur **ProfileTabContainerView** avec données mock

### Configuration DEBUG
```swift
#if DEBUG
ProfileTabContainerView(
    identityData: IdentityData(
        nom: "Dupont",
        prenom: "Marie",
        dateNaissance: Date(),
        nationalite: "Française",
        metier: "Directrice artistique",
        ville: "Paris"
    ),
    profileImage: nil,
    tekiyoID: "3A1B-7E21",
    username: "@marieD77"
)
#endif
```

---

## 📱 Données Mock

### Profil
- **Nom** : Marie Dupont
- **Username** : @marieD77
- **Métier** : Directrice artistique
- **Ville** : Paris
- **Tekiyo ID** : 3A1B-7E21
- **Trust Score** : 27% (3/10)

### Conversations
1. **Marie D.** - En ligne, non lu, "Salut, tu peux..."
2. **Thomas S.** - Non lu, "Merci pour aujourd'hui"
3. **Julie F.** - "Vous a envoyé 50€"
4. **BNP** - Vérifié, "Vous a envoyé un document"

### Messages (chat Marie D.)
- Transaction TekiyoPay : 50€
- User : "Putin merci beaucoup !"
- Marie : "Avec plaisir c'était top"
- User : "Grave !"

### Transactions Wallet
- **Aujourd'hui** :
  - Marie D. +23€ 17:03
  - Thomas L. -74€ 12:08
- **Hier** :
  - Marie D. +23€ 17:03
  - Thomas L. -74€ 12:08
- **Jeudi 18/02** :
  - Marie D. +23€ 17:03

### Liens sociaux
Facebook, Twitter, Instagram, Snapchat, LinkedIn, GitHub, TikTok, Discord, Telegram, Gmail, WhatsApp, YouTube

---

## 🔐 Permissions requises

### Info.plist
- `NSCameraUsageDescription` : "Pour prendre votre photo d'identité"
- `NSFaceIDUsageDescription` : "Pour sécuriser votre identité"
- `NSLocationWhenInUseUsageDescription` : "Pour afficher votre ville"
- `NSPhotoLibraryUsageDescription` : "Pour importer une photo"

---

## 🎯 Principes de développement appliqués

### Architecture
- ✅ **MVVM strict** - Séparation Views / ViewModels / Models
- ✅ **Single Responsibility** - 1 fichier = 1 responsabilité
- ✅ **Modularité** - Composants réutilisables
- ✅ **Injection de dépendances** - ViewModels testables
- ✅ **Fichiers courts** - Max 500 lignes, idéalement < 400

### Code Quality
- ✅ **Nommage descriptif** - Pas de noms vagues (data, info, helper)
- ✅ **Fonctions courtes** - < 30-40 lignes
- ✅ **Classes ciblées** - Pas de God classes
- ✅ **Commentaires utiles** - MARK pour sections
- ✅ **SwiftUI natif** - Composants système iOS

### Performance
- ✅ **Lazy loading** - LazyVStack/LazyVGrid
- ✅ **Optimisations GPU** - .drawingGroup()
- ✅ **Animations ciblées** - .animation(value:)
- ✅ **États stables** - Éviter re-renders inutiles

---

## 📦 Fichiers clés du projet

### Core
- `Tekiyo_IDApp.swift` - Point d'entrée
- `Typography.swift` - Styles texte
- `Color+Hex.swift` - Extension couleurs hex
- `View+DebugRender.swift` - Debug renders

### Managers
- `HapticManager.swift` - Feedback haptique
- `BiometricAuthManager.swift` - Face ID
- `CameraManager.swift` - Caméra
- `LocationManager.swift` - Géolocalisation
- `RealtimeFaceDetector.swift` - Détection visage

### Components
- `LargeCircularCodeView.swift` - QR circulaire
- `WalletWidget.swift` - Widget portefeuille
- `CameraPreview.swift` - Preview caméra
- `FaceDetectionOverlay.swift` - Overlay détection
- `PrimaryButton.swift` - Bouton principal

### Features
- **Onboarding** : StartView, IntroductionView
- **Auth** : FaceIDSetupView
- **Identity** : IdentitySetupView, PhotoCaptureView, FingerprintCreationView, IdentityCompleteView
- **Messaging** : MessageListView, ChatView, ConversationRow, MessageBubble, TransactionBubble
- **Wallet** : WalletView, TransactionRow, WalletActionButtons
- **Profile** : ProfileView, ProfileTabContainerView, RecentActivitiesView

---

## 🚀 État actuel du projet

### ✅ Fonctionnalités complètes
- Onboarding complet (intro, FaceID, formulaire, photo)
- Détection de visage temps réel avec Vision
- Système de messaging natif avec chat
- Portefeuille avec transactions groupées
- Profil utilisateur avec QR code circulaire
- TabBar 4 onglets (icônes seulement)
- Géolocalisation temps réel
- Dark mode par défaut
- Architecture MVVM complète
- Composants 100% SwiftUI natifs

### 🔄 En attente
- Écran Home (placeholder actuel)
- Backend / API intégration
- Blockchain pour empreinte digitale
- Vérification d'identité réelle
- Notifications push
- Partage de profil

### 🐛 Debug features
- Skip intro/FaceID sur Mac
- Démarrage direct sur profil en DEBUG
- Données mock pour tous les écrans
- Logging des renders

---

## 📈 Statistiques

- **Langage** : Swift 5.9+, SwiftUI
- **Minimum iOS** : iOS 16.0+
- **Architecture** : MVVM
- **Fichiers** : ~50+ fichiers Swift
- **Composants** : 30+ composants réutilisables
- **ViewModels** : 10+ ViewModels
- **Managers** : 5 Singletons
- **Écrans** : 15+ vues principales
- **Modèles** : 10+ structures de données

---

## 🎓 Bonnes pratiques appliquées

1. **Pas de dépendances externes** - SwiftUI/UIKit natif uniquement
2. **Support Dark/Light mode** - Couleurs système adaptatives
3. **Accessibilité** - Dynamic Type, VoiceOver ready
4. **Performances** - Optimisations GPU, lazy loading
5. **Sécurité** - Face ID, données locales
6. **Tests** - Architecture testable (injection dépendances)
7. **Scalabilité** - Modulaire, extensible
8. **Maintenance** - Code propre, bien documenté

---

## 🔮 Prochaines étapes suggérées

1. **Backend integration** - API REST ou GraphQL
2. **Blockchain** - Stockage empreinte décentralisée
3. **Notifications** - Push notifications
4. **Partage** - QR code scan, NFC
5. **Analytics** - Tracking usage
6. **Tests** - Unit tests, UI tests
7. **CI/CD** - Automatisation déploiement
8. **App Clip** - Version légère pour vérification rapide

---

## 📝 Notes importantes

- **Mode DEBUG activé** : App démarre sur profil avec données mock
- **Permissions requises** : Caméra, Face ID, Localisation, Photos
- **SwiftUI natif** : Aucune lib tierce, 100% composants système
- **MVVM strict** : Séparation claire Models/Views/ViewModels
- **Optimisé énergie** : Animations ciblées, pas de loops infinies
- **Design Apple-like** : Frosted glass, continuous corners, SF Symbols

---

*Projet Tekiyo ID - Identity & Proof of Humanity*
*Développé avec SwiftUI, MVVM Architecture, 100% Native iOS*


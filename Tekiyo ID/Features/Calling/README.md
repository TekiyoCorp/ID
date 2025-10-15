# Système d'appels audio/vidéo Tekiyo ID

## 📋 Vue d'ensemble

Système d'appels natif iOS implémenté avec WebRTC, CallKit et PushKit pour l'application Tekiyo ID.

## 🏗️ Architecture

### Composants principaux

1. **CallManager** - Coordinateur principal
2. **WebRTCManager** - Gestion des connexions peer-to-peer
3. **CallKitManager** - Intégration avec l'interface d'appel iOS native
4. **PushKitManager** - Gestion des notifications d'appels entrants
5. **CallView** - Interface SwiftUI pour les appels

### Modèles de données

- **Call** - Modèle principal des appels
- **CallType** - Audio ou vidéo
- **CallDirection** - Entrant ou sortant
- **CallState** - État de l'appel

## 🔧 Configuration requise

### Dépendances

```swift
// Dans Package.swift
dependencies: [
    .package(url: "https://github.com/WebRTC-Swift/WebRTC", from: "1.1.0")
]
```

### Permissions (Info.plist)

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Tekiyo ID a besoin d'accéder à votre microphone pour les appels audio et vidéo.</string>

<key>NSCameraUsageDescription</key>
<string>Tekiyo ID a besoin d'accéder à votre caméra pour les appels vidéo.</string>

<key>UIBackgroundModes</key>
<array>
    <string>voip</string>
    <string>audio</string>
</array>
```

## 🚀 Utilisation

### 1. Démarrer un appel

```swift
@StateObject private var callManager = CallManager()

// Démarrer un appel vidéo
callManager.startCall(
    to: "user_123",
    callerName: "Marie Dupont",
    type: .video
)
```

### 2. Intégration dans ChatView

Les boutons d'appel sont automatiquement ajoutés dans le header de ChatView :

```swift
// Bouton appel vidéo
Button(action: {
    callType = .video
    showCallView = true
}) {
    Image(systemName: "video.fill")
        .floatingGlassButton()
}

// Bouton appel audio
Button(action: {
    callType = .audio
    showCallView = true
}) {
    Image(systemName: "phone.fill")
        .floatingGlassButton()
}
```

### 3. Gestion des permissions

```swift
@StateObject private var permissionsManager = AVFoundationPermissionsManager()

// Vérifier les permissions
let hasPermissions = permissionsManager.hasRequiredPermissions(for: .video)

// Demander les permissions
let micStatus = await permissionsManager.requestMicrophonePermission()
let cameraStatus = await permissionsManager.requestCameraPermission()
```

## 🎨 Interface utilisateur

### CallView

- **Vidéo plein écran** pour l'appelé distant
- **Picture-in-picture** pour la vidéo locale
- **Contrôles tactiles** : mute, vidéo, haut-parleur, raccrocher
- **Masquage automatique** des contrôles après 3 secondes
- **Transitions fluides** avec animations SwiftUI

### Contrôles disponibles

- 🎤 **Mute/Unmute** - Contrôle audio
- 📹 **Caméra on/off** - Contrôle vidéo (appels vidéo uniquement)
- 🔊 **Haut-parleur** - Sortie audio
- 📞 **Raccrocher** - Terminer l'appel

## 🔔 Notifications Push

### Configuration PushKit

```swift
// Structure du payload VoIP
struct VoIPPushPayload {
    let callerID: String
    let callerName: String
    let callType: CallType
    let callUUID: UUID
    let timestamp: Date
}
```

### Envoi de notification (Backend)

```json
{
    "aps": {
        "alert": {
            "title": "Appel entrant",
            "body": "Marie Dupont vous appelle"
        },
        "sound": "TekiyoRingtone.caf",
        "badge": 1
    },
    "caller_id": "user_123",
    "caller_name": "Marie Dupont",
    "call_type": "video",
    "call_uuid": "12345678-1234-1234-1234-123456789abc",
    "timestamp": 1640995200
}
```

## 🎯 CallKit Integration

### Configuration du provider

```swift
let providerConfiguration = CXProviderConfiguration(localizedName: "Tekiyo ID")
providerConfiguration.supportsVideo = true
providerConfiguration.maximumCallGroups = 1
providerConfiguration.maximumCallsPerCallGroup = 1
providerConfiguration.supportedHandleTypes = [.generic]
providerConfiguration.tintColor = UIColor(hex: "#007AFF")
```

### Branding Tekiyo

- **Couleur principale** : `#007AFF` (bleu iOS)
- **Couleur secondaire** : `#002FFF` (bleu Tekiyo)
- **Icône personnalisée** : Logo Tekiyo
- **Sonnerie** : `TekiyoRingtone.caf`

## 🧪 Tests

### CallTestView

Interface de test complète pour :

- ✅ Démarrer des appels sortants
- ✅ Simuler des appels entrants
- ✅ Tester les contrôles média
- ✅ Vérifier les permissions
- ✅ Observer l'état des connexions

### Simulation d'appels entrants

```swift
// Simuler un appel entrant
callManager.simulateIncomingCall(
    from: "test_user_123",
    callerName: "Marie Dupont",
    type: .video
)
```

## 🔒 Sécurité

### Permissions

- **Microphone** : Requis pour tous les appels
- **Caméra** : Requis uniquement pour les appels vidéo
- **Notifications** : Requis pour les appels entrants

### Validation

- Vérification des permissions avant chaque appel
- Gestion des erreurs de connexion
- Nettoyage automatique des ressources

## 📱 Support iOS

- **Version minimum** : iOS 16.0+
- **Frameworks requis** : WebRTC, CallKit, PushKit, AVFoundation
- **Architecture** : arm64 (iPhone uniquement)

## 🚀 Déploiement

### Étapes de configuration

1. **Ajouter WebRTC** au projet
2. **Configurer Info.plist** avec les permissions
3. **Intégrer CallTestView** pour les tests
4. **Configurer le backend** pour les notifications Push
5. **Tester sur device** (pas de simulateur pour CallKit)

### Notes importantes

- ⚠️ **CallKit ne fonctionne pas sur simulateur**
- ⚠️ **WebRTC nécessite un device physique**
- ⚠️ **Les notifications VoIP nécessitent un certificat Push**

## 📞 Support

Pour toute question sur l'implémentation des appels :

1. Vérifier les permissions dans les Réglages iOS
2. Tester avec CallTestView
3. Consulter les logs Xcode pour les erreurs WebRTC
4. Vérifier la configuration du backend pour les notifications

---

**Développé pour Tekiyo ID** 🎯

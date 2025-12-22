//
//  DataEncryption.swift
//  DesertSurvivors
//
//  Provides encryption/decryption for saved player data.
//  Uses CryptoKit for AES-GCM encryption with device-bound keys.
//

import Foundation
import CryptoKit

enum EncryptionError: Error, LocalizedError {
    case encryptionFailed
    case decryptionFailed
    case keyGenerationFailed
    case invalidData

    var errorDescription: String? {
        switch self {
        case .encryptionFailed:
            return "Failed to encrypt data"
        case .decryptionFailed:
            return "Failed to decrypt data"
        case .keyGenerationFailed:
            return "Failed to generate encryption key"
        case .invalidData:
            return "Invalid encrypted data format"
        }
    }
}

class DataEncryption {

    // MARK: - Singleton

    static let shared = DataEncryption()

    private init() {}

    // MARK: - Key Management

    private let keychainService = "com.desertsurvivors.encryption"
    private let keychainAccount = "dataEncryptionKey"

    /// Gets or creates the encryption key stored in Keychain
    private func getOrCreateKey() throws -> SymmetricKey {
        // Try to load existing key from Keychain
        if let existingKeyData = loadKeyFromKeychain() {
            return SymmetricKey(data: existingKeyData)
        }

        // Generate new key
        let newKey = SymmetricKey(size: .bits256)
        let keyData = newKey.withUnsafeBytes { Data($0) }

        // Store in Keychain
        guard saveKeyToKeychain(keyData) else {
            throw EncryptionError.keyGenerationFailed
        }

        return newKey
    }

    private func loadKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data else {
            return nil
        }

        return data
    }

    private func saveKeyToKeychain(_ keyData: Data) -> Bool {
        // Delete existing key if present
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new key
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        return status == errSecSuccess
    }

    // MARK: - Encryption/Decryption

    /// Encrypts data using AES-GCM
    /// - Parameter data: The plaintext data to encrypt
    /// - Returns: The encrypted data (nonce + ciphertext + tag)
    func encrypt(_ data: Data) throws -> Data {
        let key = try getOrCreateKey()

        do {
            let sealedBox = try AES.GCM.seal(data, using: key)

            // Combine nonce + ciphertext + tag into single Data
            guard let combined = sealedBox.combined else {
                throw EncryptionError.encryptionFailed
            }

            return combined
        } catch {
            throw EncryptionError.encryptionFailed
        }
    }

    /// Decrypts data using AES-GCM
    /// - Parameter encryptedData: The encrypted data (nonce + ciphertext + tag)
    /// - Returns: The decrypted plaintext data
    func decrypt(_ encryptedData: Data) throws -> Data {
        let key = try getOrCreateKey()

        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            let decryptedData = try AES.GCM.open(sealedBox, using: key)
            return decryptedData
        } catch {
            throw EncryptionError.decryptionFailed
        }
    }

    // MARK: - Convenience Methods

    /// Encrypts a Codable object
    func encrypt<T: Encodable>(_ object: T) throws -> Data {
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(object)
        return try encrypt(jsonData)
    }

    /// Decrypts data into a Codable object
    func decrypt<T: Decodable>(_ encryptedData: Data, as type: T.Type) throws -> T {
        let decryptedData = try decrypt(encryptedData)
        let decoder = JSONDecoder()
        return try decoder.decode(type, from: decryptedData)
    }
}

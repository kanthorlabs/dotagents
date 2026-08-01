# Security and Cryptography

## Secure Random

```go
import "crypto/rand"

// Random bytes
buf := make([]byte, 32)
rand.Read(buf)

// Random text (Go 1.24+)
text := rand.Text()
```

## Hashing

```go
import "crypto/sha256"

// One-shot
sum := sha256.Sum256(data)
```

## Post-Quantum Cryptography (Go 1.24+)

```go
import "crypto/mlkem"

dk, err := mlkem.GenerateKey768()
if err != nil {
    log.Fatal(err)
}
ek := dk.EncapsulationKey()
sharedKey, ciphertext := ek.Encapsulate()
decryptedKey, err := dk.Decapsulate(ciphertext)
```

## TLS Configuration

```go
config := &tls.Config{
    MinVersion: tls.VersionTLS13,
    // Post-quantum enabled by default in Go 1.26
}
```

## HPKE (Go 1.26+)

```go
import "crypto/hpke"

ciphertext, enc, err := hpke.Seal(
    hpke.MLKEM768X25519, hpke.HKDFSHA256, hpke.AES128GCM,
    recipientPub, info, aad, plaintext,
)

plaintext, err := hpke.Open(
    hpke.MLKEM768X25519, hpke.HKDFSHA256, hpke.AES128GCM,
    recipientPriv, enc, info, aad, ciphertext,
)
```

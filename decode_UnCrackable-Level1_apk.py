from Crypto.Cipher import AES
import base64

# Chiave AES in esadecimale
key_hex = "8d127684cbc37c17616d806cf50473cc"
key = bytes.fromhex(key_hex)

# Ciphertext codificato in Base64
cipher_b64 = "5UJiFctbmgbDoLXmpL12mkno8HT4Lv8dlat8FxR2GOc="
cipher_bytes = base64.b64decode(cipher_b64)

# AES decryption in ECB mode
cipher = AES.new(key, AES.MODE_ECB)
plaintext = cipher.decrypt(cipher_bytes)

# Rimuovi padding PKCS7
pad_len = plaintext[-1]
plaintext = plaintext[:-pad_len]

print("[+] Password decifrata:", plaintext.decode())

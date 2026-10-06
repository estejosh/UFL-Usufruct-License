"""Licensor side: sign a paid-use key for one Component. Run by the Licensor
(or its payment webhook) after a Licensee pays the Published Price.
Needs: pip install cryptography. The private key never ships in the Software."""
import base64, json, sys
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives import serialization as S

def b64(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode()

def new_keypair():
    k = Ed25519PrivateKey.generate()
    priv = k.private_bytes(S.Encoding.Raw, S.PrivateFormat.Raw, S.NoEncryption())
    pub = k.public_key().public_bytes(S.Encoding.Raw, S.PublicFormat.Raw)
    return priv, pub  # embed `pub` in the Software; keep `priv` offline

def issue(priv, component, licensee, period_start, period_end, seats=1):
    payload = json.dumps({"v": 1, "license": "UFL-3.5", "component": component,
                          "licensee": licensee, "seats": seats,
                          "period_start": period_start, "period_end": period_end},
                         sort_keys=True, separators=(",", ":")).encode()
    sig = Ed25519PrivateKey.from_private_bytes(priv).sign(payload)
    return b64(payload) + "." + b64(sig)

if __name__ == "__main__":
    priv, pub = new_keypair()
    print("public key (embed in the Software):", b64(pub))
    print("key:", issue(priv, "snifrig-fix", "Example Licensee", "2026-10-06", "2027-10-06"))

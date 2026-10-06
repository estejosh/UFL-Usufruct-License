"""Licensor side: sign a paid-use key for one Component. Run by the Licensor
(or its payment webhook) after a Licensee pays the Published Price.
Needs: pip install cryptography. The private key never ships in the Software."""
import base64, json, sys
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey
from cryptography.hazmat.primitives import serialization as S

def b64(b): return base64.urlsafe_b64encode(b).rstrip(b"=").decode()

def machine_id_hash(machine_id):
    import hashlib
    return hashlib.sha256(machine_id.encode()).hexdigest()

def new_keypair():
    k = Ed25519PrivateKey.generate()
    priv = k.private_bytes(S.Encoding.Raw, S.PrivateFormat.Raw, S.NoEncryption())
    pub = k.public_key().public_bytes(S.Encoding.Raw, S.PublicFormat.Raw)
    return priv, pub  # embed `pub` in the Software; keep `priv` offline

def issue(priv, component, licensee, issued_at, not_after, seats=1, machine=None):
    """Keep keys short-lived (for example 30 days) and re-issue them from the
    Licensee's account on the Licensor's website, with a cap on re-issues per
    paid period. `machine` is an optional hash the Licensee supplies when
    asking for the key; the Software compares it locally. That limits sharing
    without the Software ever reporting anything."""
    d = {"v": 1, "license": "UFL-3.5", "component": component, "licensee": licensee,
         "seats": seats, "issued_at": issued_at, "not_after": not_after}
    if machine: d["machine"] = machine
    payload = json.dumps(d, sort_keys=True, separators=(",", ":")).encode()
    sig = Ed25519PrivateKey.from_private_bytes(priv).sign(payload)
    return b64(payload) + "." + b64(sig)

if __name__ == "__main__":
    priv, pub = new_keypair()
    print("public key (embed in the Software):", b64(pub))
    print("key:", issue(priv, "snifrig-fix", "Example Licensee", "2026-10-06", "2026-11-05", machine=machine_id_hash("example-machine")))

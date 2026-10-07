"""Software side: check a paid-use key entirely offline.
Imports no network library and makes no network call (Section 10). The only
inputs are the key file, the embedded public key, the local clock, and a
local machine hash."""
import base64, datetime, json
from cryptography.exceptions import InvalidSignature
from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PublicKey

def unb64(s): return base64.urlsafe_b64decode(s + "=" * (-len(s) % 4))

def check(key, public_key_b64, component, today=None, machine=None, last_seen=None):
    """Returns (ok, reason). ok means: signed by the Licensor, for this
    Component, and the local date is inside the paid period."""
    try:
        p, s = key.strip().split(".")
        payload, sig = unb64(p), unb64(s)
        Ed25519PublicKey.from_public_bytes(unb64(public_key_b64)).verify(sig, payload)
    except (ValueError, InvalidSignature):
        return False, "key is not signed by the Licensor"
    d = json.loads(payload)
    if d.get("license") != "UFL-3.5" or d.get("component") != component:
        return False, "key is for a different Component or license version"
    today = today or datetime.date.today().isoformat()
    # last_seen: the latest date this machine has run the Software, kept in a
    # local file. A clock set backwards to reuse an expired key is refused.
    if last_seen and today < last_seen:
        return False, "the system clock is earlier than a date already seen on this machine"
    if d.get("machine") and d["machine"] != machine:
        return False, "key was issued for a different machine"
    if not (d["issued_at"] <= today <= d["not_after"]):
        return False, "key is valid " + d["issued_at"] + " to " + d["not_after"] + "; get a fresh key from your account"
    return True, "Paid Use for " + component + " until " + d["not_after"]

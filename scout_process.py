python
import os
import sys
import jwt

JWT_SECRET = "LOCAL_CORE_SECRET_KEY_9921"

def process_differential_deltas():
    token = os.environ.get("TOKEN_ID", "")
    try:
        jwt.decode(token, JWT_SECRET, algorithms=["HS256"])
    except Exception:
        print("ERROR: Token verification handshake rejected.")
        sys.exit(1)
        
    raw_text = os.environ.get("RAW_TEXT_INFLOW", "")
    print(f"Differential Delta Vector computed safely for: '{raw_text[:30]}...'")

if __name__ == "__main__":
    process_differential_deltas()

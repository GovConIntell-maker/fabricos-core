# keygen.py
import random

def generate_sovereign_key(batch_id=7412, option_flag=9921):
    """
    Generates a mathematically valid FabricOS offline product key.
    - batch_id: 4-digit production batch tracking number (Default: 7412)
    - option_flag: 4-digit licensing option code (Default: 9921 for Lifetime)
    """
    # Force formatting boundaries
    payload_p1 = f"{batch_id:04d}"
    payload_p2 = f"{option_flag:04d}"
    
    # Execute the matching identity algorithm from coordinator.dart
    combined_payload = int(payload_p1) + int(payload_p2)
    calculated_hash = (combined_payload * 541) % 65535
    
    # Convert remainder to a 4-digit uppercase hex checksum string
    check_digits = f"{calculated_hash:04X}"
    
    # Compile the final validated key string
    product_key = f"FBRC-{payload_p1}-{payload_p2}-{check_digits}"
    return product_key

if __name__ == "__main__":
    print("=== FABRICOS MASTER OFFLINE PRODUCT KEY GENERATOR ===")
    print("Generating 5 valid commercial lifetime activation keys...\n")
    
    for _ in range(5):
        # Randomize batch prefix slightly to give unique sequences per customer purchase
        random_batch = random.randint(1000, 8999)
        new_key = generate_sovereign_key(batch_id=random_batch, option_flag=9921)
        print(f"🔑 Key Generated Successfully: {new_key}")
        
    print("\nDrop these keys directly into your automated onboarding welcome emails.")

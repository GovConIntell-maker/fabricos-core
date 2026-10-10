python
import socket
import time
import json
import pyperclip 

class FabricOSCompanion:
    def __init__(self):
        self.phone_ip = "192.168.43.1" 
        self.phone_port = 8990
        self.last_copied_context = ""

    def watch_clipboard_forever(self):
        print("[FabricOS Companion] Background sync active...")
        while True:
            try:
                current_text = pyperclip.paste().strip()
                if current_text and current_text != self.last_copied_context:
                    self.last_copied_context = current_text
                    payload = {"domain": "CrossDeviceClipboard", "data": current_text}
                    
                    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    sock.settimeout(2.0)
                    sock.connect((self.phone_ip, self.phone_port))
                    sock.sendall(json.dumps(payload).encode('utf-8'))
                    sock.close()
            except Exception:
                pass
            time.sleep(1.5)

if __name__ == "__main__":
    service = FabricOSCompanion()
    service.watch_clipboard_forever()

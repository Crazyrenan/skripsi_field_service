# File: create_user.py
from passlib.context import CryptContext
from sqlalchemy import create_engine, text

# --- KONFIGURASI 1: DATABASE ---
# Ganti user, password, dan nama_database sesuai docker-compose.yml Anda
# Format: mysql+mysqlconnector://USER:PASSWORD@localhost:PORT/NAMA_DB
DATABASE_URL = "mysql+mysqlconnector://root:root@localhost:3306/skripsi_db" 

# --- KONFIGURASI 2: USER BARU ---
EMAIL_BARU = "admin@example.com"
PASSWORD_BARU = "rahasia123" 

# Setup Hashing (Supaya password tidak plain text)
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def create_admin():
    print("⏳ Sedang menghubungkan ke database...")
    try:
        # Buat koneksi
        engine = create_engine(DATABASE_URL)
        connection = engine.connect()
        
        # Hash password
        hashed_pwd = pwd_context.hash(PASSWORD_BARU)
        
        # --- KONFIGURASI 3: QUERY SQL ---
        # PERHATIKAN: Sesuaikan nama tabel ('users') dan nama kolom
        # Cek models.py Anda: apakah 'hashed_password' atau 'password'?
        query = text("""
            INSERT INTO users (email, username, hashed_password, is_active) 
            VALUES (:email, :username, :pwd, :active)
        """)
        
        # Eksekusi Query
        connection.execute(query, {
            "email": EMAIL_BARU,
            "username": "admin", # Jika tabel Anda butuh username
            "pwd": hashed_pwd,
            "active": True # Anggap user langsung aktif
        })
        
        connection.commit()
        print(f"✅ SUKSES! User '{EMAIL_BARU}' dengan password '{PASSWORD_BARU}' berhasil dibuat.")
        
    except Exception as e:
        print(f"❌ ERROR: {e}")
        print("💡 Tips: Cek nama tabel atau kolom di models.py Anda.")
    finally:
        if 'connection' in locals():
            connection.close()

if __name__ == "__main__":
    create_admin()
from passlib.context import CryptContext
from sqlalchemy import create_engine, text

# 1. Konfigurasi Database (PostgreSQL)
# Pastikan password 'secure_password_123' sesuai docker-compose Anda
DATABASE_URL = "postgresql://admin_skripsi:secure_password_123@localhost:5432/field_service_db"

# 2. Data Baru untuk Budi
EMAIL_TARGET = "budi@field.com"
PASSWORD_BARU = "budi123"  # <--- Password barunya ini

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def reset_password():
    print(f"🔄 Sedang mereset password untuk {EMAIL_TARGET}...")
    
    try:
        engine = create_engine(DATABASE_URL)
        connection = engine.connect()
        
        # Enkripsi password baru
        hashed_pwd = pwd_context.hash(PASSWORD_BARU)
        
        # Query Update
        query = text("""
            UPDATE users 
            SET password_hash = :pwd, is_active = true 
            WHERE email = :email
        """)
        
        result = connection.execute(query, {
            "pwd": hashed_pwd,
            "email": EMAIL_TARGET
        })
        
        connection.commit()
        
        if result.rowcount > 0:
            print(f"✅ BERHASIL! Password {EMAIL_TARGET} sudah diganti.")
            print(f"🔑 Password baru: {PASSWORD_BARU}")
        else:
            print(f"⚠️ GAGAL: User dengan email {EMAIL_TARGET} tidak ditemukan di database.")
            print("   Mungkin emailnya salah ketik atau user belum pernah dibuat?")
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
    finally:
        if 'connection' in locals():
            connection.close()

if __name__ == "__main__":
    reset_password()
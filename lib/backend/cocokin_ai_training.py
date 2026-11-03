# Google Colab Notebook — Pelatihan Model Personal Color Cocokin
# Framework: Python, OpenCV, Scikit-Learn, NumPy

# ========================================================
# LANGKAH 1: PERSIAPAN ENVIRONMENT & DATASET SIMULASI
# ========================================================
import cv2
import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report
import joblib

print("1. Menyiapkan Dataset Fitur Warna Kulit (RGB, HSV, Lab)...")

# Data ekstraksi piksel kulit wajah: [R, G, B, H, S, V, L, a, b]
# Target Label: Warm Autumn, Cool Summer, Warm Spring, Cool Winter
np.random.seed(42)

# Simulasi data ekstraksi kulit sesuai kategori undertone & skin tone
# 1. Warm Autumn (Cenderung warm undertone, medium tone, nilai 'a' & 'b' positif tinggi)
warm_autumn = np.random.normal(loc=[195, 145, 110, 18, 110, 195, 62, 16, 22], scale=10, size=(250, 9))
# 2. Cool Summer (Cool undertone, fair-medium, rona kebiruan/pink lembut)
cool_summer = np.random.normal(loc=[220, 175, 170, 5, 60, 220, 75, 14, 8], scale=10, size=(250, 9))
# 3. Warm Spring (Warm cerah, peach terang, high value)
warm_spring = np.random.normal(loc=[235, 185, 135, 20, 105, 235, 78, 15, 25], scale=10, size=(250, 9))
# 4. Cool Winter (Kontras tajam, fair atau deep dengan blue base)
cool_winter = np.random.normal(loc=[160, 120, 125, 170, 70, 160, 52, 15, 2], scale=10, size=(250, 9))

X = np.vstack([warm_autumn, cool_summer, warm_spring, cool_winter])
y = np.array(['Warm Autumn']*250 + ['Cool Summer']*250 + ['Warm Spring']*250 + ['Cool Winter']*250)

df = pd.DataFrame(X, columns=['R', 'G', 'B', 'H', 'S', 'V', 'L', 'a', 'b'])
df['Personal_Color'] = y
print("Jumlah sampel data:", len(df))
print(df.head())

# ========================================================
# LANGKAH 2: TRAINING MODEL MACHINE LEARNING
# ========================================================
print("\n2. Melatih Model Classifier...")
X_train, X_test, y_train, y_test = train_test_split(df[['R', 'G', 'B', 'H', 'S', 'V', 'L', 'a', 'b']], df['Personal_Color'], test_size=0.2, random_state=42)

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X_train, y_train)

# Evaluasi Akurasi
y_pred = model.predict(X_test)
print("\nHasil Evaluasi Model (Akurasi):")
print(classification_report(y_test, y_pred))

# ========================================================
# LANGKAH 3: FUNGSI INFERENSI GAMBAR (PREDIKSI DARI FOTO WAJAH)
# ========================================================
def analyze_face_color(image_path_or_array):
    """
    Mengekstrak rata-rata piksel RGB, HSV, dan Lab di area ROI wajah (oval)
    Lalu memprediksi Personal Color menggunakan model yang sudah dilatih.
    """
    # Simulasi pembacaan foto wajah
    # img = cv2.imread(image_path)
    # Ubah color space
    # hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)
    # lab = cv2.cvtColor(img, cv2.COLOR_BGR2LAB)
    
    # Contoh input piksel hasil ekstraksi wajah pengguna
    sample_face = np.array([[198, 142, 108, 17, 112, 198, 61, 17, 23]])
    prediksi = model.predict(sample_face)[0]
    probabilitas = np.max(model.predict_proba(sample_face)) * 100
    
    return {
        "personal_color": prediksi,
        "confidence": f"{probabilitas:.2f}%",
        "undertone": "Warm" if "Warm" in prediksi else "Cool",
        "skin_tone": "Medium"
    }

print("\n3. Uji Coba Prediksi dari Fitur Wajah:")
hasil = analyze_face_color(None)
print("Hasil Analisis AI:", hasil)

# Simpan Model untuk Deployment Backend
joblib.dump(model, 'cocokin_personal_color_model.pkl')
print("\nModel berhasil diexport: cocokin_personal_color_model.pkl")

import pandas as pd
from datetime import datetime
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
from qdrant_client.models import PointStruct, VectorParams, Distance
import uuid

client = QdrantClient(host="localhost", port=6333)
collection_name = "mesai_chatbot"

df = pd.read_excel("mesai_saatleri.xlsx")
model = SentenceTransformer("all-MiniLM-L6-v2")

points = []

for _, row in df.iterrows():
    giris_tarih = pd.to_datetime(row["Giriş Tarihi"], dayfirst=True).strftime("%d.%m.%Y")
    cikis_tarih = pd.to_datetime(row["Çıkış Tarihi"], dayfirst=True).strftime("%d.%m.%Y")

    giris_saat = str(row["Giriş Saati"])[:5]
    cikis_saat = str(row["Çıkış Saati"])[:5]
    name = str(row["Personel Adı"]).strip()

    fmt = "%H:%M"
    sure_dk = (
        datetime.strptime(cikis_saat, fmt) - datetime.strptime(giris_saat, fmt)
    ).seconds // 60

    text = f"{name} adlı personel {giris_tarih} tarihinde {giris_saat} giriş - {cikis_saat} çıkış yaptı. Toplam {sure_dk} dakika çalıştı."
    vector = model.encode(text)

    payload = {
        "text": text,
        "personel": name,
        "giris_tarih": giris_tarih,
        "cikis_tarih": cikis_tarih,
        "giris_saat": giris_saat,
        "cikis_saat": cikis_saat,
        "calisma_suresi_dk": sure_dk
    }

    points.append(PointStruct(id=str(uuid.uuid4()), vector=vector, payload=payload))

# Koleksiyon oluşturma
if not client.collection_exists(collection_name):
    client.create_collection(
        collection_name=collection_name,
        vectors_config=VectorParams(size=384, distance=Distance.COSINE)
    )
else:
    client.delete_collection(collection_name)
    client.create_collection(
        collection_name=collection_name,
        vectors_config=VectorParams(size=384, distance=Distance.COSINE)
    )

client.upsert(collection_name=collection_name, points=points)

print(f"{len(points)} kayıt Qdrant'a yüklendi.")

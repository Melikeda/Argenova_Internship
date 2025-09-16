from fastapi import FastAPI
from pydantic import BaseModel
from sentence_transformers import SentenceTransformer
from qdrant_client import QdrantClient
import ollama

app = FastAPI()

# Qdrant bağlantısı
qdrant_client = QdrantClient(host="localhost", port=6333)
collection_name = "mesai_chatbot"

# Embedding modeli
embed_model = SentenceTransformer("all-MiniLM-L6-v2")

class SoruModel(BaseModel):
    soru: str

def build_rag_prompt(soru: str, baglam: str) -> str:
    return f"""
Sen, Exceldeki personellerin çalışma verilerini okuyup onlar hakkında sorulan sorulara cevap veren bir Türkçe yapay zeka asistanısın.

TÜM personelleri analiz ederek aşağıdaki türden sorularda etkili ve doğru cevaplar üret:
- Hesaplama sorularında, veri üzerinden doğru ve eksiksiz sonuçlar sun.
- Yorum veya analiz sorularında, tutarlı ve mantıklı değerlendirmeler yap.
- "En fazla" veya "en az çalışan kim" gibi sorularda, tüm personelleri kapsamlı şekilde analiz ederek kesin cevaplar ver.

GÖREVLER:
- Giriş-çıkış saatlerinden çalışma süresini hesapla.
- Personel performansını ve çalışma sürelerini karşılaştır.
- Veri temelli, rakamlarla desteklenmiş çıkarımlar yap.

KURALLAR:
- Hesaplamaları doğru, tutarlı ve eksiksiz yap.
- Sadece veriye dayalı, net ve anlaşılır Türkçe kullan.

BAĞLAM:
{baglam}

SORU: {soru}

CEVAP:"""

@app.post("/sor")
async def sor(soru_model: SoruModel):
    soru = soru_model.soru

    # Soru için embedding oluştur
    soru_vektor = embed_model.encode(soru)

    # Qdrant'tan ilgili kayıtları çek
    search_results = qdrant_client.search(
        collection_name=collection_name,
        query_vector=soru_vektor,
        limit=10,
        score_threshold=0.5
    )

    # Bağlamı oluştur
    baglam = "\n".join(
        hit.payload["text"] for hit in search_results if hit.payload and "text" in hit.payload
    )

    # Prompt hazırla
    prompt = build_rag_prompt(soru, baglam)

    # Ollama LLM ile cevap al
    response = ollama.chat(model="llama3", messages=[{"role": "user", "content": prompt}])

    return {"cevap": response["message"]["content"]}
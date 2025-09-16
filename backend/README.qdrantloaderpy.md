# Qdrant Loader

Bu dosya (`qdrant_loader.py`), Excel dosyasındaki mesai verilerini Qdrant vektör veritabanına yüklemek için kullanılır. 

## Özellikler

- `mesai_saatleri.xlsx` dosyasını okur.
- Her satır için:
  - Personel adı
  - Giriş ve çıkış tarihleri
  - Giriş ve çıkış saatleri
  - Toplam çalışma süresi (dakika)
- Bu verileri anlamlı bir cümleye dönüştürür.
- Cümleyi **SentenceTransformer** ile vektöre çevirir.
- Vektörleri ve ilgili bilgileri Qdrant'a kaydeder.

## Kullanılan Kütüphaneler

- `pandas` → Excel verilerini okumak için
- `datetime` → Tarih ve saat hesaplamaları için
- `sentence_transformers` → Metni vektörleştirmek için
- `qdrant_client` → Qdrant veritabanı ile etkileşim için
- `uuid` → Her kayıt için benzersiz ID oluşturmak için

## Qdrant Koleksiyonu

- Koleksiyon adı: `mesai_chatbot`
- Vektör boyutu: 384 (all-MiniLM-L6-v2 modeli kullanılır)
- Mesafe ölçütü: Cosine Distance
- Mevcut koleksiyon varsa silinir ve yeniden oluşturulur.

## Çalıştırma

1. Qdrant sunucusunun çalıştığından emin olun (`localhost:6333`).
2. `mesai_saatleri.xlsx` dosyasının aynı klasörde olduğundan emin olun.
3. Aşağıdaki komutu çalıştırın:

```bash
python qdrant_loader.py
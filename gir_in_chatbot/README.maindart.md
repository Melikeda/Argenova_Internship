# Excel Veri Analiz Asistanı – Flutter Uygulaması

**Excel Veri Analiz Asistanı**, kullanıcıların Excel verileri hakkında doğal dilde sorular sorup cevap alabileceği bir Flutter tabanlı chat uygulamasıdır. Backend üzerinden soruları işler ve yanıtları kullanıcıya gösterir.

---

## Özellikler

* **Sohbet Arayüzü**: Kullanıcı ve bot mesajları farklı baloncuklarda gösterilir.
* **Mesaj Kaydı**: `SharedPreferences` ile sohbet geçmişi cihazda saklanır.
* **Yeni Sohbet Başlatma**: Kullanıcı kolayca yeni bir sohbet başlatabilir.
* **Mesaj Silme ve Temizleme**: Sohbetler veya tek tek mesajlar silinebilir.
* **Typing Indicator**: Bot cevap verirken animasyonlu yazıyor göstergesi bulunur.
* **Backend İletişimi**: `http` paketini kullanarak FastAPI veya benzeri bir backend ile iletişim sağlar.
* **Responsive UI**: Farklı ekran boyutlarına uygun tasarım.

---

## Kurulum

1. Flutter ortamını kurun:
   [Flutter Kurulum Rehberi](https://flutter.dev/docs/get-started/install)

2. Projeyi klonlayın:

   ```bash
   git clone <repository-url>
   cd excel-veri-asistan
   ```

3. Paketleri yükleyin:

   ```bash
   flutter pub get
   ```

4. Uygulamayı çalıştırın:

   ```bash
   flutter run
   ```

---

## Kullanım

1. Uygulamayı açın.
2. “Yeni Sohbet” butonuna tıklayın.
3. Mesaj kutusuna Excel verilerinizle ilgili sorularınızı yazın ve gönderin.
4. Bot cevabı ekranda gösterilecektir.
5. Sohbetleri silmek veya temizlemek için uzun basın veya menü seçeneklerini kullanın.

---

## Dosya Yapısı

* `main.dart`: Uygulamanın giriş noktası ve tüm UI mantığı.
* `ChatSession`, `ChatMessage`: Sohbet ve mesaj model sınıfları.
* `SharedPreferences`: Sohbet geçmişinin cihazda saklanması.
* `http`: Backend API ile iletişim.

---

## Backend Ayarları

* Backend URL’si `main.dart` içinde tanımlıdır:

  ```dart
  final Uri backendUri = Uri.parse("http://<backend-ip>:8000/sor");
  ```
* Backend, JSON formatında `{ "soru": "<kullanıcı mesajı>" }` alır ve `{ "cevap": "<bot cevabı>" }` döner.

---

## Özelleştirme

* Tema rengi: `Colors.deepPurple`
* Font: `Roboto`
* Mesaj baloncukları ve avatar ikonları UI üzerinden değiştirilebilir.

---

## Gereksinimler

* Flutter 3.0 veya üzeri
* Dart 3.0 veya üzeri
* İnternet bağlantısı (backend ile iletişim için)

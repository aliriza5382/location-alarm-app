# Konum Alarm Uygulaması

Flutter ile geliştirilen bu mobil uygulama, kullanıcıyı belirli bir konuma yaklaştığında sesli uyarı vererek bilgilendirir. Özellikle toplu taşıma kullanıcıları ve konum bazlı hatırlatma ihtiyacı olanlar için uygundur.

## Temel Özellikler
- Haritadan hedef konum seçme
- Adres girerek koordinat alma (Geocoding)
- Anlık mesafe ölçümü
- Alarm tetikleme (alarm.mp3)
- Otomatik takip modu (her 10 saniyede güncellenir)
- Hedef konumu haritada görüntüleme

## Kullanılan Teknolojiler
- **Flutter (Dart)**
- `geolocator`, `geocoding`, `latlong2` – Konum işlemleri
- `flutter_map` – Harita görüntüleme
- `permission_handler` – Konum izinleri
- `audioplayers` – Alarm sesi çalma

## Önemli Dosyalar
| Dosya                     | Açıklama                                  |
|---------------------------|-------------------------------------------|
| `main.dart`               | Ana ekran ve takip mekanizması            |
| `map_screen.dart`         | Haritadan hedef konum seçme               |
| `map_view_screen.dart`    | Hedefi haritada gösterme ekranı           |
| `assets/sounds/alarm.mp3` | Alarm sesi (assets klasöründe)            |

## Geri Bildirim / İletişim

Her türlü geri bildirim veya öneri için:

E-posta: [sahinaliriza888@gmail.com](mailto:sahinaliriza888@gmail.com)  
GitHub: [github.com/aliriza5382](https://github.com/aliriza5382)

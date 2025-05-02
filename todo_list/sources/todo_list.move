/// Modül: todolist
module todo_list::todo_list;

// === Importlar ===

// String tipini standart kütüphaneden içe aktar
use std::string::String;

// === Structlar ===

/// Yapılacaklar listesindeki tek bir öğeyi temsil eder
/// `title`: görevin açıklaması
/// `completed`: görevin tamamlanıp tamamlanmadığını belirtir
/// 
/// Yetenekler:
/// - `store`: bu türün global storage’da saklanmasına izin verir
/// - `drop`: bu türün gerektiğinde silinmesine izin verir
public struct TodoItem has store, drop {
  title: String,
  completed: bool,
}

/// Tüm yapılacaklar listesi objesini temsil eder
/// `id`: listenin benzersiz kimliği
/// `items`: `TodoItem`'lardan oluşan bir dinamik dizi (vector)
///
/// Yetenekler:
/// - `key`: bu objenin bir kullanıcının hesabında üst seviye kaynak olarak saklanmasını sağlar
public struct TodoList has key {
  id: UID,
  items: vector<TodoItem>,
}

// === Public Fonksiyonlar ===

/// Yeni bir yapılacaklar listesi oluşturur ve zincirde paylaşır
/// `ctx`: yeni obje oluşturmak için gereken işlem bağlamı
public fun new(ctx: &mut TxContext) {
  let list = TodoList {
    id: object::new(ctx),           // Listenin benzersiz ID’sini oluştur
    items: vector::empty(),         // Başlangıçta boş bir görev listesi
  };
  transfer::share_object(list)      // Objeyi zincirde erişilebilir hale getir
}

/// Yapılacaklar listesine yeni bir görev ekler
/// `list`: mevcut TodoList’e mutable referans
/// `item`: eklenecek görevin başlığı
public fun add(list: &mut TodoList, item: String) {
  list.items.push_back(TodoItem {
    title: item,
    completed: false,               // Yeni görev tamamlanmamış olarak başlar
  });
}

/// Belirli bir indeksteki görevi listeden siler
/// `list`: TodoList’e mutable referans
/// `index`: silinecek öğenin listedeki konumu
public fun remove(list: &mut TodoList, index: u64) {
  list.items.remove(index);
}

/// Belirli bir görevin tamamlandığını işaretler
/// `list`: TodoList’e mutable referans
/// `index`: durumu güncellenecek öğenin konumu
public fun update_status(list: &mut TodoList, index: u64) {
  let item = list.items.borrow_mut(index);  // Öğeye mutable erişim al
  item.completed = true;                    // Görevi tamamlanmış olarak işaretle
}

/// Tüm yapılacaklar listesini zincirden siler
/// `list`: silinecek TodoList objesi
public fun delete(list: TodoList) {
  let TodoList { id, items: _ } = list;
  id.delete();  // Objenin kimliği üzerinden silme işlemi yapılır
}

/* 
⚠️ Not: Bu haliyle TodoList objesi herkes tarafından silinebilir.
Gerçek uygulamalarda, sadece objenin sahibi tarafından silinebilmesini sağlamak için object::owner ve tx_context::sender gibi kontroller eklenmelidir.
Ancak bu yazı bir başlangıç rehberi olduğu için, sadelik adına bu tür güvenlik önlemlerini şimdilik dahil etmedik.
Aynı şekilde, diğer fonksiyonlarda da daha gelişmiş kontrol mekanizmaları eklenebilir.
 */
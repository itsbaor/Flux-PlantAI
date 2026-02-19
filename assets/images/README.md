# Assets Images

## Folder Structure

```
assets/images/
├── plants/          # Ảnh các loại cây
│   ├── plant1.jpg
│   ├── plant2.png
│   └── ...
└── backgrounds/     # Ảnh background
    └── leaves_bg.jpg
```

## Cách sử dụng ảnh trong code:

### 1. Hiển thị ảnh từ assets:
```dart
Image.asset(
  'assets/images/plants/plant1.jpg',
  width: 200,
  height: 200,
  fit: BoxFit.cover,
)
```

### 2. Sử dụng làm background:
```dart
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/images/backgrounds/leaves_bg.jpg'),
      fit: BoxFit.cover,
    ),
  ),
)
```

### 3. Với error handling:
```dart
Image.asset(
  'assets/images/plants/plant1.jpg',
  errorBuilder: (context, error, stackTrace) {
    return Icon(Icons.local_florist, size: 60);
  },
)
```

## Lưu ý:
- Sau khi thêm ảnh mới, chạy: `flutter pub get`
- Định dạng hỗ trợ: .jpg, .png, .gif, .webp
- Nên tối ưu kích thước ảnh trước khi thêm vào project

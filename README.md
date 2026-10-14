# Лабораторная работа №4 — PyQt5 + QML Painter

## Задание

Использовать каркас приложения `painter`, в котором backend реализован на PyQt5,
а frontend — на QML.

В классе `Interface` необходимо реализовать сохранение области рисования `Canvas`
**по таймеру в файл на носитель информации**.

## Что реализовано

Исходный painter из шаблона сохранён:

- выбор цвета кисти;
- выбор толщины кисти;
- рисование мышью в `Canvas`.

Добавлено автоматическое сохранение области рисования.

### 1. Таймер в backend

В классе `Interface` создаётся `QTimer`:

```python
self.timer = QTimer(self)
self.timer.setInterval(5000)
self.timer.timeout.connect(self.request_save)
self.timer.start()
```

Каждые 5 секунд backend испускает сигнал:

```python
saveRequested = pyqtSignal()
```

### 2. Передача Canvas из QML в Python

QML получает сигнал `saveRequested` и преобразует текущий `Canvas`
в PNG через:

```qml
var dataUrl = canvas.toDataURL("image/png")
_backend.save_canvas(dataUrl)
```

### 3. Сохранение файла в Interface

Метод `save_canvas()` класса `Interface`:

- получает PNG в Base64;
- декодирует изображение;
- создаёт папку `saved`, если её ещё нет;
- сохраняет изображение с датой и временем в имени.

Пример:

```text
saved/
└── canvas_2026-10-14_21-55-10_123456.png
```

Таким образом логика таймера и запись файла реализованы в backend-классе
`Interface`, а QML используется для получения изображения `Canvas`.

## Структура проекта

```text
gui-lab4-painter/
├── main.py
├── mainWindow.qml
├── Circle.qml
├── Square.qml
├── requirements.txt
├── README.md
└── saved/              # создаётся автоматически после запуска
```

## Установка на Windows

Скачайте репозиторий через **Code → Download ZIP** и распакуйте его.

Перейдите в папку проекта:

```powershell
cd "$HOME\Downloads\gui-lab4-painter-main"
```

Проверьте содержимое:

```powershell
dir
```

В папке должны находиться:

```text
main.py
mainWindow.qml
Circle.qml
Square.qml
requirements.txt
README.md
```

Создайте виртуальное окружение:

```powershell
python -m venv .venv
```

Установите зависимости:

```powershell
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
```

## Запуск

```powershell
.\.venv\Scripts\python.exe main.py
```

## Проверка работы

1. Откройте приложение.
2. Нарисуйте что-нибудь мышью.
3. Подождите не более 5 секунд.
4. В папке проекта автоматически появится каталог:

```text
saved
```

5. В нём появится PNG-файл текущего состояния `Canvas`.
6. Продолжите рисование — каждые 5 секунд будет создаваться новый PNG-файл.

В верхней части окна также отображается статус последнего сохранения.

## Изменение интервала

Интервал задаётся в `main.py`:

```python
AUTOSAVE_INTERVAL_MS = 5000
```

Например, для сохранения каждые 10 секунд:

```python
AUTOSAVE_INTERVAL_MS = 10000
```

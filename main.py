import base64
import sys
from datetime import datetime
from pathlib import Path

from PyQt5.QtCore import QObject, QTimer, QUrl, pyqtSignal, pyqtSlot
from PyQt5.QtQml import QQmlApplicationEngine
from PyQt5.QtWidgets import QApplication


BASE_DIR = Path(__file__).resolve().parent
SAVE_DIR = BASE_DIR / "saved"
AUTOSAVE_INTERVAL_MS = 5000


class Interface(QObject):
    # Python сообщает QML, что пришло время сохранить canvas.
    saveRequested = pyqtSignal()

    # Сигналы результата сохранения.
    saveFinished = pyqtSignal(str)
    saveFailed = pyqtSignal(str)

    def __init__(self):
        super().__init__()

        SAVE_DIR.mkdir(exist_ok=True)

        # Таймер находится именно в backend-классе Interface.
        self.timer = QTimer(self)
        self.timer.setInterval(AUTOSAVE_INTERVAL_MS)
        self.timer.timeout.connect(self.request_save)
        self.timer.start()

    @pyqtSlot()
    def request_save(self):
        """Запрашивает у QML текущее изображение области Canvas."""
        self.saveRequested.emit()

    @pyqtSlot(str)
    def save_canvas(self, data_url):
        """
        Получает Canvas как data:image/png;base64,...,
        декодирует PNG и сохраняет его на диск.
        """
        try:
            prefix = "data:image/png;base64,"
            if not data_url.startswith(prefix):
                raise ValueError("QML передал данные не в формате PNG data URL")

            encoded = data_url[len(prefix):]
            image_bytes = base64.b64decode(encoded, validate=True)

            timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S_%f")
            file_path = SAVE_DIR / f"canvas_{timestamp}.png"
            file_path.write_bytes(image_bytes)

            print(f"Canvas сохранён: {file_path}")
            self.saveFinished.emit(str(file_path))

        except Exception as exc:
            message = f"Ошибка сохранения Canvas: {exc}"
            print(message)
            self.saveFailed.emit(message)


def main():
    app = QApplication(sys.argv)

    interface = Interface()

    engine = QQmlApplicationEngine()
    engine.rootContext().setContextProperty("_backend", interface)

    qml_file = BASE_DIR / "mainWindow.qml"
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        print("Ошибка: не удалось загрузить QML-файл.")
        sys.exit(-1)

    sys.exit(app.exec())


if __name__ == "__main__":
    main()

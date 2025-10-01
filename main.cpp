// Qt includes
#include <QGuiApplication>      // Base class for GUI applications
#include <QQmlApplicationEngine> // Loads and runs QML files
#include <QQmlContext>          // Allows exposing C++ objects to QML

// Our custom model
#include "ContactModel.h"

/**
 * @brief main - Application entry point
 *
 * FLOW:
 * 1. Create Qt application object
 * 2. Register our C++ types so QML can use them
 * 3. Create QML engine and load Main.qml
 * 4. Start the event loop (app.exec())
 *
 * @param argc - Number of command-line arguments
 * @param argv - Array of command-line arguments
 * @return Exit code (0 = success)
 */
int main(int argc, char *argv[])
{
    // STEP 1: Create the application object
    // This initializes Qt's event loop, window system connection, etc.
    // Must be created before any Qt GUI code runs
    QGuiApplication app(argc, argv);

    // STEP 2: Register our C++ type with QML
    // This makes ContactModel available in QML files
    //
    // Parameters:
    // - "ContactApp" = QML module URI (matches CMakeLists.txt)
    // - 1, 0 = Version number (major, minor)
    // - "ContactModel" = Name used in QML (import ContactApp 1.0; ContactModel { })
    //
    // After this, QML can do:
    //   import ContactApp 1.0
    //   ContactModel { id: myModel }
    qmlRegisterType<ContactModel>("ContactApp", 1, 0, "ContactModel");

    // STEP 3: Create the QML engine
    // This is responsible for:
    // - Loading QML files
    // - Instantiating QML objects
    // - Managing the QML runtime
    QQmlApplicationEngine engine;

    // STEP 4: Load the main QML file
    // fromLocalFile() converts a filesystem path to a Qt URL
    // Main.qml is our UI definition (next file)
    //
    // What happens here:
    // 1. Engine reads Main.qml
    // 2. Parses the QML syntax
    // 3. Creates all QML objects (Window, ListView, etc.)
    // 4. Shows the window
    const QUrl url(QStringLiteral("qrc:/ContactApp/Main.qml"));
    engine.load(url);

    // STEP 5: Check if loading succeeded
    // If Main.qml has syntax errors or can't be found, rootObjects() is empty
    if (engine.rootObjects().isEmpty())
        return -1; // Exit with error code

    // STEP 6: Start the event loop
    // This keeps the application running until:
    // - User closes all windows
    // - QGuiApplication::quit() is called
    //
    // The event loop processes:
    // - Mouse/keyboard input
    // - Timers
    // - Network events
    // - Signals/slots
    return app.exec();
}

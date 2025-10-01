#ifndef CONTACTMODEL_H
#define CONTACTMODEL_H

// QAbstractListModel is the base class for all list models in Qt
// It provides the interface between our data and QML views
#include <QAbstractListModel>

// QString is Qt's string class (better than std::string for Qt apps)
#include <QString>

// QVector is Qt's dynamic array (like std::vector)
#include <QVector>

/**
 * @brief ContactModel - A simple model that stores contact information
 *
 * This class inherits from QAbstractListModel, which means:
 * 1. It can be used with ListView, GridView, Repeater in QML
 * 2. It provides data through a "role-based" system
 * 3. It automatically notifies views when data changes
 *
 * Think of this as a "smart container" that:
 * - Stores data (like a database table)
 * - Tells QML "hey, I have X rows"
 * - Provides data when QML asks "what's in row 3?"
 * - Updates views when data changes
 */
class ContactModel : public QAbstractListModel
{
    // Q_OBJECT macro is REQUIRED for:
    // - Signals and slots to work
    // - Q_PROPERTY to work (exposes properties to QML)
    // - qmlRegisterType to work (makes class available in QML)
    Q_OBJECT

    // Q_PROPERTY exposes C++ properties to QML
    // Syntax: Q_PROPERTY(type name READ getter NOTIFY signal)
    // This means QML can do: contactModel.count
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    /**
     * @brief Roles - These are the "column names" for our data
     *
     * In Model-View, data is accessed through "roles" (not direct properties).
     * Each role is an integer ID that maps to a piece of data.
     *
     * Qt has built-in roles (Qt::DisplayRole, Qt::EditRole, etc.)
     * We create custom roles starting from Qt::UserRole + 1
     *
     * Example: If QML asks for row 0 with NameRole, we return "Alice"
     */
    enum Roles {
        NameRole = Qt::UserRole + 1,  // Start after Qt's built-in roles
        PhoneRole,                      // Each role gets the next integer
        EmailRole
    };

    /**
     * @brief Constructor
     * @param parent - Qt's parent-child memory management system
     *
     * When you pass a parent, Qt automatically deletes this object
     * when the parent is deleted (prevents memory leaks)
     */
    explicit ContactModel(QObject *parent = nullptr);

    // ========== REQUIRED OVERRIDES FROM QAbstractListModel ==========

    /**
     * @brief rowCount - How many rows does this model have?
     *
     * This is called by QML views to know how many items to display.
     * For example, if this returns 5, ListView will create 5 delegates.
     *
     * @param parent - Used for tree models (ignore for lists)
     * @return Number of items in the model
     *
     * WHY IT'S CALLED:
     * - When ListView/GridView is created
     * - After we call beginInsertRows/endInsertRows
     * - After we call beginRemoveRows/endRemoveRows
     */
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;

    /**
     * @brief data - What data should be displayed for this row/role?
     *
     * This is the CORE method. QML calls this constantly:
     * "Hey model, I need row 2 with role NameRole, what's the value?"
     *
     * @param index - Contains the row number (index.row())
     * @param role - Which piece of data? (NameRole, PhoneRole, etc.)
     * @return The data as QVariant (Qt's type-safe union)
     *
     * WHY IT'S CALLED:
     * - When a delegate becomes visible (scrolling)
     * - When we emit dataChanged()
     * - When QML bindings reference model properties
     *
     * PERFORMANCE NOTE:
     * This method is called VERY frequently. Keep it fast!
     */
    QVariant data(const QModelIndex &index, int role) const override;

    /**
     * @brief roleNames - Maps role integers to QML property names
     *
     * This tells QML: "When you see NameRole (256), call it 'name' in QML"
     *
     * In QML delegate, you can then do:
     *   Text { text: name }  // 'name' comes from this mapping
     *
     * @return Hash map of role ID -> property name
     *
     * WHY IT'S CALLED:
     * - Once when model is first used
     * - QML uses this to enable property access in delegates
     */
    QHash<int, QByteArray> roleNames() const override;

    // ========== CUSTOM API FOR QML ==========

    /**
     * @brief addContact - Add a new contact to the model
     *
     * Q_INVOKABLE makes this callable from QML:
     *   contactModel.addContact("Alice", "555-1234", "alice@example.com")
     *
     * @param name - Contact's name
     * @param phone - Contact's phone number
     * @param email - Contact's email address
     *
     * IMPORTANT: We must call beginInsertRows() BEFORE adding data
     * and endInsertRows() AFTER. This notifies views to update.
     */
    Q_INVOKABLE void addContact(const QString &name,
                                const QString &phone,
                                const QString &email);

    /**
     * @brief removeContact - Remove a contact by index
     *
     * @param index - Row number to remove (0-based)
     *
     * IMPORTANT: We must call beginRemoveRows() BEFORE removing data
     * and endRemoveRows() AFTER.
     */
    Q_INVOKABLE void removeContact(int index);

    /**
     * @brief clear - Remove all contacts
     *
     * beginResetModel() / endResetModel() is efficient for bulk changes
     */
    Q_INVOKABLE void clear();

signals:
    /**
     * @brief countChanged - Emitted when the number of contacts changes
     *
     * QML can connect to this signal or bind to the 'count' property:
     *   Text { text: contactModel.count }  // Auto-updates when signal fires
     */
    void countChanged();

private:
    /**
     * @brief Contact - Our data structure (a "record" or "row")
     *
     * This is a simple struct to hold one contact's information.
     * Think of it like one row in a database table.
     */
    struct Contact {
        QString name;
        QString phone;
        QString email;
    };

    /**
     * @brief m_contacts - The actual data storage
     *
     * This is our "database" - just a simple dynamic array.
     * In a real app, this might be a SQL database, JSON file, etc.
     *
     * QVector is Qt's version of std::vector
     */
    QVector<Contact> m_contacts;
};

#endif // CONTACTMODEL_H

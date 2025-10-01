#include "ContactModel.h"

/**
 * @brief Constructor - Initialize the model
 *
 * The : QAbstractListModel(parent) part calls the parent class constructor.
 * This is required for Qt's parent-child memory management.
 */
ContactModel::ContactModel(QObject *parent)
    : QAbstractListModel(parent)
{
    // Optionally, we could pre-populate with test data here:
    // m_contacts.append({"Alice", "555-1234", "alice@example.com"});
    // m_contacts.append({"Bob", "555-5678", "bob@example.com"});

    // For this example, we'll start with an empty list
}

/**
 * @brief rowCount - Return the number of items in the model
 *
 * STEP-BY-STEP FLOW:
 * 1. QML creates a ListView with model: contactModel
 * 2. ListView immediately calls contactModel.rowCount()
 * 3. We return m_contacts.count() (e.g., 0 if empty, 5 if 5 contacts)
 * 4. ListView now knows to create 0/5 delegate instances
 *
 * @param parent - For tree models (parent items). Lists always return 0 for invalid parent.
 * @return Number of contacts
 */
int ContactModel::rowCount(const QModelIndex &parent) const
{
    // Tree models have parent items. For lists, we only count top-level items.
    // If parent.isValid() == true, that means someone is asking "how many children
    // does row X have?" For lists, the answer is always 0 (lists have no children).
    if (parent.isValid())
        return 0;

    // Return the number of contacts we're storing
    return m_contacts.count();
}

/**
 * @brief data - Return data for a specific row and role
 *
 * STEP-BY-STEP FLOW:
 * 1. ListView creates a delegate for row 2
 * 2. Delegate has: Text { text: name }
 * 3. QML calls contactModel.data(index=2, role=NameRole)
 * 4. We look up m_contacts[2].name and return it
 * 5. Text displays "Charlie" (or whatever the name is)
 *
 * This is called MANY times:
 * - Once per role per visible delegate
 * - When scrolling (new delegates appear)
 * - After dataChanged() is emitted
 *
 * @param index - Contains the row number (0-based)
 * @param role - Which property to return (NameRole, PhoneRole, EmailRole)
 * @return The data wrapped in QVariant (Qt's type-safe union)
 */
QVariant ContactModel::data(const QModelIndex &index, int role) const
{
    // VALIDATION: Check if the requested row is valid
    // Example: If we have 5 contacts (rows 0-4) and someone asks for row 7,
    // we return an invalid QVariant() instead of crashing
    if (!index.isValid() || index.row() >= m_contacts.count()) {
        return QVariant(); // Invalid/empty value
    }

    // Get the contact for this row
    // Example: If index.row() == 2, we get m_contacts[2]
    const Contact &contact = m_contacts.at(index.row());

    // Return the appropriate field based on the role
    // The 'role' tells us which property QML wants
    switch (role) {
    case NameRole:
        // QML asked for 'name', return the name string
        return contact.name;

    case PhoneRole:
        // QML asked for 'phone', return the phone string
        return contact.phone;

    case EmailRole:
        // QML asked for 'email', return the email string
        return contact.email;

    default:
        // Unknown role (shouldn't happen), return empty
        return QVariant();
    }
}

/**
 * @brief roleNames - Map role integers to QML property names
 *
 * STEP-BY-STEP FLOW:
 * 1. QML sees: ListView { model: contactModel; delegate: Text { text: name } }
 * 2. QML asks model: "What does 'name' mean?"
 * 3. We return { 256 -> "name", 257 -> "phone", 258 -> "email" }
 * 4. QML now knows: When delegate says 'name', call data() with role=256
 *
 * This is called ONCE when the model is first used.
 *
 * @return HashMap of role ID -> QML property name
 */
QHash<int, QByteArray> ContactModel::roleNames() const
{
    QHash<int, QByteArray> roles;

    // Map each enum value to a QML-friendly name
    // The key (NameRole) is the integer ID
    // The value ("name") is what QML sees in delegates
    roles[NameRole] = "name";      // QML can use: Text { text: name }
    roles[PhoneRole] = "phone";    // QML can use: Text { text: phone }
    roles[EmailRole] = "email";    // QML can use: Text { text: email }

    return roles;
}

/**
 * @brief addContact - Add a new contact to the model
 *
 * CRITICAL SEQUENCE (must follow this order):
 * 1. Call beginInsertRows() - Tells views "I'm about to add rows"
 * 2. Modify the data (append to m_contacts)
 * 3. Call endInsertRows() - Views automatically update
 * 4. Emit countChanged() - Updates count property bindings
 *
 * WHY THIS ORDER MATTERS:
 * If you modify data BEFORE beginInsertRows(), views will crash or show stale data.
 *
 * @param name - Contact name
 * @param phone - Contact phone
 * @param email - Contact email
 *
 * EXAMPLE USAGE FROM QML:
 *   Button {
 *       text: "Add Contact"
 *       onClicked: contactModel.addContact("Alice", "555-1234", "alice@example.com")
 *   }
 */
void ContactModel::addContact(const QString &name,
                              const QString &phone,
                              const QString &email)
{
    // Calculate where the new row will be inserted
    // Since we're appending, it's at index m_contacts.count()
    // Example: If we have 3 contacts (indices 0,1,2), new one goes at index 3
    int newRow = m_contacts.count();

    // STEP 1: Tell views "I'm about to insert 1 row at position 'newRow'"
    // Parameters: (parent, firstRow, lastRow)
    // For lists, parent is always QModelIndex() (invalid/root)
    // firstRow and lastRow are the same when inserting 1 item
    beginInsertRows(QModelIndex(), newRow, newRow);

    // STEP 2: Actually add the data to our storage
    // Create a new Contact struct and append it to the vector
    Contact newContact;
    newContact.name = name;
    newContact.phone = phone;
    newContact.email = email;
    m_contacts.append(newContact);

    // STEP 3: Tell views "I'm done inserting, you can update now"
    // After this call:
    // - ListView automatically creates a new delegate
    // - rowCount() will return the new count
    // - data() can be called for the new row
    endInsertRows();

    // STEP 4: Notify QML that the count property changed
    // This updates any bindings like: Text { text: "Total: " + contactModel.count }
    emit countChanged();
}

/**
 * @brief removeContact - Remove a contact at the given index
 *
 * CRITICAL SEQUENCE:
 * 1. Validate index
 * 2. Call beginRemoveRows()
 * 3. Remove from m_contacts
 * 4. Call endRemoveRows()
 * 5. Emit countChanged()
 *
 * @param index - Row number to remove (0-based)
 *
 * EXAMPLE USAGE FROM QML:
 *   Button {
 *       text: "Delete"
 *       onClicked: contactModel.removeContact(2)  // Remove 3rd item
 *   }
 */
void ContactModel::removeContact(int index)
{
    // VALIDATION: Make sure the index is in valid range
    // Example: If we have 5 contacts (0-4) and someone tries to remove index 7,
    // we do nothing instead of crashing
    if (index < 0 || index >= m_contacts.count()) {
        return; // Invalid index, do nothing
    }

    // STEP 1: Tell views "I'm about to remove row at 'index'"
    beginRemoveRows(QModelIndex(), index, index);

    // STEP 2: Actually remove the data from storage
    m_contacts.removeAt(index);

    // STEP 3: Tell views "I'm done removing, update yourselves"
    // After this:
    // - ListView destroys the delegate for this row
    // - Remaining delegates shift up
    // - rowCount() returns the new count
    endRemoveRows();

    // STEP 4: Update count property
    emit countChanged();
}

/**
 * @brief clear - Remove all contacts at once
 *
 * For bulk operations (clearing everything), beginResetModel() / endResetModel()
 * is more efficient than removing one-by-one.
 *
 * SEQUENCE:
 * 1. beginResetModel() - "Everything is changing, wait"
 * 2. Clear the data
 * 3. endResetModel() - "Done, rebuild everything"
 *
 * This causes views to:
 * - Destroy all delegates
 * - Call rowCount() again
 * - Recreate delegates if rowCount() > 0
 */
void ContactModel::clear()
{
    // Early return if already empty (optimization)
    if (m_contacts.isEmpty())
        return;

    // STEP 1: Tell views "I'm about to reset the entire model"
    beginResetModel();

    // STEP 2: Clear all data
    m_contacts.clear();

    // STEP 3: Tell views "Done resetting, rebuild from scratch"
    endResetModel();

    // STEP 4: Update count property
    emit countChanged();
}

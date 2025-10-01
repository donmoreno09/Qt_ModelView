┌─────────────────────────────────────────────────────────────────┐
│                         USER INTERACTION                        │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                │ 1. User clicks "Add Contact"
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                              QML                                │
│  Button.onClicked: contactModel.addContact("Alice", ...)       │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                │ 2. QML calls C++ method
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                        C++ MODEL (ContactModel)                 │
│                                                                 │
│  void addContact(name, phone, email) {                         │
│    beginInsertRows(parent, row, row);  ← 3. Tell views         │
│    m_contacts.append({name, phone, email});  ← 4. Add data     │
│    endInsertRows();  ← 5. Views auto-update                    │
│    emit countChanged();  ← 6. Update count property            │
│  }                                                              │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                │ 7. endInsertRows() triggers
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                         ListView (QML)                          │
│                                                                 │
│  - Calls rowCount() → Returns 4 (was 3, now 4)                │
│  - Creates new delegate for row 3                              │
│  - Delegate needs to display model.name                        │
│  - Calls data(index=3, role=NameRole)                         │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                │ 8. ListView calls data()
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                        C++ MODEL (ContactModel)                 │
│                                                                 │
│  QVariant data(index, role) {                                  │
│    if (role == NameRole)                                       │
│      return m_contacts[index.row()].name;  ← 9. Return "Alice"│
│  }                                                              │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                │ 10. Return value
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                         ListView Delegate                       │
│                                                                 │
│  Text { text: model.name }  ← 11. Displays "Alice"            │
└───────────────────────────────┬─────────────────────────────────┘
                                │
                                │ 12. Render on screen
                                ↓
┌─────────────────────────────────────────────────────────────────┐
│                           SCREEN                                │
│  ┌──────────────────────────────────────────┐                 │
│  │ Contacts (4)                              │                 │
│  │ [Name] [Phone] [Email] [Add Contact]     │                 │
│  │ ────────────────────────────────────────  │                 │
│  │ Alice Johnson                    [🗑️]     │                 │
│  │ 📞 555-1234                               │                 │
│  │ ✉️ alice@example.com                      │                 │
│  └──────────────────────────────────────────┘                 │
└─────────────────────────────────────────────────────────────────┘

Key Concepts Summary
1. The Three-Method Contract
Every model MUST implement:
cpp// How many rows?
int rowCount(const QModelIndex &parent) const override;

// What data for this row/role?
QVariant data(const QModelIndex &index, int role) const override;

// Map roles to QML property names
QHash<int, QByteArray> roleNames() const override;
2. The Insert/Remove Protocol
Always follow this sequence:
cpp// INSERTING:
beginInsertRows(parent, first, last);  // 1. Announce
m_data.insert(...);                    // 2. Modify data
endInsertRows();                       // 3. Views update

// REMOVING:
beginRemoveRows(parent, first, last);  // 1. Announce
m_data.remove(...);                    // 2. Modify data
endRemoveRows();                       // 3. Views update

// BULK CHANGES:
beginResetModel();                     // 1. Announce
m_data.clear();                        // 2. Modify data
endResetModel();                       // 3. Views rebuild
3. Role-Based Access
cpp// C++ side:
enum Roles { NameRole = Qt::UserRole + 1, PhoneRole, EmailRole };
roles[NameRole] = "name";  // Map 256 → "name"

// QML side:
Text { text: model.name }  // Translated to data(index, 256)
4. Automatic Updates
When you call:

endInsertRows() → ListView creates new delegate
endRemoveRows() → ListView destroys delegate
emit dataChanged() → ListView updates existing delegates
emit countChanged() → QML property bindings update

5. Virtualization
ListView only creates delegates for visible items:
1000 contacts in model
↓
Only 10 visible on screen
↓
Only ~12 delegates created (10 visible + 2 buffer)
↓
Memory efficient!

What Happens When You Scroll?
User scrolls down
↓
Row 0 delegate moves off screen
↓
ListView RECYCLES that delegate for row 10
↓
Calls data(index=10, role=NameRole)
↓
Updates Text { text: model.name } to new value
↓
Delegate now shows row 10 data

Common Mistakes to Avoid
❌ Wrong: Modifying data without begin/end
cppvoid addContact(...) {
    m_contacts.append(...);  // CRASH! Views don't know
}
✅ Right: Always use begin/end
cppvoid addContact(...) {
    beginInsertRows(...);
    m_contacts.append(...);
    endInsertRows();  // Views update safely
}
❌ Wrong: Returning raw pointers
cppQVariant data(...) {
    return &m_contacts[index];  // DON'T! Memory issues
}
✅ Right: Return by value
cppQVariant data(...) {
    return m_contacts[index].name;  // QVariant copies it safely
}
❌ Wrong: Forgetting roleNames()
cpp// If you don't implement roleNames()
// QML can't use: model.name
// You'd have to use: model.display (Qt's default role)

This example demonstrates the complete cycle of Model-View architecture in Qt Quick. Every line is explained in detail to show why it exists and what happens at runtime.

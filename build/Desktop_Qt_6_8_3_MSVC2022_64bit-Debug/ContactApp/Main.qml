// Import Qt Quick module (provides Window, Rectangle, Text, etc.)
import QtQuick 6.8

// Import Qt Quick Controls (provides Button, TextField, ListView, etc.)
import QtQuick.Controls 6.8

// Import Qt Quick Layouts (provides ColumnLayout, RowLayout, etc.)
import QtQuick.Layouts 6.8

// Import our C++ module (registered in main.cpp)
import ContactApp 1.0

/**
 * ApplicationWindow - The main window of the application
 *
 * This is the root element. Everything else is a child of this window.
 */
ApplicationWindow {
    // Window properties
    width: 400              // Initial window width in pixels
    height: 600             // Initial window height in pixels
    visible: true           // Make window visible immediately
    title: "Contact List"  // Window title bar text

    // ========== THE MODEL ==========
    /**
     * ContactModel - Our C++ model instance
     *
     * WHAT HAPPENS HERE:
     * 1. QML sees "ContactModel" and looks for a registered type with that name
     * 2. Finds our qmlRegisterType<ContactModel>() from main.cpp
     * 3. Creates a NEW instance of ContactModel (calls ContactModel constructor)
     * 4. Assigns it ID "contactModel" so other QML elements can reference it
     *
     * Now we can do:
     * - contactModel.addContact(...)
     * - contactModel.count
     * - model: contactModel (in ListView)
     */
    ContactModel {
        id: contactModel

        // Optional: Initialize with test data
        Component.onCompleted: {
            // Component.onCompleted runs after this object is fully created
            // We can add some sample contacts here

            contactModel.addContact("Alice Johnson", "555-1234", "alice@example.com")
            contactModel.addContact("Bob Smith", "555-5678", "bob@example.com")
            contactModel.addContact("Charlie Brown", "555-9012", "charlie@example.com")
        }
    }

    // ========== THE UI ==========
    /**
     * ColumnLayout - Arranges children vertically
     *
     * Children are stacked from top to bottom:
     * 1. Title text
     * 2. Input form (another RowLayout)
     * 3. Add button
     * 4. List of contacts (ListView)
     */
    ColumnLayout {
        // Make this layout fill the entire window
        anchors.fill: parent

        // Margin around the edges (10 pixels of padding)
        anchors.margins: 10

        // Vertical space between children (10 pixels)
        spacing: 10

        // ===== HEADER =====
        /**
         * Text - Display the title and contact count
         *
         * BINDING MAGIC:
         * contactModel.count is a Q_PROPERTY from our C++ code.
         * When we call emit countChanged(), QML automatically re-evaluates
         * this text binding and updates the UI.
         *
         * Example: "Contacts (0)" → user adds contact → "Contacts (1)"
         */
        Text {
            text: "Contacts (" + contactModel.count + ")"

            // Font styling
            font.pixelSize: 24    // Large text
            font.bold: true       // Bold weight

            // Make this text take full width of the ColumnLayout
            Layout.fillWidth: true

            // Center the text horizontally
            horizontalAlignment: Text.AlignHCenter
        }

        // ===== INPUT FORM =====
        /**
         * RowLayout - Horizontal arrangement of input fields
         *
         * Contains three text fields side-by-side for entering contact info
         */
        RowLayout {
            // Take full width of parent ColumnLayout
            Layout.fillWidth: true

            // Horizontal spacing between text fields
            spacing: 5

            /**
             * TextField - Input for name
             *
             * TextField is from QtQuick.Controls
             * It provides:
             * - Text input
             * - Cursor
             * - Selection
             * - Placeholder text
             * - Focus handling
             */
            TextField {
                id: nameField  // Give it an ID so we can reference it later

                // Placeholder text (shown when empty)
                placeholderText: "Name"

                // Make this field expand to fill available space
                // All three fields have this, so they share space equally
                Layout.fillWidth: true
            }

            TextField {
                id: phoneField
                placeholderText: "Phone"
                Layout.fillWidth: true
            }

            TextField {
                id: emailField
                placeholderText: "Email"
                Layout.fillWidth: true
            }
        }

        // ===== ADD BUTTON =====
        /**
         * Button - Adds a new contact
         *
         * When clicked:
         * 1. Reads text from the three TextFields
         * 2. Calls C++ method contactModel.addContact()
         * 3. C++ adds the contact and emits countChanged()
         * 4. ListView automatically shows the new item
         * 5. Clears the input fields
         */
        Button {
            text: "Add Contact"

            // Center the button horizontally
            Layout.alignment: Qt.AlignHCenter

            /**
             * onClicked - Event handler for button clicks
             *
             * This is a JavaScript function that runs when the button is clicked.
             * It's one of the most important parts of QML - connecting UI to logic.
             */
            onClicked: {
                // Only add if name is not empty (basic validation)
                if (nameField.text.trim() !== "") {
                    // CALL OUR C++ METHOD
                    // This triggers ContactModel::addContact() in C++
                    // The C++ code:
                    // 1. Calls beginInsertRows()
                    // 2. Appends to m_contacts
                    // 3. Calls endInsertRows()
                    // 4. Emits countChanged()
                    contactModel.addContact(
                        nameField.text,   // Pass name
                        phoneField.text,  // Pass phone
                        emailField.text   // Pass email
                    )

                    // Clear the input fields after adding
                    nameField.text = ""
                    phoneField.text = ""
                    emailField.text = ""

                    // Give focus back to name field for quick next entry
                    nameField.forceActiveFocus()
                }
            }
        }

        // ===== CONTACT LIST =====
        /**
         * ListView - The star of Model-View architecture!
         *
         * This is where the magic happens:
         * 1. ListView asks model: "How many rows?" (calls rowCount())
         * 2. For each visible row, ListView creates a delegate
         * 3. Each delegate asks model: "What's the data?" (calls data())
         * 4. ListView handles scrolling, virtualization, animations
         *
         * VIRTUALIZATION:
         * ListView only creates delegates for VISIBLE items.
         * If you have 1000 contacts but window shows 10, only 10-15 delegates
         * are created. As you scroll, delegates are recycled.
         * This makes it memory-efficient for large datasets.
         */
        ListView {
            // Make ListView take all remaining vertical space
            // (after header, input form, and button)
            Layout.fillWidth: true
            Layout.fillHeight: true

            // Vertical space between list items (5 pixels)
            spacing: 5

            // Enable clipping (hide items outside bounds)
            // Required for smooth scrolling
            clip: true

            // ===== CONNECT TO MODEL =====
            /**
             * model - THE CONNECTION TO C++
             *
             * By setting model: contactModel, we're telling ListView:
             * "Use contactModel (our C++ ContactModel instance) as your data source"
             *
             * ListView will now:
             * - Call contactModel.rowCount() to know how many items
             * - Call contactModel.data(index, role) to get data for each item
             * - Watch for model signals (countChanged, dataChanged, etc.)
             */
            model: contactModel

            // ===== DELEGATE - THE TEMPLATE FOR ONE ITEM =====
            /**
             * delegate - Defines HOW each contact looks
             *
             * This Component is INSTANTIATED ONCE PER VISIBLE ROW.
             *
             * CONTEXT PROPERTIES INJECTED BY LISTVIEW:
             * ListView automatically injects properties into each delegate:
             * - index: Row number (0, 1, 2, ...)
             * - model.name: Data from NameRole
             * - model.phone: Data from PhoneRole
             * - model.email: Data from EmailRole
             *
             * These come from our roleNames() implementation:
             * roles[NameRole] = "name"  → accessible as model.name
             *
             * HOW IT WORKS:
             * 1. ListView creates delegate for row 0
             * 2. Delegate needs to display model.name
             * 3. ListView calls contactModel.data(index=0, role=NameRole)
             * 4. C++ returns m_contacts[0].name = "Alice Johnson"
             * 5. Text element displays "Alice Johnson"
             */
            delegate: Rectangle {
                // IMPLICIT PROPERTIES AVAILABLE HERE:
                // - index: Row number (0-based)
                // - model.name: From NameRole
                // - model.phone: From PhoneRole
                // - model.email: From EmailRole

                // Size of each list item
                width: ListView.view.width  // Match ListView width
                height: 80                  // Fixed height per item

                                // Alternating background colors for better readability
                                // index is provided by ListView (0, 1, 2, ...)
                                // Even rows (0, 2, 4) get light gray, odd rows (1, 3, 5) get white
                                color: index % 2 === 0 ? "#f0f0f0" : "#ffffff"

                                // Rounded corners
                                radius: 5

                                // Subtle border
                                border.color: "#cccccc"
                                border.width: 1

                                // ===== CONTENT LAYOUT =====
                                /**
                                 * RowLayout - Arrange contact info horizontally
                                 *
                                 * Layout: [Name/Phone/Email]  [Delete Button]
                                 */
                                RowLayout {
                                    // Fill the entire Rectangle
                                    anchors.fill: parent

                                    // Padding inside the rectangle
                                    anchors.margins: 10

                                    // Space between columns
                                    spacing: 10

                                    // ===== LEFT SIDE: CONTACT INFO =====
                                    /**
                                     * ColumnLayout - Stack contact details vertically
                                     *
                                     * Shows:
                                     * - Name (bold, larger)
                                     * - Phone (gray)
                                     * - Email (gray)
                                     */
                                    ColumnLayout {
                                        // Take all available horizontal space
                                        // (pushing the delete button to the right)
                                        Layout.fillWidth: true

                                        // Vertical spacing between text lines
                                        spacing: 2

                                        /**
                                         * Text - Display contact name
                                         *
                                         * CRITICAL BINDING:
                                         * model.name comes from our C++ roleNames() mapping.
                                         *
                                         * FLOW:
                                         * 1. QML sees "model.name"
                                         * 2. Looks up roleNames() → finds NameRole (256) maps to "name"
                                         * 3. Calls contactModel.data(index=thisRow, role=256)
                                         * 4. C++ returns m_contacts[thisRow].name
                                         * 5. Text displays it
                                         *
                                         * If C++ emits dataChanged() for this row, QML automatically
                                         * re-evaluates this binding and updates the display.
                                         */
                                        Text {
                                            text: model.name        // From NameRole
                                            font.pixelSize: 16      // Larger text
                                            font.bold: true         // Bold name
                                            color: "#333333"        // Dark gray
                                        }

                                        /**
                                         * Text - Display phone number
                                         *
                                         * Same mechanism as name, but uses PhoneRole
                                         */
                                        Text {
                                            text: "📞 " + model.phone  // From PhoneRole
                                            font.pixelSize: 14
                                            color: "#666666"        // Medium gray
                                        }

                                        /**
                                         * Text - Display email
                                         *
                                         * Same mechanism as name, but uses EmailRole
                                         */
                                        Text {
                                            text: "✉️ " + model.email  // From EmailRole
                                            font.pixelSize: 14
                                            color: "#666666"        // Medium gray
                                        }
                                    }

                                    // ===== RIGHT SIDE: DELETE BUTTON =====
                                    /**
                                     * Button - Delete this contact
                                     *
                                     * When clicked:
                                     * 1. Calls contactModel.removeContact(index)
                                     * 2. C++ calls beginRemoveRows()
                                     * 3. C++ removes from m_contacts
                                     * 4. C++ calls endRemoveRows()
                                     * 5. ListView automatically removes this delegate
                                     * 6. ListView shifts remaining items up
                                     */
                                    Button {
                                        text: "🗑️"  // Trash can emoji

                                        // Make button narrower (just icon)
                                        Layout.preferredWidth: 50

                                        // Match parent height
                                        Layout.fillHeight: true

                                        /**
                                         * onClicked - Delete button handler
                                         *
                                         * CRITICAL: We use 'index' which is provided by ListView.
                                         * 'index' is the row number of THIS delegate.
                                         *
                                         * Example: If this is the 3rd item, index = 2
                                         */
                                        onClicked: {
                                            // CALL C++ REMOVE METHOD
                                            // This triggers ContactModel::removeContact(index)
                                            contactModel.removeContact(index)

                                            // No need to manually update UI!
                                            // ListView automatically handles:
                                            // - Destroying this delegate
                                            // - Shifting remaining items up
                                            // - Updating scroll position
                                        }
                                    }
                                }

                                // ===== HOVER EFFECT =====
                                /**
                                 * MouseArea - Add hover highlighting
                                 *
                                 * This is OPTIONAL - just makes the UI feel more responsive.
                                 * When mouse hovers over an item, it gets lighter.
                                 */
                                MouseArea {
                                    // Cover the entire delegate
                                    anchors.fill: parent

                                    // Enable hover detection
                                    hoverEnabled: true

                                    // Don't block click events (let delete button work)
                                    propagateComposedEvents: true

                                    /**
                                     * onEntered - Mouse entered this item
                                     *
                                     * Lighten the background color slightly
                                     */
                                    onEntered: {
                                        parent.color = Qt.lighter(parent.color, 1.1)
                                    }

                                    /**
                                     * onExited - Mouse left this item
                                     *
                                     * Restore original background color
                                     */
                                    onExited: {
                                        // Restore alternating color
                                        parent.color = index % 2 === 0 ? "#f0f0f0" : "#ffffff"
                                    }
                                }
                            } // End of delegate

                            // ===== EMPTY STATE =====
                            /**
                             * Text - Shown when list is empty
                             *
                             * This is a child of ListView but NOT part of the model-view system.
                             * It's just a static element that appears when count === 0.
                             */
                            Text {
                                // Only visible when no contacts
                                visible: contactModel.count === 0

                                text: "No contacts yet.\nAdd one above!"

                                // Center in the ListView
                                anchors.centerIn: parent

                                // Text styling
                                font.pixelSize: 16
                                color: "#999999"
                                horizontalAlignment: Text.AlignHCenter
                            }

                            // ===== SCROLL INDICATORS =====
                            /**
                             * ScrollBar - Visual scroll indicator
                             *
                             * Shows a scrollbar on the right side when content overflows.
                             * This is SEPARATE from the scrolling mechanism - ListView handles
                             * scrolling automatically. This just shows WHERE you are.
                             */
                            ScrollBar.vertical: ScrollBar {
                                // Only show when actually needed
                                policy: ScrollBar.AsNeeded
                            }
                        } // End of ListView

                        // ===== FOOTER BUTTONS =====
                        /**
                         * RowLayout - Action buttons at the bottom
                         */
                        RowLayout {
                            // Center horizontally
                            Layout.alignment: Qt.AlignHCenter

                            spacing: 10

                            /**
                             * Button - Clear all contacts
                             *
                             * Calls contactModel.clear() which:
                             * 1. Calls beginResetModel()
                             * 2. Clears m_contacts
                             * 3. Calls endResetModel()
                             * 4. ListView destroys all delegates and rebuilds from scratch
                             */
                            Button {
                                text: "Clear All"

                                onClicked: {
                                    // CALL C++ CLEAR METHOD
                                    contactModel.clear()

                                    // ListView automatically:
                                    // - Destroys all delegates
                                    // - Shows empty state
                                }
                            }

                            /**
                             * Button - Add sample data
                             *
                             * Demonstrates that you can add multiple items programmatically
                             */
                            Button {
                                text: "Add Sample Data"

                                onClicked: {
                                    // Add several contacts at once
                                    // Each call triggers beginInsertRows/endInsertRows
                                    // ListView efficiently updates after each insertion
                                    contactModel.addContact("David Miller", "555-1111", "david@example.com")
                                    contactModel.addContact("Emma Wilson", "555-2222", "emma@example.com")
                                    contactModel.addContact("Frank Lee", "555-3333", "frank@example.com")
                                }
                            }
                        }
                    } // End of ColumnLayout
                } // End of ApplicationWindow

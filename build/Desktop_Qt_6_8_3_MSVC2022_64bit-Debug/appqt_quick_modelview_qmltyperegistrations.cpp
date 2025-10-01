/****************************************************************************
** Generated QML type registration code
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <QtQml/qqml.h>
#include <QtQml/qqmlmoduleregistration.h>

#if __has_include(<ToDoModel.h>)
#  include <ToDoModel.h>
#endif


#if !defined(QT_STATIC)
#define Q_QMLTYPE_EXPORT Q_DECL_EXPORT
#else
#define Q_QMLTYPE_EXPORT
#endif
Q_QMLTYPE_EXPORT void qml_register_types_QT_Quick_ModelView()
{
    QT_WARNING_PUSH QT_WARNING_DISABLE_DEPRECATED
    qmlRegisterTypesAndRevisions<ToDoModel>("QT_Quick_ModelView", 1);
    qmlRegisterAnonymousType<QAbstractItemModel, 254>("QT_Quick_ModelView", 1);
    QT_WARNING_POP
    qmlRegisterModule("QT_Quick_ModelView", 1, 0);
}

static const QQmlModuleRegistration qTQuickModelViewRegistration("QT_Quick_ModelView", qml_register_types_QT_Quick_ModelView);

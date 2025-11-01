#ifndef FAVORITEMANAGER_H
#define FAVORITEMANAGER_H

#include <QObject>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QJsonDocument>
#include <Qtsql/QSqlDatabase>
#include <Qtsql/QSqlQuery>
#include <Qtsql/QSqlError>
#include <QVariant>
#include <QDateTime>
#include <QVariantList>
#include <QVariantMap>

class FavoriteManager: public QObject {
    Q_OBJECT
    Q_PROPERTY(QVariantList data READ data WRITE refreshData NOTIFY dataChanged FINAL)
    Q_PROPERTY(QString databasePath READ databasePath WRITE setDatabasePath NOTIFY databasePathChanged FINAL)
public:
    explicit FavoriteManager(QObject* parent = nullptr);
    ~FavoriteManager();
    //Q_INVOKABLE 将类的成员函数注册到qt元对象系统，让函数具备“可被元对象系统识别和调用的能力”，用于QML与c++交互，无元对象系统支持时，QML无法调用
    // Q_INVOKABLE void append(const QJsonObject& obj);
    Q_INVOKABLE void append(const QVariantMap & obj);
    Q_INVOKABLE void remove(const QString& id);
    Q_INVOKABLE int indexOf(const QString& findId);
    Q_INVOKABLE QVariantMap get(int index)const;
    // Q_INVOKABLE void clearAll();

    Q_INVOKABLE QVariantList data()const;
    // void refreshData(const QJsonArray& newData);
    void refreshData(const QVariantList& newData);
    QString databasePath()const;
    void setDatabasePath(const QString &newDatabasePath);

private:

    bool initializeDatabase();
    bool createTable();
    /*QJsonArray*/QVariantList loadAllFavorites();//从数据库获取数据转为
    // bool addFavorite(const QJsonObject& obj);
    bool addFavorite(const QVariantMap& obj);
    bool deleteFavorite(const QString& id);
    bool favoriteExists(const QString& id);

    QSqlDatabase m_database;
    QVariantList m_data;
    QString m_databasePath = "userInfo/favoriteMusic.db"; //数据库文件路径

signals:
    // void dataValueChanged();
    // void dataChanged();
    // void savePathChanged();

    void dataChanged();
    void databasePathChanged();
private slots:
    // void onDataValueChanged();


};

#endif // FAVORITEMANAGER_H

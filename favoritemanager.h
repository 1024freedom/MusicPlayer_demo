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

class FavoriteManager: public QObject {
    Q_OBJECT
    Q_PROPERTY(QJsonArray data READ data WRITE setData NOTIFY dataChanged FINAL)
    Q_PROPERTY(QString savePath READ savePath WRITE setSavePath NOTIFY savePathChanged FINAL)
public:
    explicit FavoriteManager(QObject* parent = nullptr);
    //Q_INVOKABLE 将类的成员函数注册到qt元对象系统，让函数具备“可被元对象系统识别和调用的能力”，用于QML与c++交互，无元对象系统支持时，QML无法调用
    Q_INVOKABLE void append(const QJsonObject& obj);
    Q_INVOKABLE void remove(const QString& id);
    Q_INVOKABLE int indexOf(const QString& findId);

    QJsonArray data()const;
    void setData(const QJsonArray &newData);

    QString savePath()const;
    void setSavePath(const QString &newSavePath);

private:
    QJsonArray readFile(const QString& filePath);
    void writeFile(const QString& filePath, const QJsonArray& obj);

    QJsonArray m_data;//存储数据
    QString m_savePath = "userInfo/favoriteMusic.json"; //文件保存路径
signals:
    void dataValueChanged();
    void dataChanged();
    void savePathChanged();
private slots:
    void onDataValueChanged();


};

#endif // FAVORITEMANAGER_H

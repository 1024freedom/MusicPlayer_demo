#ifndef MUSICSEARCH_H
#define MUSICSEARCH_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJSValue>
#include <QJSValueList>

class MusicSearch : public QObject {
    Q_OBJECT
public:
    explicit MusicSearch(QObject *parent = nullptr);

    Q_INVOKABLE void search(const QJSValue& obj);
    Q_INVOKABLE void searchSuggest(const QJSValue& obj);//搜索建议
private:
    QNetworkAccessManager* manager = nullptr;
    const QString BASE_URL = "http://localhost:3000";
    //格式化时间
    QString formatTime(int ms);
    //处理网络请求与回调
    //callBack是QML传过来的一个JS回调函数
    //parser是一个函数，接收QByteArray,返回QJSValue
    void makeRequest(const QString& urlString, const QJSValue& callBack, std::function<QJsonValue(QByteArray)>parser);


signals:
};

#endif // MUSICSEARCH_H

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
    void makeRequest(const QString& url, const QJSValue& callBack, std::function<QJSValue(QByteArray)>parser);

signals:
};

#endif // MUSICSEARCH_H

#include "musicsearch.h"
#include <QQmlEngine> // 必须包含这个才能使用 engine->toScriptValue
#include <QJSEngine>  // 为了使用 qjsEngine(this)

MusicSearch::MusicSearch(QObject *parent)
    : QObject{parent} {
    manager = new QNetworkAccessManager(this);
}

QString MusicSearch::formatTime(int ms) {
    int totalSeconds = ms / 1000;
    int h = totalSeconds / 3600;
    int m = (totalSeconds % 3600) / 60;
    int s = totalSeconds % 60;

    QString timeStr;
    if (h > 0) {
        timeStr += QString::number(h) + ":";
    }
    // 补零处理
    timeStr += QString("%1").arg(m, 2, 10, QChar('0')) + ":";
    timeStr += QString("%1").arg(s, 2, 10, QChar('0'));

    return timeStr;
}

void MusicSearch::makeRequest(const QString &urlString, const QJSValue &callBack, std::function<QJSValue(QByteArray)> parser) {
    QUrl url(urlString);
    QNetworkRequest request(url);

    QJSValue cbCopy = callBack;

    QNetworkReply* reply = manager->get(request);

    connect(reply, &QNetworkReply::finished, this, [this, reply, cbCopy, parser]()mutable{ //最好写上mutable无论需不需要（习惯）
        if (reply->error() == QNetworkReply::NoError) {
            QByteArray data = reply->readAll();

            QJsonValue resultData = parser(data);
            QJSEngine* engine = qjsEngine(this); //找到当前c++对象所属的QML引擎

            if (!engine && cbCopy.isCallable()) {
                engine = cbCopy.engine();
            }
            if (engine) {
                QJSValueList args;
                args << engine->toScriptValue(resultData.toVariant()); //转换为qml能用的类型
                if (cbCopy.isCallable()) {
                    cbCopy.call(args);//执行qml传过来的回调函数
                }
            } else {
                qWarning() << "无法获取 QJSEngine，回调无法执行";
            }
        } else {
            qWarning() << "Network Error:" << reply->errorString();
        }
        reply->deleteLater();
    });
}

//搜索功能，单曲type=1 歌单type=1000
void MusicSearch::search(const QJSValue &obj) {
    QString keywords = obj.property("keywords").toString();
    QString type = obj.hasProperty("type") ? obj.property("type").toString() : "1";
    QJSValue callBack = obj.property("callBack");

    if (keywords.isEmpty()) {
        return;
    }
    QString urlStr = QString("%1/search?keywords=%2&type=%3").arg(BASE_URL, keywords, type);

    //解析逻辑
    auto parser = [type, this](QByteArray rawData)->QJsonValue{
        QJsonDocument doc = QJsonDocument::fromJson(rawData);
        QJsonObject root = doc.object();
        QJsonObject result = root.value("result").toObject();
        QJsonArray finalArray;

        if (type == "1") { //单曲
            QJsonArray songs = result.value("songs").toArray();
            for (const auto& val : songs) {
                QJsonObject song = val.toObject();
                QJsonObject output;

                //适配qml字段
                output.insert("id", song.value("id").toVariant().toLongLong());
                output.insert("name", song.value("name").toString());
                //处理歌手
                QStringList artistNames;
                QString fallbackImg;//备用封面
                QJsonArray artists = song.value("artists").toArray();
                if (artists.isEmpty()) { //可能返回不同字段的情况
                    artists = song.value("ar").toArray();
                }
                for (const auto& artist : artists) {
                    artistNames << artist.toObject().value("name").toString();
                    if (fallbackImg.isEmpty()) {
                        fallbackImg = artist.toObject().value("img1v1Url").toString();
                    }
                }
                output.insert("artists", artistNames.join("/"));
                //处理专辑与封面
                QJsonObject album = song.value("album").toObject();
                if (album.isEmpty()) {
                    album = song.value("al").toObject();
                }
                output.insert("album", album.value("name").toString());
                //处理封面图片
                QString cover = album.value("picUrl").toString();
                if (cover.isEmpty()) {
                    cover = fallbackImg;
                }
                output.insert("coverImg", cover);
                //处理时长
                int duration = song.value("duration").toInt();
                if (duration == 0)duration = song.value("dt").toInt();
                output.insert("url", "");
                output.insert("allTime", formatTime(duration));
                finalArray.append(output);
            }
        } else if (type == 1000) { //歌单
            QJsonArray playlists = result.value("playlists").toArray();
            for (const auto& val : playlists) {
                QJsonObject list = val.toObject();
                QJsonObject output;

                output.insert("id", list.value("id").toVariant().toLongLong());
                output.insert("name", list.value("name").toString());
                output.insert("coverImg", list.value("coverImgUrl").toString());
                output.insert("description", list.value("description").toString());
                // 创建者昵称
                QJsonObject creator = list.value("creator").toObject();
                output.insert("creator", creator.value("nickname").toString());

                // 播放量 (转成字符串，防止数字过大)
                output.insert("playCount", list.value("playCount").toVariant().toLongLong());

                // 歌曲数量
                output.insert("trackCount", list.value("trackCount").toInt());

                finalArray.append(output);
            }
        }
    };
    makeRequest(urlStr, callBack, parser);
}
void MusicSearch::searchSuggest(const QJSValue &obj) {
    QString keywords = obj.property("keywords").toString();
    QJSValue callback = obj.property("callBack");
    if (keywords.isEmpty()) {
        return;
    }
    QString urlStr = QString("%1/search/suggest?keywords=%2&type=mobile").arg(BASE_URL, keywords);
    auto parser = [](QByteArray rawData)->QJsonValue{
        QJsonDocument doc = QJsonDocument::fromJson(rawData);
        QJsonObject root = doc.object();

        QJsonArray suggestions;
        if (root.contains("result")) {
            QJsonObject result = root.value("result").toObject();
            if (result.contains("allMatch")) {
                QJsonArray allMatch = result.value("allMatch").toArray();
                //遍历提取keywords
                for (const auto& val : allMatch) {
                    QJsonObject item = val.toObject();
                    suggestions.append(item.value("keywords").toString());
                }
            }
        }
        //返回提示词字符串数组
        return suggestions;
    };
    makeRequest(urlStr, callback, parser);
}

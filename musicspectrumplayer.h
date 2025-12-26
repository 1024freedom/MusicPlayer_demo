#ifndef MUSICSPECTRUMPLAYER_H
#define MUSICSPECTRUMPLAYER_H

#include <QQuickPaintedItem>
#include <QAudioSink>
#include <QAudioDecoder>
#include <QMediaDevices>
#include <QAudioDevice>
#include <QBuffer>
#include <QTimer>
#include <vector>
#include <complex>

class MusicSpectrumPlayer : public QQuickPaintedItem {
    Q_OBJECT
    //模拟mediaplayer的属性
    Q_PROPERTY(QUrl m_source READ source WRITE setSource NOTIFY sourceChanged FINAL)
    Q_PROPERTY(qint64 duration READ duration NOTIFY durationChanged FINAL)
    Q_PROPERTY(qint64 position READ position WRITE setPosition NOTIFY positionChanged FINAL)
    Q_PROPERTY(bool m_playing READ isPlaying NOTIFY playbackStateChanged FINAL)
    Q_PROPERTY(QColor m_barColor READ barColor WRITE setBarColor NOTIFY barColorChanged FINAL)

    QML_ELEMENT//自动化注册

public:
    explicit MusicSpectrumPlayer(QQuickItem *parent = nullptr);
    ~MusicSpectrumPlayer();

    void paint(QPainter *painter)override;
    QUrl source()const;
    void setSource(const QUrl& newSource);

    qint64 duration()const;
    qint64 position()const;
    void setPosition(qint64 newPosition);

    bool isPlaying()const;
    QColor barColor()const;
    void setBarColor(const QColor& color);
public slots:
    void play();
    void pause();
    void stop();

signals:
    void onBufferReady();
    void onFinished();
    void handleStateChanged(QAudio::State newState);
    void updateSpectrum();//定时刷新波型和进度
private:
    void fft(std::vector<std::complex<double>>& x);//传一个复数容器
    QAudioDecoder* m_decoder = nullptr;
    QAudioSink* m_audioSink = nullptr; //播放原始音频数据
    QIODevice* m_ioDevice = nullptr; //用于向audiosink写入数据的buffer

    QByteArray m_pcmData;//存储完整的解码后的音频数据
    QBuffer m_buffer;//包装m_pcmData用于播放

    QUrl m_source;
    QColor m_barColor = Qt::cyan; //初始化为青色

    QTimer* m_timer;
    std::vector<double> m_spectrum;//频谱高度
    int m_barCount = 80;

    QAudioFormat m_format;
    bool m_playing = false;

};

#endif // MUSICSPECTRUMPLAYER_H

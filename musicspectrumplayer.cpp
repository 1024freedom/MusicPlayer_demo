#include "musicspectrumplayer.h"

MusicSpectrumPlayer::MusicSpectrumPlayer(QQuickItem *parent)
    : QQuickPaintedItem{parent} {
    //设置音频格式，16位44100Hz双声道
    m_format.setSampleRate(44100);
    m_format.setChannelCount(2);
    m_format.setSampleFormat(QAudioFormat::Int16);
    //初始化解码器
    m_decoder = new QAudioDecoder(this);
    m_decoder->setAudioFormat(m_format);

    connect(m_decoder, &QAudioDecoder::bufferReady, this, &MusicSpectrumPlayer::onBufferReady);
    connect(m_decoder, &QAudioDecoder::finished, this, &MusicSpectrumPlayer::onFinished);

    //初始化音频输出
    QAudioDevice device = QMediaDevices::defaultAudioOutput();
    m_audioSink = new QAudioSink(device, m_format, this);
    connect(m_audioSink, &QAudioSink::stateChanged, this, &MusicSpectrumPlayer::handleStateChanged);

    //刷新定时器
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &MusicSpectrumPlayer::updateSpectrum);
    m_spectrum.resize(m_barCount, 0.0);
}

MusicSpectrumPlayer::~MusicSpectrumPlayer() {
    stop();
}

void MusicSpectrumPlayer::paint(QPainter *painter) {
    painter->setRenderHint(QPainter::Antialiasing);//开启抗锯齿
    painter->setBrush(m_barColor);
    painter->setPen(Qt::NoPen);

    if (m_spectrum.empty())return;

    qreal w = width();
    qreal h = height(); //频谱图组件的宽高
    qreal totalBarSpace = w / m_barCount;
    qreal barWidth = totalBarSpace * 0.8;
    qreal gap = totalBarSpace * 0.2;
    for (int i = 0; i < m_barCount; ++i) {
        qreal barHeight = m_spectrum[i] * h;
        qreal x = i * (barWidth + gap) + gap / 2;
        qreal y = h - barHeight;
        //绘制圆角矩形
        painter->drawRoundedRect(QRectF(x, y, barWidth, barHeight), barWidth, barHeight);
    }
}

//----播放控制-----
void MusicSpectrumPlayer::setSource(const QUrl &newSource) {
    if (m_source == newSource) {
        return;
    }
    m_source = newSource;
    stop();
    //清空旧数据
    m_pcmData.clear();
    m_buffer.close();
    m_spectrum.assign(m_barCount, 0.0); //全部替换为0.0
    update();//重新渲染
    //开始解码新文件
    m_decoder->setSource(m_source);
    m_decoder->start();
    emit sourceChanged();
}

QUrl MusicSpectrumPlayer::source()const {
    return m_source;
}

void MusicSpectrumPlayer::onBufferReady() {
    //读取解码后的数据块并追加到内存中
    QAudioBuffer buffer = m_decoder->read();
    m_pcmData.append(reinterpret_cast<const char*>(buffer.data<void>()), buffer.byteCount()); //const char* 指向常量的指针（const* char是指针常量）
    //data<void>() 是 QAudioBuffer 提供的公共接口，用于访问底层内存池。
    //reinterpret_cast<const char*> 将通用指针转换为字符指针，以便 QByteArray 能够正确追加字节内容。

}

void MusicSpectrumPlayer::onFinished() {
    //解码完成，准备播放buffer
    m_buffer.setData(m_pcmData);
    m_buffer.open(QIODevice::ReadOnly);

    emit durationChanged();
    if (m_playing) {
        play();
    }
}

void MusicSpectrumPlayer::play() {
    if (m_pcmData.isEmpty() && m_decoder->isDecoding()) {
        m_playing = true; //解码完成后自动播放
        return;
    }
    if (m_pcmData.isEmpty()) {
        return;
    }
    m_audioSink->start(&m_buffer);
    m_timer->start(30);
    m_playing = true;
    emit playbackStateChanged();
}

void MusicSpectrumPlayer::pause() {
    m_audioSink->suspend();//使声卡停止请求数据，buffer读取位置保持不动
    m_timer->stop();
    m_playing = false;
    emit playbackStateChanged();
}

void MusicSpectrumPlayer::stop() {
    m_audioSink->stop();//彻底停止音频输出设备
    m_buffer.close();//关闭当前作为输入源的buffer，同时会重置内存缓冲区指针

    //重新准备缓冲区
    if (!m_pcmData.isEmpty()) {
        m_buffer.open(QIODevice::ReadOnly);
    }

    m_timer->stop();
    m_playing = false;
    emit playbackStateChanged();
    //该函数会将进度重置为零
    emit positionChanged();
}

qint64 MusicSpectrumPlayer::duration()const {
    //公式：总字节 / (采样率 * 通道数 * 位深/8) * 1000
    if (m_pcmData.isEmpty()) {
        return 0;
    }
    qint64 bytes = m_pcmData.size();
    int bytesPerSample = 2; //16/8
    int channels = 2;
    int rate = 44100;
    return (bytes * 1000) / (rate * channels * bytesPerSample);

}

qint64 MusicSpectrumPlayer::position()const {
    if (!m_buffer.isOpen()) {
        return 0;
    }
    qint64 bytes = m_buffer.pos();
    int bytesPerSample = 2;
    int channels = 2;
    int rate = 44100;
    return (bytes * 1000) / (rate * channels * bytesPerSample);
}


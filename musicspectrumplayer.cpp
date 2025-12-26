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

void MusicSpectrumPlayer::~MusicSpectrumPlayer() {
    stop();
}

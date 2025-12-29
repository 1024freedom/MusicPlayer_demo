#include "musicspectrumplayer.h"

const int FFT_SIZE = 512;

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

/**
 * @brief MusicSpectrumPlayer::setPosition
 * 设置播放进度（Seek操作）。
 * 当用户拖动进度条时，QML 会调用此函数，传入目标时间（毫秒）。
 * @param newPosition 目标播放位置，单位：毫秒 (ms)
 */
void MusicSpectrumPlayer::setPosition(qint64 newPosition) {
    if (!m_buffer.isOpen()) {
        return;
    }
    int bytesPerSample = 2;
    int channels = 2;
    int rate = 44100;
    /**
     * 时间转字节偏移量（核心公式）
     * 目标字节位置 = 时间(ms) * 每秒数据量 / 1000
     * * 计算逻辑：
     * newPosition / 1000 -> 转换成“秒”
     * * rate             -> 这一秒有多少个采样时刻
     * * channels         -> 每个时刻有两个通道的数据（左+右）
     * * bytesPerSample   -> 每个数据占多少字节
     */
    qint64 targetByte = (newPosition * rate * channels * bytesPerSample) / 1000;

    /**
     * 采样帧对齐 (关键步骤)
     * 音频数据在内存中是交错排列的：[左低8位][左高8位][右低8位][右高8位] ...
     * 一个完整的采样帧（Frame）包含 左声道+右声道，共 2+2=4 字节。
     * * 如果 targetByte 是 1、2 或 3，指针会落在采样数据的“中间”，导致左右声道反转或产生爆音。
     * 这里的计算 (targetByte % 4) 是取余数，减去余数是为了确保 targetByte 是 4 的倍数。
     */
    targetByte = targetByte - (targetByte % 4);

    if (targetByte < m_pcmData.size()) {
        m_buffer.seek(targetByte);
        emit positionChanged();
    }
}

bool MusicSpectrumPlayer::isPlaying()const {
    return m_playing;
}

void MusicSpectrumPlayer::handleStateChanged(QAudio::State newState) {
    if (newState == QAudio::IdleState && m_playing) {
        //播放结束
        stop();
        emit playbackFinished();
    }
}

//-----数据分析与快速傅里叶变换

/**
 * @brief MusicSpectrumPlayer::updateSpectrum
 * 定时器触发的槽函数（核心引擎）。
 * 作用：实时分析当前播放位置的音频数据，生成频谱可视化数据。
 */
void MusicSpectrumPlayer::updateSpectrum() {
    emit positionChanged();//同步进度
    if (!m_buffer.isOpen()) {
        return;
    }
    //当前播放指针的位置
    qint64 pos = m_buffer.pos();
    /**
     * 计算需要读取的数据量：
     * FFT_SIZE (512): 我们需要 512 个样本点来进行一次傅里叶变换。
     * * 2 (Channels): 音频是双声道的，数据是 [左, 右, 左, 右...] 交错排列的。
     * * 2 (Bytes): 16位音频 (Int16) 每个样本占 2 个字节。
     */
    int bytesToRead = FFT_SIZE * 2 * 2;
    if (pos + bytesToRead >= m_pcmData.size()) {
        return;
    }
    //获取内存指针
    //m_pcnData是数组首地址
    const char* ptr = m_pcmData.constData() + pos;
    // 强转为 Int16 指针，方便后续直接按数值读取（而不是按字节读取）
    const qint16* samples = reinterpret_cast<const qint16*>(ptr);

    //-------预处理与加窗-------

    //准备一个复数数组作为FFT的输入
    std::vector<std::complex<double>> vec(FFT_SIZE);

    for(int i = 0; i<FFT_SIZE; ++i) {
        /**
         * 提取左声道数据：
         * 内存结构：[L0, R0, L1, R1, L2, R2 ...]
         * 索引 i=0 -> samples[0] (L0)
         * 索引 i=1 -> samples[2] (L1)  <-- 也就是 i * 2
         * 只分析左声道即可，双声道合成分析会增加计算量但视觉效果提升不明显。
         */
        double sampleVal = samples[i * 2];

        //汉宁窗处理
        /**
         *截取的一段音频波形在首尾处可能会突然被切断（不连续），这在 FFT 中会产生
         *原本不存在的高频杂波（频谱泄漏）。
         * 汉宁窗本质上是一条中间高（1）、两头低（0）的钟形曲线。
            操作步骤： 我们将原始的那段音频数据，乘以这个汉宁窗曲线
            中间的数据：乘以接近 1 的数，保留原样
            两头的数据：乘以接近 0 的数，被强制压低，逐渐变为静音。
            结果： 经过处理后的波形，起点和终点都变成了 0。这样无论这一段波形怎么循环，首尾都能完美连接，不再有“断崖”。
        */
        double window = 0.5 * (1.0 - qCos(2.0 * M_PI * i / (FFT_SIZE - 1)));
        //构建复数，实部是加窗后的采样值，虚部为0
        vec[i] = std::complex<double>(sampleVal * window, 0);
    }
    //-------快速傅里叶变换-------
    //时域信号（横轴是时间，纵轴是振幅/音量）转换为频域信号（横轴是频率（低音高音），纵轴是强度（有多响））
    fft(vec);

    //--------数据映射与视觉平滑----------
    /**
     * FFT 结果是对称的，我们只需要前半部分 (FFT_SIZE / 2)。
     * 我们需要将这 256 个频率点合并成 m_barCount 个柱子。
     * samplesPerBar: 每个显示柱子代表多少个 FFT 频率点的集合。
     */
    int samplesPerBar = (FFT_SIZE / 2) / m_barCount;

}


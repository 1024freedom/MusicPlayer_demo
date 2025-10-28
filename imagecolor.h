#ifndef IMAGECOLOR_H
#define IMAGECOLOR_H

#include <QObject>
#include <QImage>
#include <QColor>
#include <QVector>
#include <QRandomGenerator>
#include <cmath>
#include <QDebug>
#include <random>
#include <omp.h>
#include <QtConcurrent/QtConcurrent>
#include <QFutureWatcher>

class ImageColor: public QObject {
    Q_OBJECT
    Q_PROPERTY(int k READ k WRITE setK NOTIFY kChanged)
    Q_PROPERTY(int maxIterations READ maxIterations WRITE setMaxIterations NOTIFY maxIterationsChanged)
public:
    ImageColor();

    //聚类中心的数量
    const int k = 3;
    //最大迭代次数(逐步修正聚类中心的位置，让其从初始的 “粗略估计” 收敛到 “能准确代表簇内颜色的最优位置”)
    const int maxItrations = 6;

    //K-means++算法
    Q_INVOKABLE QVector<QColor> getMainColorsSync(const QImage& image);//同步版本
    Q_INVOKABLE void getMainColorsAsync(const QImage& image);//异步版本

    // 取消当前异步操作
    Q_INVOKABLE void cancelCurrentOperation();

    // 属性访问器
    int k() const { return k; }
    int maxIterations() const { return maxIterations; }

    void setK(int newk) {
        if (k != newk) {
            k = newk;
            emit kChanged();
        }
    }

    void setMaxIterations(int iterations) {
        if (maxIterations != iterations) {
            maxIterations = iterations;
            emit maxIterationsChanged();
        }
    }
signals:
    void colorsExtracted(const QVector<QColor>& colors);
    void extractionFailed();
    void kChanged();
    void maxIterationsChanged();

private:


    QFutureWatcher<QVector<QColor>>* m_futureWatcher = nullptr;
    bool m_cancelled = false;

    //静态方法，用于在后台线程安全执行
    //计算两个颜色之间的欧氏距离(值越小表示两个颜色越相似)
    static double colorEuclideanDistance(const QColor& c1, const QColor& c2);
    static QVector<QColor> kmeansPlusPlus(const QImage& image, int k);
    static QVector<QColor> extractColors(const QImage& image, int k, int maxIterations);
private slots:
    void onAsyncOperationFinished();
};

#endif // IMAGECOLOR_H

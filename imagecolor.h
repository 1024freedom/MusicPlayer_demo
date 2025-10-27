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

class ImageColor: public QObject {
    Q_OBJECT
public:
    ImageColor();
    ImageColor(const QImage &image);

    //获取平均色
    Q_INVOKABLE QString avgColor(const QImage &image);
    //K-means++算法
    Q_INVOKABLE QVector<QColor> getMainColors(const QImage& image);
    //最小距离
    double m_minDistance = 15;
    //聚类中心的数量
    const int k = 3;
    //最大迭代次数(逐步修正聚类中心的位置，让其从初始的 “粗略估计” 收敛到 “能准确代表簇内颜色的最优位置”)
    const int maxItrations = 6;
private:
    //计算两个颜色之间的欧氏距离(值越小表示两个颜色越相似)
    double colorEuclideanDistance(const QColor& c1, const QColor& c2);
    QVector<QColor> kmeansPlusPlus(const QImage& image, int k);
};

#endif // IMAGECOLOR_H

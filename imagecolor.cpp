#include "imagecolor.h"

ImageColor::ImageColor() {}


ImageColor::ImageColor(const QImage &image) {
    avgColor(image);
}

double ImageColor::colorEuclideanDistance(const QColor &c1, const QColor &c2) {
    int dr = c1.red() - c2.red();
    int dg = c1.green() - c2.green();
    int db = c1.blue() - c2.blue();
    return std::sqrt(dr * dr + dg * dg + db * db);
}

QString ImageColor::avgColor(const QImage &image) {
    qDebug() << "图片宽高" << "w:" << image.width() << "h:" << image.height();

    //初始化颜色值的总和
    int totalRed = 0;
    int totalGreen = 0;
    int totalBlue = 0;
    int totalPixels = image.width() * image.height();

    //遍历图片像素，累加颜色值
    for (int y = 0; y < image.height(); y++) {
        for (int x = 0; x < image.width(); x++) {
            QColor color(image.pixel(x, y));
            totalRed += color.red();
            totalGreen += color.green();
            totalBlue += color.blue();
        }
    }

    //计算平均颜色
    int avgRed = totalRed / totalPixels;
    int avgGreen = totalGreen / totalPixels;
    int avgBlue = totalBlue / totalPixels;

    //创建平均颜色的qcolor对象
    QColor avgColor(avgRed, avgGreen, avgBlue);

    return avgColor.name();//平均颜色值
}

// //选择初始聚类中心的K-means++算法
// QVector<QColor> ImageColor::kmeansPlusPlus(const QImage &image, int k){

//     QVector<QColor> centroids;//存储聚类中心

//     if(image.width()<=0||image.height()<=0||k<=0){
//         return centroids;
//     }

//     //选择第一个聚类中心 随机选择一个像素
//     int x=QRandomGenerator::global()->bounded(image.width());
//     int y=QRandomGenerator::global()->bounded(image.height());
//     centroids.append(image.pixelColor(x,y));

//     //选择剩余的聚类中心
//     for(int i=1;i<k;i++){

//         QVector<double>minDistance(image.width()*image.height(),std::numeric_limits<double>::max());//所有元素初始值设为double所能表示的最大值

//         double totalDist=0.0;

//         //计算每个像素到最近聚类中心的距离(被现有中心覆盖的程度)
//         for(int y=0;y<image.height();y++){
//             for(int x=0;x<image.width();x++){
//                 QColor pixel=image.pixelColor(x,y);
//                 for(int j=0;j<centroids.size();j++){
//                     double d=ImageColor:: colorEuclideanDistance(pixel,centroids[j]);
//                     minDistance[y*image.width()+x]=std::min(minDistance[y*image.width()+x],d);

//                 }
//                 totalDist+=minDistance[y*image.width()+x];//累加所有最小距离(每个样本的选中概率为minDistance[i]/totalDist，距离越大的样本，被选中为下一个中心的概率越高，避免聚类中心扎堆)
//             }
//         }

//         //根据距离加权随机选择下一个聚类中心
//         double randVal=QRandomGenerator::global()->bounded(totalDist);//生成[0.0,totalDist）区间内的随机double数
//         double sum=0.0;
//         int x;
//         int y;
//         //线性搜索找到随机值对应的像素位置
//         for(y=0;y<image.height();y++){
//             for(x=0;x<image.width();x++){
//                 sum+=minDistance[y*image.width()+x];
//                 if(sum>=randVal){
//                     break;
//                 }
//             }
//             if(sum>=randVal){
//                 break;
//             }
//         }
//         centroids.append(image.pixelColor(x,y));//添加新的聚类中心
//     }
//     return centroids;
// }

//选择初始聚类中心的K-means++算法
QVector<QColor> ImageColor::kmeansPlusPlus(const QImage &image, int k) {
    QVector<QColor> centroids;

    if (image.width() <= 0 || image.height() <= 0 || k <= 0) {
        return centroids;
    }

    const int width = image.width();
    const int height = image.height();
    const int totalPixels = width * height;

    //预计算所有像素颜色，避免重复调用pixelColor
    QVector<QColor>pixels;
    pixels.reserve(totalPixels);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            pixels.append(image.pixelColor(x, y));
        }
    }

    //随机数生成器
    std::random_device rd;//真随机数种子源
    std::mt19937 gen(rd());

    //选择第一个聚类中心
    std::uniform_int_distribution<>dis(0, totalPixels - 1);
    centroids.append(pixels[dis(gen)]);

    //选择剩余聚类中心
    QVector<double>minDistance(totalPixels, std::numeric_limits<double>::max());

    for (int i = 0; i < k; i++) {
        double totalDist = 0.0;

        //并行计算最小距离
//当 totalPixels 大于 10000 时，将后续的 for 循环并行化（多线程同时执行），并通过加法归约安全累加 totalDist；否则，循环按串行执行，平衡并行效率与开销。充分利用多核硬件资源
        #pragma omp parallel for reduction(+:totalDist)if(totalPixels>10000)
        for (int idx = 0; idx < totalPixels; idx++) {
            double minDist = std::numeric_limits<double>::max();

            //找到该像素到所有已有聚类中心的最小距离
            for (int j = 0; j < centroids.size(); j++) {
                double dist = ImageColor::colorEuclideanDistance(pixels[idx], centroids[j]);
                if (dist < minDist) {
                    minDist = dist;
                }
            }
            minDistance[idx] = minDist;
            totalDist += minDist;
        }


        std::vector<double>cumulativeSums(totalPixels);
        cumulativeSums[0] = minDistance[0];
        for (int idx = 1; idx < totalPixels; idx++) {
            cumulativeSums[idx] = cumulativeSums[idx - 1] + minDistance[idx];
        }//前缀和,构建概率分布区间

        std::uniform_int_distribution<>realDis(0.0, totalDist);
        double randVal = realDis(gen);

        //二分法搜索目标像素位置
        auto it = std::lower_bound(cumulativeSums.begin(), cumulativeSums.end(), randVal);
        int selectedIndex = std::distance(cumulativeSums.begin(), it);

        //边界检查
        if (selectedIndex >= totalPixels) {
            selectedIndex = totalPixels - 1;
        }
        centroids.append(pixels[selectedIndex]);
    }
    return centroids;
}


QVector<QColor> ImageColor::getMainColors(const QImage &image) {
    if (image.width() <= 0 || image.height() <= 0 || k <= 0) {
        return QVector<QColor>();
    }

    const int width = image.width();
    const int height = image.height();
    const int totalPixels = width * height;

    //预读取所有像素到连续内存
    QVector<QRgb> pixels(totalPixels);
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            pixels[y * width + x] = image.pixel(x, y);
        }
    }

    //使用k-means++初始化聚类中心点
    QVector<QColor> centroids = ImageColor::kmeansPlusPlus(image, this->k);
    QVector<int>centroidsCnt(this->k, 0); //每个簇的像素数量，用于结果分析

    //提前计算收敛阈值
    const double convergenceThreshold = 1.0;

    //主迭代循环（同一个索引的中心点在不同迭代周期中的实体构成一个簇）
    for (int iter = 0; iter < this->maxItrations; iter++) {

        // 使用累加器记录每个簇的颜色分量总和，避免存储所有像素
        // 使用qint64防止大图像求和时整数溢出
        QVector<qint64> sumR(this->k, 0), sumG(this->k, 0), sumB(this->k, 0);

        QVector<int> clusterSizes(this->k, 0); //在一个迭代周期中每个簇的像素增加量
        QVector<QColor> oldCentroids = centroids; //保存旧中心用于收敛判断
        bool converged = true; //是否收敛

        //并行化像素分配
        #pragma omp parallel for if(totalPixels>10000)
        for (int idx = 0; idx < totalPixels; idx++) {
            QRgb rgb = pixels[idx];
            QColor pixel = QColor::fromRgb(rgb);

            int closestCentroid = 0;
            double minDistance = std::numeric_limits<double>::max();

            //寻找当前像素最近的聚类中心
            for (int i = 0; i < this->k; i++) {
                double distance = colorEuclideanDistance(pixel, centroids[i]);
                if (distance < minDistance) {
                    minDistance = distance;
                    closestCentroid = i;
                }
            }
            //原子操作更新累加器
            #pragma omp atomic
            sumR[closestCentroid] += qRed(rgb);
            #pragma omp atomic
            sumG[closestCentroid] += qGreen(rgb);
            #pragma omp atomic
            sumB[closestCentroid] += qBlue(rgb);
            #pragma omp atomic
            clusterSizes[closestCentroid]++;
        }

        //迭代聚类中心并检查收敛
        for (int i = 0; i < this->k; i++) {
            if (clusterSizes[i] > 0) {
                int r = static_cast<int>(sumR[i] / clusterSizes[i]);
                int g = static_cast<int>(sumG[i] / clusterSizes[i]);
                int b = static_cast<int>(sumB[i] / clusterSizes[i]);
                QColor newCentroid(r, g, b);

                //检查收敛性
                if (converged && colorEuclideanDistance(newCentroid, oldCentroids[i]) > convergenceThreshold) {
                    converged = false;
                }
                centroids[i] = newCentroid;
                centroidsCnt[i] += clusterSizes[i];
            }
        }

        //如果聚类中心不再显著变化，提前终止迭代
        if (converged && iter > 5) { //至少迭代五次
            break;
        }
    }
    //过滤空簇并按亮度排序
    QVector<QColor> validCentroids;
    for (int i = 0; i < this->k; i++) {
        if (centroidsCnt[i] > 0) {
            validCentroids.append(centroids[i]);
        }
    }
    std::sort(validCentroids.begin(), validCentroids.end(), [](const QColor & a, const QColor & b) {
        return a.lightnessF() < b.lightnessF();
    });

    return validCentroids;
}

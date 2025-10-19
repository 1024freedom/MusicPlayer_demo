#ifndef DESKTOPLYRIC_H
#define DESKTOPLYRIC_H
#include <QObject>
#include<QQuickWindow>
class DesktopLyric: public QQuickWindow {
    Q_OBJECT
public:
    DesktopLyric(QWindow* parent = nullptr);
// protected:
//     void mousePressEvent(QMouseEvent* event)override;
//     void mouseReleaseEvent(QMouseEvent* event)override;
//     void mouseMoveEvent(QMouseEvent* event)override;

};

#endif // DESKTOPLYRIC_H

#ifndef DESKTOPLYRIC_H
#define DESKTOPLYRIC_H
#include <QObject>
#include<QQuickWindow>
class DesktopLyric: public QQuickWindow {
    Q_OBJECT
public:
    DesktopLyric(QWindow* parent = nullptr);
protected:
    void mousePressEvent(QMouseEvent* event)override;
    void mouseReleaseEvent(QMouseEvent* event)override;
    void mouseMoveEvent(QMouseEvent* event)override;
private:
    void handleWindowMove(const QPointF& globalMousePos);
    bool m_isMoving = false;

    QPointF m_startGlobalPos;        // 鼠标按下时的全局位置
    QPoint m_startWindowPos;         // 窗口起始位置

};

#endif // DESKTOPLYRIC_H

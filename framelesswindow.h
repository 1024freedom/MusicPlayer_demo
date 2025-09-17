#ifndef FRAMELESSWINDOW_H
#define FRAMELESSWINDOW_H
#include<QQuickWindow>
#include<QPointF>
#include<QSize>
class FramelessWindow: public QQuickWindow {
    Q_OBJECT

public:
    enum class MousePosition {
        TOPLEFT = 1,
        TOP,
        TOPRIGHT,
        LEFT,
        RIGHT,
        BOTTOMLEFT,
        BOTTOM,
        BOTTOMRIGHT,
        NORMAL
    };
    FramelessWindow(QWindow* parent = nullptr);
protected:
    void mousePressEvent(QMouseEvent* event)override;
    void mouseReleaseEvent(QMouseEvent* event)override;
    void mouseMoveEvent(QMouseEvent* event)override;
private:
    void setWindowGeometry(const QPointF& pos);
    void setCursorIcon();
    MousePosition getMousePos(QPointF& pos);
    //缩放边距
    int step = 8;
    //鼠标的大概位置
    MousePosition mouse_pos = MousePosition::NORMAL;
    //起始位置
    QPointF start_pos;
    //旧位置
    QPointF old_pos;
    //旧大小
    QSize old_size;
};

#endif // FRAMELESSWINDOW_H

#ifndef FRAMELESSWINDOW_H
#define FRAMELESSWINDOW_H
#include<QQuickWindow>
#include<QPointF>
class FramelessWindow: public QQuickWindow {
    Q_OBJECT
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

public:
    FramelessWindow(QWindow* parent = nullptr);
protected:
    void mousePressEvent(QMouseEvent* event)override;
    void mouseReleaseEvent(QMouseEvent* event)override;
    void mouseMoveEvent(QMouseEvent* event)override;
private:
    void setCursorIcon();
    MousePosition getMousePos(QPointF& pos);
    //缩放边距
    int step = 8;
    //鼠标的大概位置
    MousePosition mouse_pos = MousePosition::NORMAL;
};

#endif // FRAMELESSWINDOW_H

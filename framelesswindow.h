// #ifndef FRAMELESSWINDOW_H
// #define FRAMELESSWINDOW_H
// #include<QQuickWindow>
// #include<QPointF>
// #include<QSize>
// class FramelessWindow: public QQuickWindow {
//     Q_OBJECT

// public:
//     enum class MousePosition {
//         TOPLEFT,
//         TOP,
//         TOPRIGHT,
//         LEFT,
//         RIGHT,
//         BOTTOMLEFT,
//         BOTTOM,
//         BOTTOMRIGHT,
//         NORMAL
//     };
//     FramelessWindow(QWindow* parent = nullptr);
// protected:
//     void mousePressEvent(QMouseEvent* event)override;
//     void mouseReleaseEvent(QMouseEvent* event)override;
//     void mouseMoveEvent(QMouseEvent* event)override;
// private:
//     void setWindowGeometry(const QPointF& pos);
//     void setCursorIcon();
//     MousePosition getMousePos(QPointF& pos);
//     //缩放边距
//     int step = 15;
//     //鼠标当前位置
//     MousePosition mouse_pos = MousePosition::NORMAL;
//     //起始位置
//     QPointF start_pos;
//     //旧位置
//     QPointF old_pos;
//     //旧大小
//     QSize old_size;
// };

// #endif // FRAMELESSWINDOW_H
#ifndef FRAMELESSWINDOW_H
#define FRAMELESSWINDOW_H

#include <QQuickWindow>
#include <QPointF>
#include <QSize>
#include <QMouseEvent>

class FramelessWindow : public QQuickWindow {
    Q_OBJECT

public:
    enum class MousePosition {
        TOPLEFT,
        TOP,
        TOPRIGHT,
        LEFT,
        RIGHT,
        BOTTOMLEFT,
        BOTTOM,
        BOTTOMRIGHT,
        NORMAL,
        TITLEBAR  // 添加标题栏区域用于移动窗口
    };

    FramelessWindow(QWindow* parent = nullptr);

protected:
    void mousePressEvent(QMouseEvent* event) override;
    void mouseReleaseEvent(QMouseEvent* event) override;
    void mouseMoveEvent(QMouseEvent* event) override;

private:
    void updateCursorIcon();
    MousePosition getMousePosition(const QPointF& pos);
    void handleWindowResize(const QPointF& globalMousePos);
    void handleWindowMove(const QPointF& globalMousePos);

    int m_borderWidth = 10;           // 边框宽度
    int m_titleBarHeight = 40;       // 标题栏高度

    MousePosition m_mousePosition = MousePosition::NORMAL;
    bool m_isResizing = false;
    bool m_isMoving = false;

    QPointF m_startGlobalPos;        // 鼠标按下时的全局位置
    QPointF m_startLocalPos;         // 鼠标按下时的局部位置
    QPoint m_startWindowPos;         // 窗口起始位置
    QSize m_startWindowSize;         // 窗口起始大小
};

#endif // FRAMELESSWINDOW_H

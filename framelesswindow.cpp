// #include "framelesswindow.h"

// FramelessWindow::FramelessWindow(QWindow* parent) : QQuickWindow(parent) {
//     this->setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowMinMaxButtonsHint);
// }

// void FramelessWindow::setCursorIcon() {
//     static bool isSet = false;
//     switch (this->mouse_pos) {
//     case MousePosition::TOPLEFT:
//     case MousePosition::BOTTOMRIGHT:
//         this->setCursor(Qt::SizeFDiagCursor);
//         isSet = true;
//         break;
//     case MousePosition::TOP:
//     case MousePosition::BOTTOM:
//         this->setCursor(Qt::SizeVerCursor);
//         isSet = true;
//         break;
//     case MousePosition::TOPRIGHT:
//     case MousePosition::BOTTOMLEFT:
//         this->setCursor(Qt::SizeBDiagCursor);
//         isSet = true;
//         break;
//     case MousePosition::LEFT:
//     case MousePosition::RIGHT:
//         this->setCursor(Qt::SizeHorCursor);
//         isSet = true;
//         break;
//     default:
//         if (isSet) {
//             isSet = false;
//             this->unsetCursor();
//         }
//         break;
//     }
// }

// FramelessWindow::MousePosition FramelessWindow::getMousePos(QPointF &pos) {
//     int x = pos.x();
//     int y = pos.y();
//     int w = this->width();
//     int h = this->height();

//     MousePosition mouse_pos = MousePosition::NORMAL;

//     if (x >= 0 && x <= this->step && y >= 0 && y <= this->step) {
//         mouse_pos = MousePosition::TOPLEFT;
//     } else if (x >= w - this->step && x < w && y >= 0 && y <= this->step) {
//         mouse_pos = MousePosition::TOPRIGHT;
//     } else if (x > this->step && x < (w - this->step) && y >= 0 && y <= this->step) {
//         mouse_pos = MousePosition::TOP;
//     } else if (x >= 0 && x < this->step && y >= this->step && y <= h - this->step) {
//         mouse_pos = MousePosition::LEFT;
//     } else if (x >= w - this->step && x <= w && y >= this->step && y <= h - this->step) {
//         mouse_pos = MousePosition::RIGHT;
//     } else if (x >= 0 && x <= this->step && y >= h - this->step && y <= h) {
//         mouse_pos = MousePosition::BOTTOMLEFT;
//     } else if (x >= w - this->step && x < w && y >= h - this->step && y <= h) {
//         mouse_pos = MousePosition::BOTTOMRIGHT;
//     } else if (x > this->step && x <= w - this->step && y >= h - this->step && y <= h) {
//         mouse_pos = MousePosition::BOTTOM;
//     }
//     return mouse_pos;
// }
// void FramelessWindow::setWindowGeometry(const QPointF &pos) {

//     QPointF offset = this->start_pos - pos;//鼠标的全局位移
//     if (offset.x() == 0 && offset.y() == 0)return;

//     auto set_geometry_func = [this](const QSize & size, const QPointF & pos) { //传入拖拽后窗口的size和pos
//         QPointF t_pos = this->old_pos;
//         QSize t_size = minimumSize();
//         if (size.width() > minimumWidth()) {
//             t_pos.setX(pos.x());
//             t_size.setWidth(size.width());
//         } else if (this->mouse_pos == MousePosition::LEFT) {
//             t_pos.setX(this->old_pos.x() + this->old_size.width() - minimumWidth());
//         }
//         if (size.height() > minimumHeight()) {
//             t_pos.setY(pos.y());
//             t_size.setHeight(size.height());
//         } else if (this->mouse_pos == MousePosition::TOP) {
//             t_pos.setX(this->old_pos.y() + this->old_size.height() - minimumHeight());
//         }
//         this->setGeometry(t_pos.x(), t_pos.y(), t_size.width(), t_size.height());
//         this->update();
//     };


//     switch (this->mouse_pos) {
//     case MousePosition::TOPLEFT: set_geometry_func(this->old_size + QSize(offset.x(), offset.y()),
//                 this->old_pos - offset);
//         break;
//     case MousePosition::TOP: set_geometry_func(this->old_size + QSize(0, offset.y()),
//                 this->old_pos - QPointF(0, offset.y()));
//         break;
//     case MousePosition::TOPRIGHT: set_geometry_func(this->old_size - QSize(offset.x(), -offset.y()),
//                 this->old_pos - QPointF(0, offset.y()));
//         break;
//     case MousePosition::LEFT: set_geometry_func(this->old_size + QSize(offset.x(), 0),
//                 this->old_pos - QPointF(offset.x(), 0));
//         break;
//     case MousePosition::RIGHT: set_geometry_func(this->old_size - QSize(offset.x(), 0),
//                 this->position());
//         break;
//     case MousePosition::BOTTOMLEFT: set_geometry_func(this->old_size + QSize(offset.x(), -offset.y()),
//                 this->old_pos - QPointF(offset.x(), 0));
//         break;
//     case MousePosition::BOTTOM: set_geometry_func(this->old_size + QSize(0, -offset.y()),
//                 this->position());
//         break;
//     case MousePosition::BOTTOMRIGHT: set_geometry_func(this->old_size - QSize(offset.x(), offset.y()),
//                 this->position());
//         break;
//     default:
//         break;
//     }
// }

// void FramelessWindow::mousePressEvent(QMouseEvent *event) {
//     this->start_pos = event->globalPosition();
//     this->old_pos = this->position();
//     this->old_size = this->size();
//     event->ignore();
//     QQuickWindow::mousePressEvent(event);
// }
// void FramelessWindow::mouseReleaseEvent(QMouseEvent *event) {
//     this->old_pos = this->position();
//     QQuickWindow::mouseReleaseEvent(event);
// }
// void FramelessWindow::mouseMoveEvent(QMouseEvent *event) {
//     QPointF pos = event->position();
//     if (event->buttons()&Qt::LeftButton) {
//         //改变大小
//         this->setWindowGeometry(pos);
//     } else {
//         this->mouse_pos = this->getMousePos(pos);
//         this->setCursorIcon();
//     }
//     QQuickWindow::mouseMoveEvent(event);
// }
#include "framelesswindow.h"
#include <QCursor>

FramelessWindow::FramelessWindow(QWindow* parent) : QQuickWindow(parent) {
    this->setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowMinMaxButtonsHint);
}

void FramelessWindow::updateCursorIcon() {
    switch (m_mousePosition) {
    case MousePosition::TOPLEFT:
    case MousePosition::BOTTOMRIGHT:
        this->setCursor(Qt::SizeFDiagCursor);
        break;
    case MousePosition::TOP:
    case MousePosition::BOTTOM:
        this->setCursor(Qt::SizeVerCursor);
        break;
    case MousePosition::TOPRIGHT:
    case MousePosition::BOTTOMLEFT:
        this->setCursor(Qt::SizeBDiagCursor);
        break;
    case MousePosition::LEFT:
    case MousePosition::RIGHT:
        this->setCursor(Qt::SizeHorCursor);
        break;
    case MousePosition::TITLEBAR:
        this->setCursor(Qt::ArrowCursor);
        break;
    default:
        this->unsetCursor();
        break;
    }
}

FramelessWindow::MousePosition FramelessWindow::getMousePosition(const QPointF& pos) {
    int x = pos.x();
    int y = pos.y();
    int w = this->width();
    int h = this->height();



    // 检查边框区域（用于缩放）
    if (x >= 0 && x <= m_borderWidth && y >= 0 && y <= m_borderWidth) {
        return MousePosition::TOPLEFT;
    } else if (x >= w - m_borderWidth && x <= w && y >= 0 && y <= m_borderWidth) {
        return MousePosition::TOPRIGHT;
    } else if (x >= m_borderWidth && x <= w - m_borderWidth && y >= 0 && y <= m_borderWidth) {
        return MousePosition::TOP;
    } else if (x >= 0 && x <= m_borderWidth && y >= m_borderWidth && y <= h - m_borderWidth) {
        return MousePosition::LEFT;
    } else if (x >= w - m_borderWidth && x <= w && y >= m_borderWidth && y <= h - m_borderWidth) {
        return MousePosition::RIGHT;
    } else if (x >= 0 && x <= m_borderWidth && y >= h - m_borderWidth && y <= h) {
        return MousePosition::BOTTOMLEFT;
    } else if (x >= w - m_borderWidth && x <= w && y >= h - m_borderWidth && y <= h) {
        return MousePosition::BOTTOMRIGHT;
    } else if (x >= m_borderWidth && x <= w - m_borderWidth && y >= h - m_borderWidth && y <= h) {
        return MousePosition::BOTTOM;
    }
    // 检查是否在标题栏区域（用于移动窗口）
    if (y >= m_borderWidth && y <= m_titleBarHeight && x >= m_borderWidth && x <= w - m_borderWidth) {
        return MousePosition::TITLEBAR;
    }

    return MousePosition::NORMAL;
}

void FramelessWindow::handleWindowResize(const QPointF& globalMousePos) {
    QPointF delta = globalMousePos - m_startGlobalPos;
    QRect newGeometry = QRect(m_startWindowPos, m_startWindowSize);

    switch (m_mousePosition) {
    case MousePosition::TOPLEFT:
        newGeometry.setTopLeft(newGeometry.topLeft() + delta.toPoint());
        break;
    case MousePosition::TOP:
        newGeometry.setTop(newGeometry.top() + delta.y());
        break;
    case MousePosition::TOPRIGHT:
        newGeometry.setTopRight(newGeometry.topRight() + QPoint(delta.x(), delta.y()));
        break;
    case MousePosition::LEFT:
        newGeometry.setLeft(newGeometry.left() + delta.x());
        break;
    case MousePosition::RIGHT:
        newGeometry.setRight(newGeometry.right() + delta.x());
        break;
    case MousePosition::BOTTOMLEFT:
        newGeometry.setBottomLeft(newGeometry.bottomLeft() + QPoint(delta.x(), delta.y()));
        break;
    case MousePosition::BOTTOM:
        newGeometry.setBottom(newGeometry.bottom() + delta.y());
        break;
    case MousePosition::BOTTOMRIGHT:
        newGeometry.setBottomRight(newGeometry.bottomRight() + delta.toPoint());
        break;
    default:
        return;
    }

    // 确保窗口不小于最小尺寸
    if (newGeometry.width() < minimumWidth()) {
        if (m_mousePosition == MousePosition::LEFT ||
                m_mousePosition == MousePosition::TOPLEFT ||
                m_mousePosition == MousePosition::BOTTOMLEFT) {
            newGeometry.setLeft(newGeometry.right() - minimumWidth());
        } else {
            newGeometry.setWidth(minimumWidth());
        }
    }

    if (newGeometry.height() < minimumHeight()) {
        if (m_mousePosition == MousePosition::TOP ||
                m_mousePosition == MousePosition::TOPLEFT ||
                m_mousePosition == MousePosition::TOPRIGHT) {
            newGeometry.setTop(newGeometry.bottom() - minimumHeight());
        } else {
            newGeometry.setHeight(minimumHeight());
        }
    }
    // 应用新的几何尺寸
    this->setGeometry(newGeometry);
}

void FramelessWindow::handleWindowMove(const QPointF& globalMousePos) {
    QPointF delta = globalMousePos - m_startGlobalPos;
    QPoint newPos = m_startWindowPos + delta.toPoint();
    this->setPosition(newPos);
}

void FramelessWindow::mousePressEvent(QMouseEvent* event) {
    if (event->button() == Qt::LeftButton) {
        m_startGlobalPos = event->globalPosition();
        m_startLocalPos = event->position();
        m_startWindowPos = this->position();
        m_startWindowSize = this->size();

        m_mousePosition = getMousePosition(m_startLocalPos);

        if (m_mousePosition == MousePosition::TITLEBAR) {
            m_isMoving = true;
        } else if (m_mousePosition != MousePosition::NORMAL) {
            m_isResizing = true;
        }
    }

    QQuickWindow::mousePressEvent(event);
}

void FramelessWindow::mouseReleaseEvent(QMouseEvent* event) {
    m_isMoving = false;
    m_isResizing = false;
    m_mousePosition = MousePosition::NORMAL;
    this->unsetCursor();

    QQuickWindow::mouseReleaseEvent(event);
}

void FramelessWindow::mouseMoveEvent(QMouseEvent* event) {
    QPointF localPos = event->position();
    QPointF globalPos = event->globalPosition();

    if (!m_isMoving && !m_isResizing) {
        // 更新鼠标光标
        m_mousePosition = getMousePosition(localPos);
        updateCursorIcon();
    } else if (m_isMoving) {
        // 移动窗口
        handleWindowMove(globalPos);
    } else if (m_isResizing) {
        // 调整窗口大小
        handleWindowResize(globalPos);
    }

    QQuickWindow::mouseMoveEvent(event);
}

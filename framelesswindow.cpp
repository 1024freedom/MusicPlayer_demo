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
        // this->unsetCursor();
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
    //调用基类先触发qml的鼠标样式变化
    QQuickWindow::mouseMoveEvent(event);
    //qml如果更改了鼠标样式，说明此时鼠标位置与窗口活动无关
    if (cursor().shape() != Qt::ArrowCursor) {
        return;
    }

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


}
void FramelessWindow::mouseDoubleClickEvent(QMouseEvent *event) {
    if (event->button() == Qt::LeftButton) {
        MousePosition mousePos = getMousePosition(event->position());
        if (mousePos == MousePosition::TITLEBAR) {
            if (this->visibility() == QWindow::Maximized) {
                this->showNormal();
            } else {
                this->showMaximized();
            }
            event->accept();
            return;
        }
    }
    QQuickWindow::mouseDoubleClickEvent(event);
}







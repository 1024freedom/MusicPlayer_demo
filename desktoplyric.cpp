#include "desktoplyric.h"

DesktopLyric::DesktopLyric(QWindow* parent): QQuickWindow(parent) {

    setColor(Qt::transparent);
    this->setFlags(Qt::Window | Qt::FramelessWindowHint | Qt::WindowMinMaxButtonsHint);

}

void DesktopLyric::handleWindowMove(const QPointF& globalMousePos) {
    QPointF delta = globalMousePos - m_startGlobalPos;
    QPoint newPos = m_startWindowPos + delta.toPoint();
    this->setPosition(newPos);
}

void DesktopLyric::mousePressEvent(QMouseEvent* event) {
    if (event->button() == Qt::LeftButton) {
        m_startGlobalPos = event->globalPosition();
        m_startWindowPos = this->position();
        m_isMoving = true;
    }
    QQuickWindow::mousePressEvent(event);
}

void DesktopLyric::mouseReleaseEvent(QMouseEvent* event) {
    m_isMoving = false;
    QQuickWindow::mouseReleaseEvent(event);
}

void DesktopLyric::mouseMoveEvent(QMouseEvent* event) {
    QPointF globalPos = event->globalPosition();
    if (m_isMoving) {
        // 移动窗口
        handleWindowMove(globalPos);
    }
    QQuickWindow::mouseMoveEvent(event);
}

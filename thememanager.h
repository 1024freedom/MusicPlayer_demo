#ifndef THEMEMANAGER_H
#define THEMEMANAGER_H

#include <QObject>
#include <QSettings>
#include <QVariantMap>
#include <QVariantList>

class ThemeManager: public QObject {
    Q_OBJECT
    Q_PROPERTY(int m_currentIndex READ getM_currentIndex WRITE setM_currentIndex NOTIFY m_currentIndexChanged FINAL)
    Q_PROPERTY(QVariantMap m_currentTheme READ getM_currentTheme NOTIFY m_currentThemeChanged FINAL)
    Q_PROPERTY(QVariantList m_themes READ getM_themes NOTIFY m_themesChanged FINAL)

public:
    explicit ThemeManager(QObject* parent = nullptr);

    int getM_currentIndex()const;
    QVariantMap getM_currentTheme()const;
    QVariantList getM_themes() const;

    Q_INVOKABLE void initialize();
    Q_INVOKABLE void setM_currentIndex(int index);
    Q_INVOKABLE void setM_themes();
    Q_INVOKABLE void saveSettings();
    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE QVariantMap getM_indexofTheme(int index)const;
signals:
    void m_currentIndexChanged();
    void m_currentThemeChanged();
    void m_themesChanged();
private:
    QSettings m_settings;
    int m_currentIndex;
    QVariantList m_themes;
    QVariantMap m_currentTheme;
};

#endif // THEMEMANAGER_H

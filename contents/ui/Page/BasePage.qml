/*
    SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>
    SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2015-2018 Eike Hein <hein@kde.org>
    SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2026 Barnak Zlatko <EQuilibriumOS>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.plasmoid
import org.kde.plasma.workspace.trianglemousefilter

FocusScope {
    id: root

    property real preferredSidebarWidth: implicitSidebarWidth
    property real preferredSidebarHeight: implicitSidebarHeight

    property alias sidebarComponent: sidebarLoader.sourceComponent
    property alias sidebarItem: sidebarLoader.item
    property alias contentAreaComponent: contentAreaLoader.sourceComponent
    property alias contentAreaItem: contentAreaLoader.item

    property alias implicitSidebarWidth: sidebarLoader.implicitWidth
    property alias implicitSidebarHeight: sidebarLoader.implicitHeight

    implicitWidth: preferredSidebarWidth + separator.implicitWidth + contentAreaLoader.implicitWidth
    implicitHeight: Math.max(preferredSidebarHeight, contentAreaLoader.implicitHeight)

    // 1. LEVA STRANA: Sadržaj / Aplikacije sada dolaze na levu stranu
    Loader {
        id: contentAreaLoader
        focus: true
        anchors {
            top: parent.top
            left: parent.left
            right: separator.left
            bottom: parent.bottom
        }

        Keys.onTabPressed: event => {
            (kickoff.isPaneOrderReversed ? sidebarLoader : kickoff.footer.nextItemInFocusChain())
                .forceActiveFocus(Qt.TabFocusReason)
        }
        Keys.onBacktabPressed: event => {
            (kickoff.isPaneOrderReversed ? kickoff.header.avatar : sidebarLoader)
                .forceActiveFocus(Qt.BacktabFocusReason)
        }
        Keys.onLeftPressed: event => {
            sidebarLoader.forceActiveFocus();
        }
        Keys.onRightPressed: event => {
            sidebarLoader.forceActiveFocus();
        }
        Keys.onUpPressed: event => {
            kickoff.searchField.forceActiveFocus(Qt.BacktabFocusReason);
        }
        Keys.onDownPressed: event => {
            (kickoff.isPaneOrderReversed ? kickoff.footer.tabBar : kickoff.footer.leaveButtons.nextItemInFocusChain())
                .forceActiveFocus(Qt.TabFocusReason)
        }
    }

    // Separator između sadržaja i sidebara
    Rectangle {
        id: separator
        anchors.top: parent.top
        anchors.right: sidebarFilter.left
        anchors.bottom: parent.bottom
        implicitWidth: Plasmoid.configuration.separatorLineWidth
        color: Plasmoid.configuration.separatorLineColor
    }

    // 2. DESNA STRANA: Sidebar sa kategorijama sada dolazi na desnu stranu
    TriangleMouseFilter {
        id: sidebarFilter
        active: Plasmoid.configuration.isUpdateOnHover
        anchors {
            top: parent.top
            right: parent.right
            bottom: parent.bottom
        }
        implicitWidth: root.preferredSidebarWidth
        implicitHeight: root.preferredSidebarHeight
        blockFirstEnter: true

        Loader {
            id: sidebarLoader
            anchors.fill: parent

            Keys.onTabPressed: event => {
                (kickoff.isPaneOrderReversed ? kickoff.footer.nextItemInFocusChain() : contentAreaLoader)
                    .forceActiveFocus(Qt.TabFocusReason);
            }
            Keys.onBacktabPressed: event => {
                (kickoff.isPaneOrderReversed ? contentAreaLoader : kickoff.header.pinButton)
                    .forceActiveFocus(Qt.BacktabFocusReason);
            }
            Keys.onLeftPressed: event => {
                contentAreaLoader.forceActiveFocus();
            }
            Keys.onRightPressed: event => {
                contentAreaLoader.forceActiveFocus();
            }
            Keys.onUpPressed: event => {
                kickoff.header.nextItemInFocusChain()
                    .forceActiveFocus(Qt.BacktabFocusReason);
            }
            Keys.onDownPressed: event => {
                (kickoff.isPaneOrderReversed ? kickoff.footer.leaveButtons.nextItemInFocusChain() : kickoff.footer.tabBar)
                    .forceActiveFocus(Qt.TabFocusReason);
            }
        }
    }
}

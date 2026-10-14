/*
 * SPDX-FileCopyrightText: 2021 Mikel Johnson <mikel5764@gmail.com>
 * SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
 * SPDX-FileCopyrightText: 2026 Barnak Zlatko <EQuilibriumOS>
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PComponents
import org.kde.plasma.private.kicker as Kicker

import org.kde.plasma.extras as PExtras
import org.kde.plasma.plasmoid

import "../Helper"
import "../View"

EmptyPage {
    id: root

    readonly property int defaultIndex: kickoff.startWidth
    property real preferredSidebarWidth: Math.max(footer.tabBar.implicitWidth, applicationsPage.implicitWidth) + kickoff.backgroundMetrics.spacing * 2

    // Raspored u RowLayout-u: 1. Desna strana (sada levo), 2. Aplikacije (sredina), 3. Levi meni / Sidebar (sada desno)
    contentItem: RowLayout {
        id: splitView
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        // --- 1. PRVI DIO (LEVO): Bivša desna strana ---
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: 380

            BasePage {
                id: rightBasePage
                anchors.fill: parent

                sidebarComponent: KickoffListView {
                    id: sidebar
                    isSidebar: true
                    focus: true
                    model: placesCategoryModel
                    delegate: KickoffListDelegate {
                        url: ""
                        description: ""
                        width: sidebar.availableWidth
                        isCategoryListItem: true
                        isMultilineText: false
                        background: PExtras.Highlight {
                            anchors.fill: parent
                            active: false
                            hovered: parent.mouseArea.containsMouse
                            visible: !Plasmoid.configuration.isUpdateOnHover
                                && !parent.isSeparator && !parent.ListView.isCurrentItem
                                && hovered
                        }
                    }
                }

                contentAreaComponent: KickoffListView {
                    id: contentArea
                    mainContentView: true
                    focus: true
                    objectName: "frequentlyUsedView"
                    model: switch (rightBasePage.sidebarItem.currentIndex) {
                        case 0: return kickoff.recentUsageModel
                    }
                    onActiveFocusChanged: if (activeFocus && count < 1) {
                        rightBasePage.sidebarItem.forceActiveFocus()
                    }
                }

                Binding {
                    target: kickoff
                    property: "sidebar"
                    value: rightBasePage.sidebarItem
                    when: rightBasePage.T.StackView.status === T.StackView.Active && rightBasePage.visible
                    restoreMode: Binding.RestoreBinding
                }
                Binding {
                    target: kickoff
                    property: "contentArea"
                    value: rightBasePage.contentAreaItem
                    when: rightBasePage.T.StackView.status === T.StackView.Active && rightBasePage.visible
                    restoreMode: Binding.RestoreBinding
                }
            }
        }



        // --- 2. DRUGI DIO (SREDINA): Aplikacije ---
        Item {
            id: leftContainer
            Layout.fillWidth: true
            Layout.fillHeight: true

            HorizontalStackView {
                id: stackView
                anchors.fill: parent
                focus: true
                movementTransitionsEnabled: true
                reverseTransitions: footer.tabBar.currentIndex === 1
                initialItem: applicationsPage

                ApplicationsPage {
                    id: applicationsPage
                    defaultIndex: root.defaultIndex
                    preferredSidebarWidth: leftContainer.width * 0.3
                }
                Component {
                    id: placesPage
                    PlacesPage {
                        preferredSidebarWidth: leftContainer.width * 0.3
                        preferredSidebarHeight: applicationsPage.implicitSidebarHeight
                    }
                }

                Connections {
                    target: footer.tabBar
                    function onCurrentIndexChanged() {
                        stackView.replace(footer.tabBar.currentIndex === 1 ? placesPage : applicationsPage)
                    }
                }
            }
        }
    }

    footer: PageFooter {
        id: footer
        isAtPlaces: root.defaultIndex === Global.placesIndex
        preferredTabBarWidth: root.preferredSidebarWidth

        Rectangle {
            anchors.fill: parent
            color: Kirigami.Theme.backgroundColor
            z: -1
        }

        Binding {
            target: kickoff
            property: "footer"
            value: footer
            restoreMode: Binding.RestoreBinding
        }

        Keys.onDownPressed: event => {}
    }
}

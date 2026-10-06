pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.UPower

// Laptop battery via UPower (needs the upower daemon)
Singleton {
    readonly property var device: UPower.displayDevice
    readonly property bool available: !!device && device.isLaptopBattery && device.isPresent
    readonly property int percent: available ? Math.round(device.percentage * 100) : 0
    readonly property bool charging: available && (device.state === UPowerDeviceState.Charging
                                                   || device.state === UPowerDeviceState.PendingCharge)
    readonly property bool full: available && device.state === UPowerDeviceState.FullyCharged
}

# Enable Screenshot — Silent Fork

This is an unofficial fork of [LSPosed/DisableFlagSecure](https://github.com/LSPosed/DisableFlagSecure), also known as **Enable Screenshot**.

It retains the upstream functionality for bypassing screenshot restrictions and screenshot/recording detection, and additionally suppresses the screenshot sound produced by Android SystemUI.

## Changes in this fork

Compared with upstream **v5.0.1**, this fork adds:

- Screenshot sound suppression in SystemUI
- Support for the standard AOSP screenshot sound path
- Fallback suppression for OEM implementations using `MediaPlayer`
- Fallback suppression for OEM implementations using `MediaActionSound`

The additional audio hooks are limited to the **SystemUI process** and do not globally mute `MediaPlayer` or camera sounds in other applications.

## Building

The project includes a Docker-based build environment.

Create `.build-signing.env` from the provided example and run:

`./build-docker.sh`

## Compatibility

### Tested

This fork has been confirmed working with:

- Android 17 / SDK 37
- Sony Xperia devices running Sony's near-AOSP Android firmware
- Vector 2.2 by JingMatrix
- Upstream/recommended LSPosed-compatible environments

Specifically tested on:

- Sony Xperia XQ-EC54 / XQ-GE54
- Android 16 / 17
- firmware `69.2.A.4.110` / `73.1.A.2.61`
- Vector 2.2

Other Sony devices have also been reported working.

### Upstream compatibility

The upstream project currently documents support for:

- Android 12–16
- Xiaomi HyperOS
- OPlus OS (ColorOS / Realme UI / OxygenOS)
- Samsung One UI

Upstream also states that unofficial LSPosed versions are not supported.

Those restrictions describe the **upstream project's support policy**. This fork is independently maintained and has been tested successfully on configurations outside that upstream support matrix, including Android 17 and JingMatrix Vector.

Compatibility outside the configurations listed as tested above is not guaranteed.

## Usage

1. Install the APK.
2. Enable the module in your LSPosed-compatible framework.
3. Select **only the recommended/default scope**.
4. Reboot the device.

Do not manually add ordinary applications such as banking apps to the module scope unless there is a specific reason to do so.

## Screenshot sound suppression

The upstream module removes or bypasses screenshot restrictions but does not suppress the screenshot sound on all devices.

This fork additionally hooks screenshot audio generation inside Android SystemUI.

OEM Android implementations may use different screenshot pipelines, so sound suppression may vary between devices and firmware versions.

## Upstream

Original project:

`LSPosed/DisableFlagSecure`

This fork is not affiliated with or endorsed by the upstream LSPosed project.

## License

This project remains licensed under the same license as the upstream project.

See `LICENSE` for details.

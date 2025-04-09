#!/bin/sh

# DEBUG mode
/usr/libexec/rc/bin/ewarn Debug release, installing additional tools

setup-apkrepos -1c
apk add vim htop efitools efi-mkuki sbsigntool sbctl

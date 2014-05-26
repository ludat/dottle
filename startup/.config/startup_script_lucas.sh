#!/bin/sh

echo Disable stupid interrupts
echo disable > /sys/firmware/acpi/interrupts/gpe06

## Check sensors

### Usage

This plugin is made to parse the value of the `sensors` command.

The arguments needed to run this script are :

.1 Line filter
.2 Matching n's value (when filter got multiple result)
.3 Temperature position on line
.4 Warning level
.5 Critical level

This can be difficult to understand so look at the exemples below.

### Exemples

So, my `sensors` result look like this :

```
coretemp-isa-0000
Adapter: ISA adapter
Package id 0:  +51.0°C  (high = +100.0°C, crit = +100.0°C)
Core 0:        +47.0°C  (high = +100.0°C, crit = +100.0°C)
Core 4:        +47.0°C  (high = +100.0°C, crit = +100.0°C)
Core 8:        +49.0°C  (high = +100.0°C, crit = +100.0°C)
Core 12:       +47.0°C  (high = +100.0°C, crit = +100.0°C)
Core 16:       +49.0°C  (high = +100.0°C, crit = +100.0°C)
Core 20:       +48.0°C  (high = +100.0°C, crit = +100.0°C)
Core 28:       +50.0°C  (high = +100.0°C, crit = +100.0°C)
Core 29:       +50.0°C  (high = +100.0°C, crit = +100.0°C)
Core 30:       +50.0°C  (high = +100.0°C, crit = +100.0°C)
Core 31:       +50.0°C  (high = +100.0°C, crit = +100.0°C)

acpitz-acpi-0
Adapter: ACPI interface
temp1:        +27.8°C

mt7921_phy0-pci-0400
Adapter: PCI adapter
temp1:        +48.0°C

nvme-pci-0100
Adapter: PCI adapter
Composite:    +43.9°C  (low  =  -0.1°C, high = +76.8°C)
                       (crit = +78.8°C)
```

First, I want the "Package id 0" sensor value.
So my line filter is gonna be `Package`.
As this value is only present one time in the output, the second argument is `1`.
The temperature value is the fourth value of the line (`4`).
I want the warning value to be `60` and `80` for the critical value.

So, for this sensor, the command will be :

```bash
./my_check_sensors.sh Package 1 4 60 80
```

I also want the motherboard sensors (mt7921_phy0-pci-0400) but the only 
filter available is `temp1` wich is present on two lines.
By putting the second argument value to 2, the script will get `temp1` second value !

So, for this sensor, the command will be :

```bash
./my_check_sensors.sh temp1 2 2 60 80
```

### Limitations

- Value is treated as Celsius
- `sensors` is not tested

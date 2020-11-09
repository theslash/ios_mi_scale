**iOS MI Scale**

Read weight measurement from a Xiaomi Mi Scale 1st Gen.

Clone in Xcode and run on your device.
Only works on iPhones, because the health app is necessary.

Before you can store the weight in Health you have to authorize, with the lower right button.

**How it works**
- Scan for Bluetooth LE devices with service "181B"
- Check if characteristic "2A9C" is present
- Subscribe to notifications for this characteristic and read the data

**Weight Data**   
2A9C data looks like this:

[2, 164, 233, 7, 1, 1, 2, 44, 56, 255, 255, 160, 62]

Last two values and first are important.
If bit 0 of the first byte is 0 the weigt is stored in metric.  
You need the following calculation to get the weight:
((Byte 13 * 256) + Byte12) * 0.005


Todo:
- provide all icon PNG's
- edit app so that it waits for byte 10+11 which change when wheight on scale stops changing


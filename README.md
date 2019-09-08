# Wi-Fi Position Tracker
This is the initial version of a position tracking software based on Wi-Fi.

## How to capture packets
### Raspberry Pi 3B
Download the "Kali Linux RaspberryPi 2 (v1.2), 3 and 4 64-Bit" from [here](offensive-security.com/kali-linux-arm-images/).

After flashing it to a SDCard and booting it in your Raspberry Pi 3B, run:

```
airmon-ng check kill
airmon-ng start wlan0
airodump-ng -w rasp --output-format="pcap" wlan0mon
```

The captured packets file should be named in the format 'rasp-01.cap'.

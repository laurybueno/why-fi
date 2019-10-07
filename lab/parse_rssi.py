# "parse_rssi" by solsticedhiver
# https://github.com/nikharris0/probemon/issues/9#issuecomment-454500364
def parse_rssi(packet):
    # parse dbm_antsignal from radiotap header
    # borrowed from python-radiotap module
    packet = bytes(packet)
    radiotap_header_fmt = '<BBHI'
    radiotap_header_len = struct.calcsize(radiotap_header_fmt)
    version, pad, radiotap_len, present = struct.unpack_from(radiotap_header_fmt, packet)

    start = radiotap_header_len
    bits = [int(b) for b in bin(present)[2:].rjust(32, '0')]
    bits.reverse()
    if bits[5] == 0:
        return 0

    while present & (1 << 31):
        present, = struct.unpack_from('<I', packet, start)
        start += 4
    offset = start
    if bits[0] == 1:
        offset = (offset + 8 -1) & ~(8-1)
        offset += 8
    if bits[1] == 1:
        offset += 1
    if bits[2] == 1:
        offset += 1
    if bits[3] == 1:
        offset = (offset + 2 -1) & ~(2-1)
        offset += 4
    if bits[4] == 1:
        offset += 2
    # Use a try except block to avoid errors when there are no bytes on the expected pointer
    try:
        dbm_antsignal, = struct.unpack_from('<b', packet, offset)
    except:
        return None
    return dbm_antsignal
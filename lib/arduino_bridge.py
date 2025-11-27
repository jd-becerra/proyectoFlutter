import serial
import requests
import time

PORT = "COM7"
BAUD = 9600

BASE = "https://proyecto-6c537-default-rtdb.firebaseio.com/parking"
ENTRIES = BASE + "/entries.json"
EXITS = BASE + "/exits.json"
TOTAL = BASE + "/total_spots.json"
OCCUPANCY = BASE + "/current_occupancy.json"

ser = serial.Serial(PORT, BAUD)


def fb_get(path):
    r = requests.get(path)
    return r.json()


def fb_set(path, value):
    requests.put(path, json=value)


def fb_increment(path):
    value = fb_get(path) or 0
    value += 1
    fb_set(path, value)
    return value


while True:
    try:
        raw = ser.readline().decode(errors="ignore").strip()
        if raw not in ("1", "2"):
            continue

        event = int(raw)

        total_spots = fb_get(TOTAL) or 0
        occupancy = fb_get(OCCUPANCY) or 0

        if event == 1:
            print("ENTRY detected")

            if occupancy < total_spots:
                occupancy += 1
                fb_set(OCCUPANCY, occupancy)
                fb_increment(ENTRIES)
                print(f"Car entered → occupancy = {occupancy}/{total_spots}")
            else:
                print("ENTRY ignored → parking FULL")

        elif event == 2:
            print("EXIT detected")

            if occupancy > 0:
                occupancy -= 1
                fb_set(OCCUPANCY, occupancy)
                fb_increment(EXITS)
                print(f"Car exited → occupancy = {occupancy}/{total_spots}")
            else:
                print("EXIT ignored → occupancy already 0")

    except Exception as e:
        print("Error:", e)
        time.sleep(1)
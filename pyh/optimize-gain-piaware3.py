#!/usr/bin/python2.7
""" Inspired by a bunch of guys at http://discussions.flightaware.com/ads-b-flight-tracking-f21/gain-adjustment-t37172.html
"""

from __future__ import print_function
import argparse, os, socket, threading
from subprocess import Popen, PIPE
from time import time, sleep
from datetime import datetime
from select import select
try:
    import queue
except:
    import Queue as queue # For Python 2.x


parser = argparse.ArgumentParser()
parser.add_argument('-t', dest='testtime', type=int, default=62, help="Seconds for each test")
parser.add_argument('-n', dest='testsnum', type=int, default=5, help="Number of tests to perform")
parser.add_argument('-s', dest='server', type=str, default='localhost',  help="hostname for data feeder, default 'localhost'", )
parser.add_argument('-p', dest='port', type=int, default=30003, help="port, default 30003")
parser.add_argument('-g', dest='gains', type=str, default="-10 36.4 38.6 40.2 42.1 44.5 48.0 49.6", help="list of strings with gains to test")
parser.add_argument('-c', dest='config', default='/boot/piaware-config.txt', help="path to config file, default '/boot/piaware-config.txt'",)
parser.add_argument('-r', dest='grepstr', default='rtlsdr-gain', help="gain settings string in config, default 'rtlsdr-gain'")
parser.add_argument('-v', dest='verbose', help="verbose output", action='count')
parser.add_argument('-d', dest='dryrun', action='store_true', help='runs the script without actually changing the gain')
parser.add_argument('--delim', type=str, default='\t', help="delimiter to seperate output")
parser.set_defaults(dryrun=False)
args = parser.parse_args()

def date(): # Returns UTC date and time in default linux format.
    return datetime.strftime(datetime.utcnow(), '%a %b %d %H:%M:%S UTC %Y')

def get_gain(cmd):
    process = Popen(cmd, shell=True, stdout=PIPE) # To use a pipe with the subprocess module, you have to pass shell=True
    (result, err) = process.communicate()
    process.wait() # Wait for process to finish
    return result.rstrip().decode('ascii').split()[1]

gains = args.gains.split()
gains.sort()
gains.reverse()

if __name__ == '__main__':
    if not os.path.isfile(args.config):
        exit('Cannot find configfile %s' % args.config)
    command = (('type "%s" | find "%s"' if os.name == 'nt' else 'cat %s | grep %s') % (args.config, args.grepstr))
    gain_old = get_gain(command)
    results = {gain: [0, 0, 0, []] for gain in gains} #msgs, positions, aircount, aircrafts
    print(date(), 'Starting with gain', gain_old, 'and arguments', args)

    for i in range(args.testsnum):
        if args.verbose:
            print("GAIN", "MSG", "POS", "ADR", '{0: >7}'.format("TIME"), "Test %s of %s" % (i + 1, args.testsnum), sep=args.delim)
        for gain in gains:
            if os.name == 'nt':
                #TODO: Create handler that monitors configfile changes on remote linux system and waits for gain change
                pass
            elif not args.dryrun:
                cmd = "piaware-config rtlsdr-gain %s" % gain
                process = Popen(cmd, shell=True, stdout=PIPE, stderr=PIPE)
                (result, err) = process.communicate()
                process.wait()  # Wait for process to finish
                if args.verbose >= 2:
                    print(result.rstrip(), err.rstrip())
                os.system("sudo systemctl restart dump1090-fa")

            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            timestart = time()

            con = sock.connect_ex((args.server, args.port))
            while con:
                con = sock.connect_ex((args.server, args.port))
                sleep(0.2)
                assert time() - timestart < 5, "Connection to %s:%s timedout after 5 seconds" % (args.server, args.port)

            # sock.setblocking(False)
            timestart, telegrams, positions, aircrafts, data = time(), 0, 0, [], b''
            while time() - timestart < args.testtime:
                ready = select([sock], [], [], 0.1) # use a non-blocking recv(), or a blocking recv() / select() with a very short timeout.
                if ready[0]:
                    data += sock.recv(32)
                if b'\r\n' in data:
                    pos = data.index(b'\r\n')
                    data = data[pos + 2:]
                    line = data[:pos].decode(encoding='ascii')
                    telegrams += 1  # Hits reported. Number of updates from aircraft to receiver - regardless of update content.
                    cols = line.split(',')
                    if len(cols) > 4:
                        # Positions reported. Number of aircraft positions reported to receiver.
                        positions += 1 if cols[1] == '3' else 0
                        if cols[4] not in aircrafts:
                            # Number of ICAO 24-bit addresses (Mode-S "hex codes") seen by receiver.
                            # Read more here: en.wikipedia.org/wiki/Aviation_transponder_interrogation_modes
                            aircrafts.append(cols[4])
            sock.close()
            results[gain][3].append(aircraft for aircraft in aircrafts if aircraft not in results[gain][3])
            results[gain][0] += telegrams
            results[gain][1] += positions
            results[gain][2] = len(results[gain][3])
            if args.verbose:
                (telegrams, positions, aircrafts) = results[gain][:3]
                print(gain, telegrams, positions, aircrafts, '{:7.2f}'.format(time() - timestart), sep=args.delim)


    print("\n%s ===Totals===", date())
    print(date(), "GAIN", "MSG", "POS", "ADR", "TIME", sep='\t')
    for gain in gains:
        (telegrams, positions, aircrafts) = results[gain][:3]
        print(gain, telegrams, positions, aircrafts, sep=args.delim)

    if os.name != 'nt' and not args.dryrun:
        os.system("piaware-config rtlsdr-gain %s" % gain)
        os.system("sudo systemctl restart dump1090-fa")
        os.system("sudo systemctl status dump1090-fa -l")

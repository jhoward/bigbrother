import pybb.data.dataio as dataio
import numpy as np
import matplotlib.pyplot as mpl
import operator
import datetime

files = ["../../data/traffic/counts/025A207P.txt", \
        "../../data/traffic/counts/006G283P.txt", \
        "../../data/traffic/counts/225A9P.txt", \
        "../../data/traffic/counts/270A39S.txt", \
        "../../data/traffic/counts/070A270P.txt", \
        "../../data/traffic/counts/070A277S.txt"]

other_file_location = "../../data/other/broncos.txt"
event_length = 11
before = 9

def strip_data_days(d, t, valid_days = \
                    ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]):
    """Strip out data to only a specific set of days.
    """
    conv_times = []
    for i in range(len(t)):
        if t[i].strftime("%a") in valid_days:
            conv_times.append(i)

    conv_data = d[conv_times]
    conv_times = t[conv_times]
    
    return conv_data, conv_times


def index_sort(data):
    tmp = sorted(enumerate(data), key=operator.itemgetter(1))
    tmp = [i[0] for i in tmp]
    return tmp


def strip_data_std(d, t, num_std = 3):
    avg_data = np.average(d, axis = 0)
    res = d - avg_data
    total_res = np.sum(np.abs(res), axis = 1)
    
    std = total_res.std()
    index = []
    for i in range(len(total_res)):
        if total_res[i] <= num_std * std:
            index.append(i)
            
    d = d[index]
    t = t[index]
    
    return d, t


def parse_events(data, times, event_times):
    striped = []
    remaining = range(len(times))
    striped_events = []
    
    for t in event_times:
        tmp_event = t.date()
        for j in range(len(times)):
            tmp_time = times[j].date()
            
            if tmp_event == tmp_time:
                striped.append(tmp_event)
                striped_events.append(data[j, :])
                remaining.remove(j)
                break
                
    striped_events = np.array(striped_events)
    remaining_times = np.array(remaining)
    striped_times = np.array(striped)
    remaining_events = data[remaining]
    
    return striped_events, remaining_events, striped_times, remaining_times

def parse_traffic_times(data, times, event_times, before = 2, length = 5):
    
    events = []
    etimes = []

    for t in event_times:
        tmp_event = t.date()
        for j in range(len(times)):
            tmp_time = times[j].date()
            if tmp_event == tmp_time:
                events.append(list(data[j, t.hour - before:\
                                    t.hour - before + length]))
                etimes.append(tmp_event)
                
    np.array(events)
    np.array(etimes)
    return events, etimes


if __name__ == "__main__":
    
    etimes = []
    rtimes = []
    edata = []
    rdata = []
    times = []
    data = []
    eres = []
    eres_avg = []
    
    event_data, event_times = \
                    dataio.load_other_data(other_file_location, datatype = 'f')
    
    for f in files:
        d, t = dataio.load_traffic_data(f)
        d, t = strip_data_days(d, t, ["Sun"])
        #d, t = strip_data_std(d, t, 3)
        times.append(t)
        data.append(t)
        ed, rd, et, rt = parse_events(d, t, event_times)
        print len(ed)
        print len(rd)
        ed, et = strip_data_std(ed, et, 3)
        rd, rt = strip_data_std(rd, rt, 3)
        etimes.append(et)
        edata.append(ed)
        rtimes.append(rt)
        rdata.append(rd)
        rd_avg = np.average(rd, axis = 0)
        eres_tmp = ed - rd_avg
        eres.append(eres_tmp)
        eres_avg.append(np.average(eres_tmp, axis=0))
        
    xdata = range(24)
    mpl.subplot(111)
    
    for p in eres_avg[1:]:
        mpl.plot(xdata, p, 'k', alpha = 0.4)
    mpl.plot(xdata, eres_avg[0], 'r', linewidth = 2)

    mpl.xlim([0, 23])

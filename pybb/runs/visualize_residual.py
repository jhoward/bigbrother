import pybb.data.dataio as dataio
import pybb.math.analysis as analysis
import numpy as np
import matplotlib.pyplot as mpl
import operator
import datetime

files = [#"../../data/traffic/counts/025A207P.txt", \
        "../../data/traffic/counts/006G283P.txt"]#, \
        #"../../data/traffic/counts/225A9S.txt", \
        #"../../data/traffic/counts/270A39P.txt", \
        #"../../data/traffic/counts/070A270P.txt", \
        #"../../data/traffic/counts/070A277P.txt"]
        
other_file_location = "../../data/other/broncos.txt"
event_length = 11
before = 9

def check(d):
    ar = .7283
    ma = .1183
    sma = -.8572
    i = 24
    s = 24
    
    p = d[i - s + 1] + ar * (d[i] - d[i - s]) - ma * (d[i] - p[i])
    
    return p

def arima(d):
    ar = 0.7110
    ma = 0.0909
    sma = -0.8569
    s = 24
    
    p = np.array(d, dtype="f")
    
    for i in range(s, len(p) - 1):
        p[i + 1] = d[i - (s - 1)] + \
                    ar * (d[i] -  d[i - s]) - \
                    ma * (d[i] - p[i]) - \
                    sma * (d[i - (s - 1)] - p[i - (s - 1)]) + \
                    ma * sma * (d[i - s] - p[i - s])
    return p


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
    
    return striped_times, remaining_times, striped_events, remaining_events
    

def combine_data(data, times, other_data, other_times):
    d = []
    t = []
    od = []
    ot = []
    
    for i in range(len(times)):
        tmp_date = times[i].date()
        for j in range(len(other_times)):
            tmp_other_date = other_times[j].date()
            
            if tmp_date == tmp_other_date:
                d.append(data[i])
                t.append(times[i])
                od.append(other_data[j])
                ot.append(other_times[j])
    
    return np.array(d), np.array(od), np.array(t)
                

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

    event_data, event_times = \
                    dataio.load_other_data(other_file_location, datatype = 'f')

    data, times = dataio.load_traffic_data(files[0])
    sd, st = strip_data_days(data, times, ["Sun"])

    sun_data, sun_times = strip_data_days(data, times, ["Sun"])
    sd, st = strip_data_std(sun_data, sun_times, 4)
    sun_avg = np.average(sd, axis = 0)
    sun_res = sun_data - sun_avg

    sun_1d = np.reshape(sun_data, -1)
    sun_avg_1d = np.resize(sun_avg, sun_data.size)
    ps = arima(sun_1d)

    mase = analysis.mase(sun_1d, sun_avg_1d)
    mape = analysis.mape(sun_1d, sun_avg_1d)
    
    print "Mean Mase:", mase
    print "Mean Mape:", mape
    
    mase = analysis.mase(sun_1d, ps)
    mape = analysis.mape(sun_1d, ps)
    
    print "SARIMA Mase:", mase
    print "SARIMA Mape:", mape
    
    
    """
    xdata = range(24)
    mpl.subplot(111)
    
    for p in weekend_res[0:300]:
        mpl.plot(xdata, p, 'k', alpha = 0.2)
    #mpl.plot(xdata, data_avg, 'r', linewidth = 3)

    mpl.xlim([0, 23])
    """

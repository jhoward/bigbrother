function [train, valid, test, trainTimes, validTimes, testTimes] = cutdata(data)
%cut data from the datastruct and return a series of arrays of times and
%data

    totalDays = floor(size(data.data, 2) / data.blocksInDay);
    
    trainStart = 1;
    trainEnd = floor(totalDays * MyConstants.TRAIN_PERCENT) * data.blocksInDay;
    validStart = trainEnd + 1;
    validEnd = floor(totalDays * MyConstants.VALID_PERCENT) * data.blocksInDay + trainEnd;
    testStart = validEnd + 1;
    testEnd = floor(totalDays * MyConstants.TEST_PERCENT) * data.blocksInDay + validEnd;
    
    train = data.data(:, trainStart:trainEnd);
    trainTimes = data.data(:, trainStart:trainEnd);
    valid = data.data(:, validStart:testEnd);
    validTimes = data.data(:, validStart:testEnd);
    test = data.data(:, validStart:testEnd);
    testTimes = data.data(:, validStart:testEnd);
end
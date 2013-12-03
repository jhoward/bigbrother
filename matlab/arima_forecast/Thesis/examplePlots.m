clear all

dataSet = 3;

load(MyConstants.HORIZON_DATA_LOCATIONS{dataSet});
load(MyConstants.BCF_RESULTS_LOCATIONS{dataSet});
load(MyConstants.FILE_LOCATIONS_CLEAN{dataSet});

fStart = data.blocksInDay * 1;
fEnd = data.blocksInDay * 12;
if dataSet == 2
    fStart = data.blocksInDay * 1;
    fEnd = data.blocksInDay * 10;
elseif dataSet == 3
    fStart = data.blocksInDay * 10; %Used if the datasets are too large to just 
    fEnd = data.blocksInDay * 26;   %test with a small portion
end

%need to extract the pertinent parts of the forecast to use for saving
testData = data.testData(fStart:fEnd);

exampleWidth = 50;
index = 200;
horizon = 3;

while (index + exampleWidth) < size(testData, 2)
    plot(testData(1, index:index + exampleWidth), 'Color', [0 0 0]);
    hold on
    plot(horizons.svm{MyConstants.TESTDATA_CELL_INDEX}{horizon}(index:index + exampleWidth), 'Color', [0 0 1]);
    plot(bcfResults.improvedTest{horizon}(index:index + exampleWidth), 'Color', [1 0 0]);
    xlim([1 (exampleWidth + 1)]);
    
    waitforbuttonpress;
    index = index + exampleWidth;
    hold off;
end

%TODO also plot the probability examples
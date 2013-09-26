classdef MyConstants
    properties (Constant = true)
        TRAIN_PERCENT = 0.6;
        VALID_PERCENT = 0.2;
        TEST_PERCENT = 0.2;
        
        IMAGE_XSIZE = 1000;
        IMAGE_YSIZE = 650;
        
        PLOT_DAYS = {'Sunday', 'Monday', 'Tuesday', 'Wednesday', ...
                        'Thursday', 'Friday', 'Saturday'};
        FONT_TYPE = 'Helvetica';
        FILE_LOCATIONS_CLEAN = {'./data/merlDataClean.mat', ...
                          './data/brownDataClean.mat', ...
                          './data/denverDataClean.mat', ...
                          './data/simulatedDataClean.mat'};
        FILE_LOCATIONS_RAW = {'./data/merlData.mat', ...
                          './data/brownData_01_06.mat', ...
                          './data/denverData.mat', ...
                          './data/simulatedData.mat'};
                      
        DATASET_SENSOR = [59, 21, 1, 1];
        
        DATA_SETS = {'Merl', 'Brown', 'Denver', 'Simulated'};
        MODEL_NAMES = {'TSNN', 'ARIMA', 'Average', 'SVM', 'NARNET'}
        THESIS_LOCATION = '/Users/jahoward/Documents/Dropbox/jim_thesis/';
    
        
        %MODEL PARAMETERS
        ARIMA_PARAMETERS = {[1 0 1 0 78 1], [0 0 1 0 78 3]};
        
        %Old constants
        %FILE_LOCATIONS_MAC = {'/Users/jahoward/Documents/Dropbox/Projects/bigbrother/data/building/merl/data/merlDataClean.mat'}
        %IMAGE_LOCATION = '../../images/'
    
        
        
    end
end


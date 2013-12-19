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
        FILE_LOCATIONS_CLEAN = {'./data/merlDataThesisDay.mat', ...
                          './data/brownDataThesisDay.mat', ...
                          './data/denverDataThesisDay.mat'};
        FILE_LOCATIONS_RAW = {'./data/merlData.mat', ...
                          './data/brownData_01_06.mat', ...
                          './data/denverDataRaw.mat'};
                      
        DATASET_SENSOR = [59, 21, 4];
        
        DATA_SETS = {'Merl', 'Brown', 'Denver'};
        
        %Uses the "model" parameter to determine which model is used
        MODEL_NAMES = {'TDNN', 'ARIMA', 'Average', 'SVM', 'NARNET', 'BCF'}
        METRIC_NAMES = {'RMSE', 'MASE', 'PONAN', 'RMSEONAN', 'SSEONAN'}
        THESIS_LOCATION = '/Users/jahoward/Documents/Dropbox/jim_thesis/';
        
        HORIZON_DATA_LOCATIONS = ...
            {'/Users/jahoward/Documents/Dropbox/jim_thesis/data/horizons_merl.mat', ...
            '/Users/jahoward/Documents/Dropbox/jim_thesis/data/horizons_brown.mat', ...
            '/Users/jahoward/Documents/Dropbox/jim_thesis/data/horizons_denver.mat'}
    
        MODELS_DATA_LOCATIONS = ...
            {'/Users/jahoward/Documents/Dropbox/jim_thesis/data/models_merl.mat', ...
            '/Users/jahoward/Documents/Dropbox/jim_thesis/data/models_brown.mat', ...
            '/Users/jahoward/Documents/Dropbox/jim_thesis/data/models_denver.mat'}
        
        BCF_RESULTS_LOCATIONS = ...
            {'/Users/jahoward/Documents/Dropbox/jim_thesis/data/bcf_merl.mat', ...
            '/Users/jahoward/Documents/Dropbox/jim_thesis/data/bcf_brown.mat', ...
            '/Users/jahoward/Documents/Dropbox/jim_thesis/data/bcf_denver.mat'}
        
        TRAINDATA_CELL_INDEX = 10;
        TESTDATA_CELL_INDEX = 11;
        TEST_PROBS_INDEX = 12;
        
        %MODEL PARAMETERS
        ARIMA_PARAMETERS = {[1 1 1 0 78 3], [1 1 0 0 78 1], [1 1 2 0 48 1]};
        SVM_PARAMETERS = {'-s 4 -t 2 -q', '-s 4 -t 2 -q', '-s 4 -t 2 -q'};
        SVM_WINDOW = {5, 5, 5};
        TDNN_PARAMETERS = {[10, 8], [10, 8], [6, 6]};
    end
end

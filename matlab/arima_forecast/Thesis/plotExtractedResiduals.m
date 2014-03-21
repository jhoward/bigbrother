%plotExtractedResiduals
fig = figure('Position', [100, 100, 100 + 1200, 100 + 550]);

pData = results.ABCF.arima.clusters{1};
width = size(pData, 2);
x = linspace(1, width, width);
xflip = [x(1 : end - 1) fliplr(x)];
for j = 1:size(pData, 1)
    y = pData(j, :);
    yflip = [y(1 : end - 1) fliplr(y)];
    patch(xflip, yflip, 'r', 'EdgeAlpha', 0.15, 'FaceColor', 'none');
    hold on
end

xlabel('Time step', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
ylabel('Residual value', 'FontSize', 18, 'FontName', MyConstants.FONT_TYPE)
title('Top 10% extracted residuals from Arima forecasts on Merl Dataset', 'FontSize', 24, 'FontName', MyConstants.FONT_TYPE);

export_fig(strcat(MyConstants.FINAL_IMAGE_DIR, ...
        'arima_abcf_extracted_residuals_', MyConstants.DATA_SETS{dataSet}, '.png'), fig, '-transparent', '-nocrop');

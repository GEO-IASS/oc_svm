%DRAW_PROPERTIES draw the data series of properties import and the ratio
%
%   RATIO_MAP = DRAW_PROPERTIES( PROPERTIES, RATIO_HISTORY_LENGTH )
%
%   This function expects the keys in the PROPERTIES Map as stated below.
%   Each key is a time series data with the values in the second column.
%   The data series are plotted, together with the ratio. The parameter
%   RATIO_HISTORY_LENGTH (default: 10) determines the number of data points
%   used for the ratio calculation.
% 
%   The returned RATIO_MAP holds for each key the ratio for every time
%pro   point.
%
%   EXPECTED KEYS: {'thresholds', 'offsets', 'outlier_distances',
%   'number_of_outliers'}
%
%   INPUT:
%       - PROPERTIES: A containers.Map() object with the above specified
%       keys, with the value in each second column.
%       - RATIO_HISTORY_LENGTH: The number of data points to use for ratio
%       calculation. Default: 10
%
%   OUTPUT:
%       - RATIO_MAP: The calculated ratio values for each key of PROPERTIES
%
%   USAGE EXAMPLE:
%   > load('data/matlab_properties_d-d-u-u_roemer-1_all-data_block-80_step-1.mat');
%     ratios = draw_properties(properties);
%     ratios_long = draw_properties(properties, 20);
%
%   The `properties` var is expected to be generated by apply_inc_svdd.
%   (Note that the 'load' command puts the values in the 'properties' var)
%
%   This function uses addaxis to plot multiple y axis.
%   See: http://www.mathworks.com/matlabcentral/fileexchange/9016-addaxis


function ratio_map = draw_properties( properties, ratio_history_length )

    if nargin < 2
        ratio_history_length = 10;
    end

    thresholds          = properties('thresholds');
    offsets             = properties('offsets');
    outlier_distances   = properties('outlier_distances');
    number_of_outliers  = properties('number_of_outliers');
    
    data_x         = thresholds(:, 1);
    
    % Calculate all the ratios
    ratio_map = containers.Map();
    property_keys = keys(properties);
    
    for i = 1 : length(property_keys)
        
        key = property_keys(i);
        series = cell2mat(values(properties,key));
        ratio_series = zeros(1, size(series, 1));
        
        for j = 1 : size(series, 1)
            ratio_series(j) = ratio(series(1:j,:), ratio_history_length); 
        end
        
        ratio_map(char(key)) = [series(:,1) series(:,2) ratio_series'];
    end
   
    % figure(1) should hold the mapped data and outlier shape
    % figure(2) will hold Offsets and Thresholds data
    % figure(3) will hold Outlier distance and number data
    % figure(4) should hold the original data
    
    % Let the white drawing area take all the available space of the window
    set(0,'DefaultAxesLooseInset',[0.03,0,0.05,0])
    
    % Set plot location and size
    screenSize = get(0,'ScreenSize');
    plot_width  = screenSize(3);
    plot_height = screenSize(4) / 4;
    
    % Offsets and Thresholds raw values
    sfigure(2); clf; axis auto;
    set(gcf,'Position',[0 (plot_height * 1.3) plot_width plot_height]);
    
    ratio_offsets    = ratio_map('offsets');
    ratio_thresholds = ratio_map('thresholds');
    
    plot(data_x, offsets(:,3), 'k-' );
    addaxis(data_x, thresholds(:,3), 'r-' );
    addaxis(data_x, ratio_offsets(:,3), 'm--' );
    addaxis(data_x, ratio_thresholds(:,3), 'b--' );
    
    addaxislabel(1, 'Offsets');
    addaxislabel(2, 'Thresholds');
    addaxislabel(3, 'Ratio offsets');
    addaxislabel(4, 'Ratio thresholds');
    
    legend('Offsets', 'Thresholds', 'Ratio offsets', 'Ratio thresholds');
    
    set(gca, 'XTick', 0:roundn(length(data_x)/50, 1):data_x(end, 1));
    
    % Outlier distances and number
    sfigure(3); clf; axis auto;
    set(gcf,'Position',[0 0 plot_width plot_height]);
    
    ratio_distances = ratio_map('outlier_distances');
    ratio_number    = ratio_map('number_of_outliers');
    
    plot(data_x, outlier_distances(:,3), 'k-' );
    addaxis(data_x, number_of_outliers(:,3), 'r-' );
    addaxis(data_x, ratio_distances(:,3), 'm--' );
    addaxis(data_x, ratio_number(:,3), 'b--' );
    
    addaxislabel(1, 'Outlier distances');
    addaxislabel(2, 'Number of outliers');
    addaxislabel(3, 'Ratio distances');
    addaxislabel(4, 'Ratio number');
    
    legend('Outlier distances', 'Number of outliers', 'Ratio distances', 'Ratio number');    
    
    set(gca, 'XTick', 0:roundn(length(data_x)/50, 1):data_x(end, 1));
end
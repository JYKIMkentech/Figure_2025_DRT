clc; clear; close all;

%% Description
% This script performs DRT estimation with uncertainty analysis using bootstrap.
% It loads the data, allows the user to select a dataset and type, and then
% performs the DRT estimation and uncertainty analysis for each scenario 
% within the selected data. The estimated gamma values are plotted with 
% uncertainty bounds and compared with the true gamma.

%% Graphic Parameters
axisFontSize = 14;
titleFontSize = 12;
legendFontSize = 12;
labelFontSize = 12;

%% Load Data

% Set the file path to the directory containing the .mat files
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\';
mat_files = dir(fullfile(file_path, '*.mat'));

% Load all .mat files
for file = mat_files'
    load(fullfile(file_path, file.name));
end

%% Parameters

% List of datasets and their names
AS_structs = {AS1_1per_new, AS1_2per_new, AS2_1per_new, AS2_2per_new};
AS_names   = {'AS1_1per_new', 'AS1_2per_new', 'AS2_1per_new', 'AS2_2per_new'};
Gamma_structs = {Gamma_unimodal, Gamma_unimodal, Gamma_bimodal, Gamma_bimodal};

% Select the dataset to process
fprintf('Available datasets:\n');
for idx = 1:length(AS_names)
    fprintf('%d: %s\n', idx, AS_names{idx});
end
dataset_idx = input('Select a dataset to process (enter the number): ');

% Set the selected dataset
AS_data   = AS_structs{dataset_idx};
AS_name   = AS_names{dataset_idx};
Gamma_data = Gamma_structs{dataset_idx};

% Extract the list of available types from the selected dataset
types = unique({AS_data.type});

% Type selection
disp('Select a type:');
for i = 1:length(types)
    fprintf('%d. %s\n', i, types{i});
end
type_idx = input('Enter the type number: ');
selected_type = types{type_idx};

% Extract data for the selected type
type_indices = find(strcmp({AS_data.type}, selected_type));
type_data    = AS_data(type_indices);

num_scenarios = length(type_data);  % Number of scenarios

% Extract scenario numbers
SN_list = [type_data.SN];

% Display selected dataset, type, and scenario numbers
fprintf('Selected dataset: %s\n', AS_name);
fprintf('Selected type: %s\n', selected_type);
fprintf('Scenario numbers: ');
disp(SN_list);

% Color matrix for plotting
c_mat = lines(num_scenarios);

% Set OCV and R0 (modify if necessary)
OCV = 0;
R0 = 0.1;

%% DRT and Uncertainty Estimation

% True gamma values
gamma_discrete_true = Gamma_data.gamma';  % Convert to column vector
theta_true          = Gamma_data.theta';  % Convert to column vector

% Variables to store DRT estimation results
gamma_est_all      = cell(num_scenarios, 1);
V_est_all          = cell(num_scenarios, 1);
V_sd_all           = cell(num_scenarios, 1);
theta_discrete_all = cell(num_scenarios, 1);
gamma_lower_all    = cell(num_scenarios, 1);
gamma_upper_all    = cell(num_scenarios, 1);

% Variables to store uncertainty estimation results
num_resamples = 100;  % Number of bootstrap resamples
gamma_resample_all_scenarios = cell(num_scenarios, 1);

% Loop over scenarios
for s = 1:num_scenarios
    fprintf('Processing %s Type %s Scenario %d/%d...\n', AS_name, ...
            selected_type, s, num_scenarios);

    % Get data for the current scenario
    scenario_data = type_data(s);
    V_sd   = scenario_data.V(:);          % Measured voltage (column vector)
    ik     = scenario_data.I(:);          % Current (column vector)
    t      = scenario_data.t(:);          % Time vector
    dt     = scenario_data.dt;           % dt value
    dur    = scenario_data.dur;          % Duration value
    n      = scenario_data.n;            % Number of RC elements
    lambda = scenario_data.Lambda_hat;   % Regularization parameter (?)

    % DRT estimation
    [gamma_est, V_est, theta_discrete, tau_discrete, ~] = ...
        DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);

    % Store results (note: gamma_est, gamma_est_all{s} as row vectors)
    gamma_est_all{s}      = gamma_est';  % gamma_est is likely Nx1 -> make it 1xN
    %V_est_all{s}         = V_est';     % If needed, keep
    V_sd_all{s}           = V_sd';       % Just storing original measured data
    theta_discrete_all{s} = theta_discrete;  % We'll handle dimension at plotting

    % Uncertainty estimation using bootstrap
    [gamma_lower, gamma_upper, gamma_resample_all] = ...
        bootstrap_uncertainty(t, ik, V_sd, lambda, n, dt, dur, OCV, R0, num_resamples);

    % Store uncertainty results (note: also row vectors for consistency)
    gamma_lower_all{s} = gamma_lower;  % check if your function returns row or col
    gamma_upper_all{s} = gamma_upper;
    gamma_resample_all_scenarios{s} = gamma_resample_all;
end

%% Plot Results
% -------------------------------------------------------------------------
% (1) Plot all scenarios together (shaded region + line)
figure('Name', [AS_name, ' Type ', selected_type, ': DRT Comparison (All)'], ...
       'NumberTitle', 'off');
hold on;
for s = 1:num_scenarios
    theta_s   = theta_discrete_all{s}(:).';        
    gamma_est = gamma_est_all{s}(:).';             
    gamma_l   = gamma_lower_all{s}(:).';           
    gamma_u   = gamma_upper_all{s}(:).';          
    plotColor = c_mat(s, :);

    a = theta_s;
    b = fliplr(theta_s);
    c = [theta_s, fliplr(theta_s)];
    d = gamma_u;
    e = fliplr(gamma_u);
    f = gamma_l;
    g = [gamma_l, fliplr(gamma_u)];

    % Shaded region 
    fill([theta_s, fliplr(theta_s)], ...
         [gamma_l, fliplr(gamma_u)], ...
         plotColor, 'FaceAlpha', 1, 'EdgeColor', 'none');

    % Estimated gamma (solid line)
    plot(theta_s, gamma_est, 'LineWidth', 1.5, 'Color', plotColor, ...
         'DisplayName', ['Scenario ', num2str(SN_list(s))]);
end

% --- Plot the true gamma as a reference ---
% true gamma도 만약 행 벡터로 바꾸고 싶다면:
theta_true_row = theta_true(:).';
gamma_true_row = gamma_discrete_true(:).';
plot(theta_true_row, gamma_true_row, 'k-', 'LineWidth', 2, ...
     'DisplayName', 'True \gamma');

hold off;
xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
ylabel('\gamma',                'FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Estimated \gamma (All Scenarios)'], ...
      'FontSize', titleFontSize);
set(gca, 'FontSize', axisFontSize);
legend('Location', 'Best', 'FontSize', legendFontSize);
ylim([0 inf]);

% -------------------------------------------------------------------------
% (2) Plot selected scenarios
disp('Available scenario numbers:');
disp(SN_list);
selected_scenarios = input('Enter scenario numbers to plot (e.g., [1,2,3]): ');

figure('Name', [AS_name, ' Type ', selected_type, ': Selected Scenarios'], ...
       'NumberTitle', 'off');
hold on;
for idx_s = 1:length(selected_scenarios)
    s = find(SN_list == selected_scenarios(idx_s), 1);
    if ~isempty(s)
        % Prepare data
        theta_s   = theta_discrete_all{s}(:).';  
        gamma_est = gamma_est_all{s}(:).';      
        gamma_l   = gamma_lower_all{s}(:).';    
        gamma_u   = gamma_upper_all{s}(:).';    
        plotColor = c_mat(s, :);

        fill([theta_s, fliplr(theta_s)], ...
             [gamma_l, fliplr(gamma_u)], ...
             plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

        plot(theta_s, gamma_est, 'LineWidth', 1.5, 'Color', plotColor, ...
             'DisplayName', ['Scenario ', num2str(SN_list(s))]);
    else
        warning('Scenario %d not found in the data', selected_scenarios(idx_s));
    end
end

% Plot true gamma
plot(theta_true_row, gamma_true_row, 'k-', 'LineWidth', 2, ...
     'DisplayName', 'True \gamma');
hold off;
xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
ylabel('\gamma', 'FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Selected Scenarios'], ...
      'FontSize', titleFontSize);
set(gca, 'FontSize', axisFontSize);
legend('Location', 'Best', 'FontSize', legendFontSize);
ylim([0 inf]);

% -------------------------------------------------------------------------
% (3) Individual scenario subplots
figure('Name', [AS_name, ' Type ', selected_type, ': Individual DRTs'], ...
       'NumberTitle', 'off');
num_cols = 5;                           % Number of subplot columns
num_rows = ceil(num_scenarios / num_cols);

for s = 1:num_scenarios
    subplot(num_rows, num_cols, s);

    % Prepare data
    theta_s   = theta_discrete_all{s}(:).';  
    gamma_est = gamma_est_all{s}(:).';      
    gamma_l   = gamma_lower_all{s}(:).';    
    gamma_u   = gamma_upper_all{s}(:).';    
    plotColor = c_mat(s, :);

    % Shaded region
    fill([theta_s, fliplr(theta_s)], ...
         [gamma_l, fliplr(gamma_u)], ...
         plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    hold on;
    % Solid line (estimated)
    plot(theta_s, gamma_est, 'LineWidth', 1.0, 'Color', plotColor);
    % True gamma
    plot(theta_true_row, gamma_true_row, 'k-', 'LineWidth', 1.5);
    hold off;

    xlabel('\theta', 'FontSize', labelFontSize);
    ylabel('\gamma', 'FontSize', labelFontSize);
    title(['Scenario ', num2str(SN_list(s))], 'FontSize', titleFontSize);
    set(gca, 'FontSize', axisFontSize);
    ylim([0 inf]);
end

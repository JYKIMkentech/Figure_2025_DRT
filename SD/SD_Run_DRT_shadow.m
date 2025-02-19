clc; clear; close all;

%% Description
% This script performs DRT estimation with uncertainty analysis using bootstrap.
% It loads the data, allows the user to select a dataset and type, and then
% performs the DRT estimation and uncertainty analysis for each scenario 
% within the selected data. 
% The 5%-95% confidence interval is shown as a shaded region, 
% and the line in the middle is the bootstrap-average gamma.

%% Graphic Parameters
axisFontSize   = 14;
titleFontSize  = 12;
legendFontSize = 12;
labelFontSize  = 12;

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
AS_structs    = {AS1_1per_new, AS1_2per_new, AS2_1per_new, AS2_2per_new};
AS_names      = {'AS1_1per_new', 'AS1_2per_new', 'AS2_1per_new', 'AS2_2per_new'};
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
Gamma_data= Gamma_structs{dataset_idx};

% Extract the list of available types from the selected dataset
types = unique({AS_data.type});

% Type selection
disp('Select a type:');
for i = 1:length(types)
    fprintf('%d. %s\n', i, types{i});
end
type_idx      = input('Enter the type number: ');
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
R0  = 0.1;

%% DRT and Uncertainty Estimation

% True gamma values
gamma_discrete_true = Gamma_data.gamma';  
theta_true          = Gamma_data.theta';  

% Variables to store DRT estimation results
gamma_est_all      = cell(num_scenarios, 1);
V_sd_all           = cell(num_scenarios, 1);
theta_discrete_all = cell(num_scenarios, 1);

% Variables to store uncertainty estimation results
num_resamples = 100;  % Number of bootstrap resamples
gamma_lower_all    = cell(num_scenarios, 1);
gamma_upper_all    = cell(num_scenarios, 1);
gamma_avg_all      = cell(num_scenarios, 1);   % ★ 부트스트랩 평균
gamma_resample_all_scenarios = cell(num_scenarios, 1);

% Loop over scenarios
for s = 1:num_scenarios
    fprintf('Processing %s Type %s Scenario %d/%d...\n', ...
            AS_name, selected_type, s, num_scenarios);

    % Get data for the current scenario
    scenario_data = type_data(s);
    V_sd   = scenario_data.V(:);  % Measured voltage
    ik     = scenario_data.I(:);  % Current
    t      = scenario_data.t(:);  % Time vector
    dt     = scenario_data.dt;    % dt value
    dur    = scenario_data.dur;   % Duration value
    n      = scenario_data.n;     % Number of RC elements
    lambda = scenario_data.Lambda_hat; % Regularization parameter

    % (1) DRT estimation (single pass)
    [gamma_est, V_est, theta_discrete, tau_discrete, ~] = ...
        DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);

    % Store main DRT results
    gamma_est_all{s}      = gamma_est';
    V_sd_all{s}           = V_sd';
    theta_discrete_all{s} = theta_discrete;

    % (2) Bootstrap uncertainty
    [gamma_lower, gamma_upper, gamma_resample_all] = ...
        bootstrap_uncertainty(t, ik, V_sd, lambda, n, dt, dur, OCV, R0, num_resamples);

    gamma_lower_all{s} = gamma_lower;
    gamma_upper_all{s} = gamma_upper;
    gamma_resample_all_scenarios{s} = gamma_resample_all;

    % ★ 부트스트랩 평균
    gamma_avg = mean(gamma_resample_all, 1);
    gamma_avg_all{s} = gamma_avg;
end

%% Plot Results
theta_true_row = theta_true(:).';
gamma_true_row = gamma_discrete_true(:).';

% -------------------------------------------------------------------------
% (1) Plot all scenarios together (shaded region + line = avg gamma)
figure('Name', [AS_name, ' Type ', selected_type, ': DRT Comparison (All)'], ...
       'NumberTitle', 'off');
hold on;
for s = 1:num_scenarios
    theta_s   = theta_discrete_all{s}(:).';  
    gamma_l   = gamma_lower_all{s}(:).';     
    gamma_u   = gamma_upper_all{s}(:).';     
    gamma_avg = gamma_avg_all{s}(:).';       % ★ 부트스트랩 평균 (라인)
    plotColor = c_mat(s, :);

    % Shaded region (5~95%)
    fill([theta_s, fliplr(theta_s)], ...
         [gamma_l, fliplr(gamma_u)], ...
         plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    % Line: bootstrap 평균
    plot(theta_s, gamma_avg, 'LineWidth', 1.5, 'Color', plotColor, ...
         'DisplayName', ['Scenario ', num2str(SN_list(s))]);

    % (Optional) If you want to see the original single-pass DRT estimate:
    % plot(theta_s, gamma_est_all{s}, '--', 'LineWidth', 1.0, ...
    %      'Color', plotColor);
end

% Plot the true gamma as a reference
plot(theta_true_row, gamma_true_row, 'k-', 'LineWidth', 2, ...
     'DisplayName', 'True \gamma');
hold off;
xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
ylabel('\gamma',                'FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Avg \gamma with 5%-95% CI (All)'], ...
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
        theta_s   = theta_discrete_all{s}(:).';  
        gamma_l   = gamma_lower_all{s}(:).';
        gamma_u   = gamma_upper_all{s}(:).';
        gamma_avg = gamma_avg_all{s}(:).';
        plotColor = c_mat(s, :);

        fill([theta_s, fliplr(theta_s)], ...
             [gamma_l, fliplr(gamma_u)], ...
             plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

        plot(theta_s, gamma_avg, 'LineWidth', 1.5, 'Color', plotColor, ...
             'DisplayName', ['Scenario ', num2str(SN_list(s))]);

        % (Optional) single-pass estimate
        % plot(theta_s, gamma_est_all{s}, '--', 'Color', plotColor);
    else
        warning('Scenario %d not found in the data', selected_scenarios(idx_s));
    end
end

plot(theta_true_row, gamma_true_row, 'k-', 'LineWidth', 2, ...
     'DisplayName', 'True \gamma');
hold off;
xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
ylabel('\gamma', 'FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Selected Scenarios (Avg & CI)'], ...
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
    theta_s   = theta_discrete_all{s}(:).';  
    gamma_l   = gamma_lower_all{s}(:).';
    gamma_u   = gamma_upper_all{s}(:).';
    gamma_avg = gamma_avg_all{s}(:).';
    plotColor = c_mat(s, :);

    % Shaded region (5~95%)
    fill([theta_s, fliplr(theta_s)], ...
         [gamma_l, fliplr(gamma_u)], ...
         plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    hold on;

    % Solid line: bootstrap 평균
    plot(theta_s, gamma_avg, 'LineWidth', 1.0, 'Color', plotColor);

    % True gamma
    plot(theta_true_row, gamma_true_row, 'k-', 'LineWidth', 1.5);
    hold off;

    xlabel('\theta', 'FontSize', labelFontSize);
    ylabel('\gamma', 'FontSize', labelFontSize);
    title(['Scenario ', num2str(SN_list(s))], 'FontSize', titleFontSize);
    set(gca, 'FontSize', axisFontSize);
    ylim([0 inf]);
end

%% (Optional) Find Indices where gamma_est is out of [gamma_lower, gamma_upper]
% 만약 single-pass DRT 추정치(gamma_est)가 신뢰구간을 벗어나는지를 확인하고자 한다면:
outOfBoundsIndices = cell(num_scenarios, 1);
for s = 1:num_scenarios
    gamma_est_vec   = gamma_est_all{s};   % single-pass estimate
    gamma_lower_vec = gamma_lower_all{s};
    gamma_upper_vec = gamma_upper_all{s};

    out_of_bounds_idx = find(gamma_est_vec < gamma_lower_vec | gamma_est_vec > gamma_upper_vec);
    outOfBoundsIndices{s} = out_of_bounds_idx;
end





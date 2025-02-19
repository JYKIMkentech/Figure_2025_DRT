clc; clear; close all;

%% Description
% This script performs DRT estimation with uncertainty analysis using bootstrap (inline).
% It loads the data, allows the user to select a dataset and type, and then
% performs the DRT estimation and uncertainty analysis for each scenario within the selected data.
% The estimated gamma values are plotted with uncertainty bounds (5%, 95%) 
% and the bootstrap average gamma is also shown.

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
gamma_discrete_true = Gamma_data.gamma';  % Convert to column vector
theta_true          = Gamma_data.theta';  % Convert to column vector

% Variables to store DRT estimation results
gamma_est_all        = cell(num_scenarios, 1);
V_sd_all             = cell(num_scenarios, 1);
theta_discrete_all   = cell(num_scenarios, 1);
gamma_lower_all      = cell(num_scenarios, 1);
gamma_upper_all      = cell(num_scenarios, 1);

% Variables to store uncertainty estimation results
num_resamples = 100;  % Number of bootstrap resamples
gamma_resample_all_scenarios = cell(num_scenarios, 1);
gamma_avg_all                = cell(num_scenarios, 1); % ★ 평균 gamma 저장

% Loop over scenarios
for s = 1:num_scenarios
    fprintf('Processing %s Type %s Scenario %d/%d...\n', ...
            AS_name, selected_type, s, num_scenarios);

    % Get data for the current scenario
    scenario_data = type_data(s);
    V_sd   = scenario_data.V(:);  % Measured voltage (column vector)
    ik     = scenario_data.I(:);  % Current (column vector)
    t      = scenario_data.t(:);  % Time vector
    dt     = scenario_data.dt;    % dt value
    dur    = scenario_data.dur;   % Duration value
    n      = scenario_data.n;     % Number of RC elements
    lambda = scenario_data.Lambda_hat; % Modify if necessary

    % (1) DRT estimation
    [gamma_est, V_est, theta_discrete, tau_discrete, ~] = ...
        DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);

    % Store results
    gamma_est_all{s}      = gamma_est';
    V_sd_all{s}           = V_sd';
    theta_discrete_all{s} = theta_discrete;

    % (2) Uncertainty estimation (Bootstrap) - INLINE
    % Initialize for bootstrap
    gamma_resample_all = zeros(num_resamples, n);

    for b = 1:num_resamples
        % Resample indices with replacement
        resample_idx = randsample(length(t), length(t), true);

        % Resampled data
        t_resampled   = t(resample_idx);
        ik_resampled  = ik(resample_idx);
        V_sd_resampled= V_sd(resample_idx);

        % Remove duplicates and sort
        [t_unique, unique_idx]   = unique(t_resampled);
        ik_unique      = ik_resampled(unique_idx);
        V_sd_unique    = V_sd_resampled(unique_idx);

        [t_sorted, sort_idx]     = sort(t_unique);
        ik_sorted       = ik_unique(sort_idx);
        V_sd_sorted     = V_sd_unique(sort_idx);

        % Recalculate dt_resampled
        dt_resampled = [t_sorted(1); diff(t_sorted)];

        % Re-run DRT estimation on the resampled data
        [gamma_boot, ~, ~, ~, ~] = ...
            DRT_estimation(t_sorted, ik_sorted, V_sd_sorted, ...
                           lambda, n, dt_resampled, dur, OCV, R0);

        gamma_resample_all(b, :) = gamma_boot';
    end

    % Compute percentile bounds (5%, 95%)
    gamma_percentiles = prctile(gamma_resample_all, [5 95]);
    gamma_lower_all{s} = gamma_percentiles(1, :);
    gamma_upper_all{s} = gamma_percentiles(2, :);

    % Compute average across all bootstrap samples
    gamma_avg_all{s} = mean(gamma_resample_all, 1);

    % Store the entire bootstrap set if needed
    gamma_resample_all_scenarios{s} = gamma_resample_all;
end

%% Plot Results

% (A) DRT comparison plot (all scenarios) with uncertainty & avg
figure('Name', [AS_name, ' Type ', selected_type, ': DRT Comparison with Uncertainty'], ...
       'NumberTitle', 'off');
hold on;
for s = 1:num_scenarios
    % Get theta_discrete for the scenario
    theta_s = theta_discrete_all{s};

    % Plot with uncertainty as error bars (Est + 5~95% CI)
    errorbar(theta_s, gamma_est_all{s}, ...
        gamma_est_all{s} - gamma_lower_all{s}, ...
        gamma_upper_all{s} - gamma_est_all{s}, ...
        '--', 'LineWidth', 1.5, 'Color', c_mat(s, :), ...
        'DisplayName', ['Scenario ', num2str(SN_list(s))]);

    % ★ Plot bootstrap average
    plot(theta_s, gamma_avg_all{s}, ':', 'LineWidth', 1.5, ...
         'Color', c_mat(s, :), ...
         'DisplayName', ['Scenario ', num2str(SN_list(s)), ' Avg']);
end
% True gamma
plot(theta_true, gamma_discrete_true, 'k-', 'LineWidth', 2, ...
     'DisplayName', 'True \gamma');
hold off;
xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
ylabel('\gamma', 'FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Estimated \gamma with Uncertainty'], ...
      'FontSize', titleFontSize);
set(gca, 'FontSize', axisFontSize);
legend('Location', 'Best', 'FontSize', legendFontSize);
ylim([0 inf])

% (B) Optionally plot selected scenarios
disp('Available scenario numbers:');
disp(SN_list);
selected_scenarios = input('Enter scenario numbers to plot (e.g., [1,2,3]): ');

figure('Name', [AS_name, ' Type ', selected_type, ': Selected Scenarios DRT Comparison with Uncertainty'], ...
       'NumberTitle', 'off');
hold on;
for idx_s = 1:length(selected_scenarios)
    s = find(SN_list == selected_scenarios(idx_s));
    if ~isempty(s)
        % Get theta_discrete for the scenario
        theta_s = theta_discrete_all{s};
        % Plot with uncertainty as error bars
        errorbar(theta_s, gamma_est_all{s}, ...
            gamma_est_all{s} - gamma_lower_all{s}, ...
            gamma_upper_all{s} - gamma_est_all{s}, ...
            '--', 'LineWidth', 1.5, 'Color', c_mat(s, :), ...
            'DisplayName', ['Scenario ', num2str(SN_list(s))]);

        % ★ Plot bootstrap average
        plot(theta_s, gamma_avg_all{s}, ':', 'LineWidth', 1.5, ...
             'Color', c_mat(s, :), ...
             'DisplayName', ['Scenario ', num2str(SN_list(s)), ' Avg']);
    else
        warning('Scenario %d not found in the data', selected_scenarios(idx_s));
    end
end
plot(theta_true, gamma_discrete_true, 'k-', 'LineWidth', 2, ...
     'DisplayName', 'True \gamma');
hold off;
xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
ylabel('\gamma', 'FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Estimated \gamma for Selected Scenarios'], ...
      'FontSize', titleFontSize);
set(gca, 'FontSize', axisFontSize);
legend('Location', 'Best', 'FontSize', legendFontSize);
ylim([0 inf])

% (C) Individual scenario plots
figure('Name', [AS_name, ' Type ', selected_type, ': Individual Scenario DRTs'], ...
       'NumberTitle', 'off');
num_cols = 5;  % Number of subplot columns
num_rows = ceil(num_scenarios / num_cols);  % Number of subplot rows

for s = 1:num_scenarios
    subplot(num_rows, num_cols, s);
    theta_s = theta_discrete_all{s};

    % Plot with uncertainty as error bars
    errorbar(theta_s, gamma_est_all{s}, ...
        gamma_est_all{s} - gamma_lower_all{s}, ...
        gamma_upper_all{s} - gamma_est_all{s}, ...
        'LineWidth', 1.0, 'Color', c_mat(s, :));
    hold on;

    % ★ Plot bootstrap average
    plot(theta_s, gamma_avg_all{s}, ':', 'LineWidth', 1.5, ...
         'Color', c_mat(s, :));

    % True gamma
    plot(theta_true, gamma_discrete_true, 'k-', 'LineWidth', 1.5);
    hold off;
    xlabel('\theta', 'FontSize', labelFontSize);
    ylabel('\gamma', 'FontSize', labelFontSize);
    title(['Scenario ', num2str(SN_list(s))], 'FontSize', titleFontSize);
    set(gca, 'FontSize', axisFontSize);
    ylim([0 inf])
end



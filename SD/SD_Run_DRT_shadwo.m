clc; clear; close all;

%% Description
% This script performs DRT estimation with uncertainty analysis using bootstrap.
% It loads the data, allows the user to select a dataset and type, and then
% performs the DRT estimation and uncertainty analysis for each scenario within the selected data.
% The estimated gamma values are plotted with shadow (fill) to represent uncertainty
% and compared with the true gamma.

%% Graphic Parameters
axisFontSize = 14;
titleFontSize = 12;
legendFontSize = 12;
labelFontSize = 12;

%% Load Data
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\';
mat_files = dir(fullfile(file_path, '*.mat'));
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
Gamma_data= Gamma_structs{dataset_idx};

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

num_scenarios = length(type_data);
SN_list       = [type_data.SN];

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
gamma_discrete_true = Gamma_data.gamma';  % Column vector
theta_true          = Gamma_data.theta';  % Column vector

% Prepare storage
gamma_est_all         = cell(num_scenarios, 1);
theta_discrete_all    = cell(num_scenarios, 1);
gamma_lower_all       = cell(num_scenarios, 1);
gamma_upper_all       = cell(num_scenarios, 1);

% Number of bootstrap resamples
num_resamples = 100;

% Loop over scenarios
for s = 1:num_scenarios
    fprintf('Processing %s Type %s Scenario %d/%d...\n', ...
        AS_name, selected_type, s, num_scenarios);

    % Get data for the current scenario
    scenario_data = type_data(s);
    V_sd = scenario_data.V(:);
    ik   = scenario_data.I(:);
    t    = scenario_data.t(:);
    dt   = scenario_data.dt;
    dur  = scenario_data.dur;
    n    = scenario_data.n;
    lambda = scenario_data.Lambda_hat;

    % --(1) DRT estimation--
    [gamma_est, ~, theta_discrete, ~, ~] = ...
        DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);

    gamma_est_all{s}      = gamma_est';
    theta_discrete_all{s} = theta_discrete;

    % --(2) Bootstrap for uncertainty--
    [gamma_lower, gamma_upper, ~] = ...
        bootstrap_uncertainty(t, ik, V_sd, lambda, n, dt, dur, OCV, R0, num_resamples);

    gamma_lower_all{s} = gamma_lower;
    gamma_upper_all{s} = gamma_upper;
end

%% (A) Plot: All scenarios
figure('Name', [AS_name, ' Type ', selected_type, ': DRT Comparison with Uncertainty'], ...
       'NumberTitle', 'off');
hold on;

for s = 1:num_scenarios
    % 각 시나리오에 대해 theta/gamma를 정렬
    theta_s_raw     = theta_discrete_all{s}(:);
    gamma_est_raw   = gamma_est_all{s}(:);
    gamma_low_raw   = gamma_lower_all{s}(:);
    gamma_up_raw    = gamma_upper_all{s}(:);

    % 오름차순 정렬
    [theta_s_sorted, idx_sort]  = sort(theta_s_raw);
    gamma_est_sorted            = gamma_est_raw(idx_sort);
    gamma_low_sorted            = gamma_low_raw(idx_sort);
    gamma_up_sorted             = gamma_up_raw(idx_sort);

    % 쉐도우(불확실성 구간) 채우기
    fill([theta_s_sorted; flipud(theta_s_sorted)], ...
         [gamma_low_sorted; flipud(gamma_up_sorted)], ...
         c_mat(s,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    % 중앙 추정선
    plot(theta_s_sorted, gamma_est_sorted, 'LineWidth', 1.5, ...
         'Color', c_mat(s,:), 'DisplayName', ['Scenario ', num2str(SN_list(s))]);
end

% True gamma
plot(theta_true, gamma_discrete_true, 'k-', 'LineWidth', 2, 'DisplayName', 'True \gamma');

hold off;
xlabel('\theta = ln(\tau [s])', 'FontSize', labelFontSize);
ylabel('\gamma', 'FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Estimated \gamma with Uncertainty'], ...
      'FontSize', titleFontSize);
set(gca, 'FontSize', axisFontSize);
legend('Location','best','FontSize',legendFontSize);
ylim([0, inf]);

%% (B) Plot: Selected scenarios only
disp('Available scenario numbers:');
disp(SN_list);
selected_scenarios = input('Enter scenario numbers to plot (e.g., [1,2,3]): ');

figure('Name', [AS_name, ' Type ', selected_type, ': Selected Scenarios DRT Comparison with Uncertainty'], ...
       'NumberTitle', 'off');
hold on;

for idx_s = 1:length(selected_scenarios)
    s = find(SN_list == selected_scenarios(idx_s));
    if isempty(s)
        warning('Scenario %d not found in the data.', selected_scenarios(idx_s));
        continue;
    end

    theta_s_raw     = theta_discrete_all{s}(:);
    gamma_est_raw   = gamma_est_all{s}(:);
    gamma_low_raw   = gamma_lower_all{s}(:);
    gamma_up_raw    = gamma_upper_all{s}(:);

    [theta_s_sorted, idx_sort] = sort(theta_s_raw);
    gamma_est_sorted = gamma_est_raw(idx_sort);
    gamma_low_sorted = gamma_low_raw(idx_sort);
    gamma_up_sorted  = gamma_up_raw(idx_sort);

    fill([theta_s_sorted; flipud(theta_s_sorted)], ...
         [gamma_low_sorted; flipud(gamma_up_sorted)], ...
         c_mat(s,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    plot(theta_s_sorted, gamma_est_sorted, 'LineWidth', 1.5, ...
         'Color', c_mat(s,:), 'DisplayName', ['Scenario ', num2str(SN_list(s))]);
end

plot(theta_true, gamma_discrete_true, 'k-', 'LineWidth', 2, 'DisplayName', 'True \gamma');
hold off;
xlabel('\theta = ln(\tau [s])','FontSize', labelFontSize);
ylabel('\gamma','FontSize', labelFontSize);
title([AS_name, ' Type ', selected_type, ': Estimated \gamma with Uncertainty for Selected Scenarios'], ...
      'FontSize', titleFontSize);
set(gca, 'FontSize', axisFontSize);
legend('Location','best','FontSize',legendFontSize);
ylim([0, inf]);

%% (C) Plot: Individual scenario subplots
figure('Name', [AS_name, ' Type ', selected_type, ': Individual Scenario DRTs'], ...
       'NumberTitle','off');
num_cols = 5;
num_rows = ceil(num_scenarios / num_cols);

for s = 1:num_scenarios
    subplot(num_rows, num_cols, s);

    theta_s_raw   = theta_discrete_all{s}(:);
    gamma_est_raw = gamma_est_all{s}(:);
    gamma_low_raw = gamma_lower_all{s}(:);
    gamma_up_raw  = gamma_upper_all{s}(:);

    [theta_s_sorted, idx_sort] = sort(theta_s_raw);
    gamma_est_sorted = gamma_est_raw(idx_sort);
    gamma_low_sorted = gamma_low_raw(idx_sort);
    gamma_up_sorted  = gamma_up_raw(idx_sort);

    fill([theta_s_sorted; flipud(theta_s_sorted)], ...
         [gamma_low_sorted; flipud(gamma_up_sorted)], ...
         c_mat(s,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    hold on;
    plot(theta_s_sorted, gamma_est_sorted, 'LineWidth', 1.0, 'Color', c_mat(s,:));
    plot(theta_true, gamma_discrete_true, 'k-', 'LineWidth', 1.5);
    hold off;

    xlabel('\theta', 'FontSize', labelFontSize);
    ylabel('\gamma', 'FontSize', labelFontSize);
    title(['Scenario ', num2str(SN_list(s))], 'FontSize', titleFontSize);
    set(gca, 'FontSize', axisFontSize);
    ylim([0, inf]);
end

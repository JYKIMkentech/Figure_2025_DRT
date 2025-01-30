%% RUN_SD_DRT_store_subplots_modified.m
clc; clear; close all;

%% (A) Description
% - 기존 DRT 추정 + 구조체 업데이트
% - 모든 시나리오(최대 10개 가정)를 2x5 subplot에 표시
% - switch 함수 대신 eval()로 원본 변수(AS1_1per_new 등)에 대입 + save
% - 마지막에 gamma_est ~ (gamma_lower, gamma_upper) 범위 확인
% - (추가) subplot에서 fill()를 이용해 불확실성 영역에 음영+투명도+경계선 표시

%% (B) Graphic Parameters
axisFontSize   = 14;
titleFontSize  = 12;
legendFontSize = 12;
labelFontSize  = 12;

%% (1) Load Data
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
mat_files = dir(fullfile(file_path, '*.mat'));
for file = mat_files'
    load(fullfile(file_path, file.name));
end

%% (2) Prepare references
AS_structs = {AS1_1per_new, AS1_2per_new, AS2_1per_new, AS2_2per_new};
AS_names   = {'AS1_1per_new','AS1_2per_new','AS2_1per_new','AS2_2per_new'};
Gamma_structs = {Gamma_unimodal, Gamma_unimodal, Gamma_bimodal, Gamma_bimodal};

fprintf('Available datasets:\n');
for idx = 1:length(AS_names)
    fprintf('%d: %s\n', idx, AS_names{idx});
end
dataset_idx = input('Select a dataset to process (enter the number): ');

AS_data    = AS_structs{dataset_idx}; 
AS_name    = AS_names{dataset_idx};   
Gamma_data = Gamma_structs{dataset_idx};

types = unique({AS_data.type});
disp('Select a type:');
for i = 1:length(types)
    fprintf('%d. %s\n', i, types{i});
end
type_idx = input('Enter the type number: ');
selected_type = types{type_idx};

type_indices = find(strcmp({AS_data.type}, selected_type));
type_data    = AS_data(type_indices);

num_scenarios = length(type_data);
SN_list = [type_data.SN];

fprintf('\n[INFO] Selected dataset: %s\n', AS_name);
fprintf('       Selected type: %s\n', selected_type);
fprintf('Scenario numbers: ');
disp(SN_list);

% 색상
c_mat = lines(num_scenarios);

% OCV, R0
OCV = 0;
R0  = 0.1;

%% (3) True gamma, theta
gamma_discrete_true = Gamma_data.gamma(:).';
theta_true          = Gamma_data.theta(:).';

%% (4) DRT Estimation & Uncertainty
gamma_est_all      = cell(num_scenarios,1);
theta_discrete_all = cell(num_scenarios,1);
gamma_lower_all    = cell(num_scenarios,1);
gamma_upper_all    = cell(num_scenarios,1);
gamma_resample_all = cell(num_scenarios,1);

num_resamples = 500;

for s = 1:num_scenarios
    fprintf('\nProcessing %s / type %s / scenario %d/%d...\n',...
        AS_name, selected_type, s, num_scenarios);

    scenario_data = type_data(s);

    V_sd   = scenario_data.V(:);
    ik     = scenario_data.I(:);
    t      = scenario_data.t(:);
    dt     = scenario_data.dt;
    dur    = scenario_data.dur;
    n      = scenario_data.n;
    lambda = 10;%scenario_data.Lambda_hat;

    % (a) DRT_estimation
    [gamma_est, V_est, theta_discrete, tau_discrete, ~] = ...
        DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);

    % (b) bootstrap
    [gamma_lower, gamma_upper, gamma_resamples] = ...
        bootstrap_uncertainty(t, ik, V_sd, lambda, n, dt, dur, OCV, R0, num_resamples);

    gamma_est_all{s}      = gamma_est(:);
    theta_discrete_all{s} = theta_discrete(:);
    gamma_lower_all{s}    = gamma_lower(:);
    gamma_upper_all{s}    = gamma_upper(:);
    gamma_resample_all{s} = gamma_resamples;
end

%% (5) Store new fields into type_data
for s = 1:num_scenarios
    type_data(s).theta           = theta_discrete_all{s};
    type_data(s).gamma_est       = gamma_est_all{s};
    type_data(s).gamma_lower     = gamma_lower_all{s};
    type_data(s).gamma_upper     = gamma_upper_all{s};
    type_data(s).gamma_resamples = gamma_resample_all{s};
end

%% (6) Reflect back to AS_data
for k = 1:num_scenarios
    AS_data(type_indices(k)).theta           = type_data(k).theta;
    AS_data(type_indices(k)).gamma_est       = type_data(k).gamma_est;
    AS_data(type_indices(k)).gamma_lower     = type_data(k).gamma_lower;
    AS_data(type_indices(k)).gamma_upper     = type_data(k).gamma_upper;
    AS_data(type_indices(k)).gamma_resamples = type_data(k).gamma_resamples;
end

%% (7) Plot in Subplot(2 x 5) with Shaded Uncertainty
num_cols = 5;
num_rows = 2;

figure('Name',[AS_name,' type ', selected_type,' - Subplot(2x5)'],...
       'NumberTitle','off');

for s = 1:num_scenarios
    subplot(num_rows, num_cols, s);

    th_s = theta_discrete_all{s}(:).';
    ge_s = gamma_est_all{s}(:).';
    gl_s = gamma_lower_all{s}(:).';
    gu_s = gamma_upper_all{s}(:).';
    plotColor = c_mat(s,:);  % 시나리오별 색상

    % (1) 불확실성 영역 (음영 + 투명도)
    fill([th_s, fliplr(th_s)], ...
         [gl_s, fliplr(gu_s)], ...
         plotColor, ...
         'FaceAlpha', 0.3, ...        % 투명도
         'EdgeColor', 'none');       % 테두리 없음
    hold on;

    % (2) 상하 경계선(점선) - 옵션
    plot(th_s, gl_s, '--', 'Color', plotColor, 'LineWidth', 1);
    plot(th_s, gu_s, '--', 'Color', plotColor, 'LineWidth', 1);

    % (3) 중앙 추정값(진한 선)
    %plot(th_s, ge_s, 'LineWidth',0.2, 'Color',plotColor);

    % (4) True gamma (검정 실선)
    plot(theta_true, gamma_discrete_true, 'k-','LineWidth',1.5);

    xlabel('\theta (ln(\tau))','FontSize',labelFontSize);
    ylabel('\gamma','FontSize',labelFontSize);
    title(['SN=', num2str(SN_list(s))], 'FontSize', titleFontSize);
    set(gca,'FontSize',axisFontSize);
    % ylim([0 inf]);  % <- 이거 해제하면 작은 값도 좀 더 보일 수 있음
    hold off;
end

%% (8) Check gamma_est within [gamma_lower, gamma_upper]
fprintf('\n=== Check gamma_est within [gamma_lower, gamma_upper] ===\n');
for s = 1:num_scenarios
    ge_s = gamma_est_all{s};
    gl_s = gamma_lower_all{s};
    gu_s = gamma_upper_all{s};

    inBounds = (ge_s >= gl_s) & (ge_s <= gu_s);
    if all(inBounds)
        fprintf('Scenario %d (SN=%d): all gamma_est in bounds.\n', s, SN_list(s));
    else
        nOut = sum(~inBounds);
        fprintf('Scenario %d (SN=%d): WARNING - %d elements out of bounds.\n',...
            s, SN_list(s), nOut);
    end
end

%% (9) Save with original variable name (no switch)
save_folder = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT';
save_filename = [AS_name, '.mat'];
save_path = fullfile(save_folder, save_filename);

% eval로 원본 변수명에 대입
eval([AS_name, ' = AS_data;']);
% 변수명을 save
eval(['save(''', save_path,''',''',AS_name,''',''-v7.3'');']);

fprintf('\n[INFO] Saved to %s\n', save_path);




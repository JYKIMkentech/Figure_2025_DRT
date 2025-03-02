%% RUN_SD_DRT_store_subplots_modified.m
clc; clear; close all;

%% (A) Description
% - 기존 DRT 추정 + 구조체 업데이트
% - 모든 시나리오(최대 10개 가정)를 2x5 subplot에 표시 (5% 시나리오 추가)
% - eval()을 통해 원본 변수(AS1_1per_new 등)에 대입 + save
% - 마지막에 gamma_est ~ [gamma_lower, gamma_upper] 범위 확인
% - fill()를 이용해 불확실성 영역(5~95%)에 음영 표시,
%   중앙선은 부트스트랩 평균(gamma_avg)로 함
% - 테두리 없애기('EdgeColor','none'), gamma_avg를 구조체에 저장
% - 1%,2%,3%,4%,5% 시나리오 모두 처리

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
% 1%,2%,3%,4%,5% 시나리오 추가
%  - 앞의 5개(AS1)는 Unimodal -> Gamma_unimodal
%  - 뒤의 5개(AS2)는 Bimodal  -> Gamma_bimodal
AS_structs = {
    AS1_1per_new, AS1_2per_new, AS1_3per_new, AS1_4per_new, AS1_5per_new, ...
    AS2_1per_new, AS2_2per_new, AS2_3per_new, AS2_4per_new, AS2_5per_new};

AS_names = {
    'AS1_1per_new','AS1_2per_new','AS1_3per_new','AS1_4per_new','AS1_5per_new', ...
    'AS2_1per_new','AS2_2per_new','AS2_3per_new','AS2_4per_new','AS2_5per_new'};

Gamma_structs = {
    Gamma_unimodal, Gamma_unimodal, Gamma_unimodal, Gamma_unimodal, Gamma_unimodal, ...
    Gamma_bimodal,  Gamma_bimodal,  Gamma_bimodal,  Gamma_bimodal,  Gamma_bimodal};

fprintf('Available datasets:\n');
for idx = 1:length(AS_names)
    fprintf('%d: %s\n', idx, AS_names{idx});
end

dataset_idx = input('Select a dataset to process (enter the number 1~10): ');
if isempty(dataset_idx) || dataset_idx < 1 || dataset_idx > length(AS_names)
    error('Invalid dataset index.');
end

AS_data    = AS_structs{dataset_idx};
AS_name    = AS_names{dataset_idx};
Gamma_data = Gamma_structs{dataset_idx};

% type 고르기
types = unique({AS_data.type});
disp('Select a type:');
for i = 1:length(types)
    fprintf('%d. %s\n', i, types{i});
end
type_idx = input('Enter the type number: ');
if isempty(type_idx) || type_idx < 1 || type_idx > length(types)
    error('Invalid type index.');
end
selected_type = types{type_idx};

type_indices = find(strcmp({AS_data.type}, selected_type));
type_data    = AS_data(type_indices);

num_scenarios = length(type_data);
SN_list = [type_data.SN];

fprintf('\n[INFO] Selected dataset: %s\n', AS_name);
fprintf('       Selected type: %s\n', selected_type);
fprintf('Scenario numbers: '); disp(SN_list);

% 색상
c_mat = lines(num_scenarios);

% OCV, R0
OCV = 0;
R0  = 0.1;

%% (3) True gamma, theta
gamma_discrete_true = Gamma_data.gamma(:).';  % row vector
theta_true          = Gamma_data.theta(:).';

%% (4) DRT Estimation & Uncertainty
gamma_est_all      = cell(num_scenarios,1);
theta_discrete_all = cell(num_scenarios,1);
gamma_lower_all    = cell(num_scenarios,1);
gamma_upper_all    = cell(num_scenarios,1);
gamma_resample_all = cell(num_scenarios,1);
gamma_avg_all      = cell(num_scenarios,1);  % ★ 부트스트랩 평균 추가 저장

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
    lambda = scenario_data.Lambda_hat; % ex) D,E,F -> lambda = 10 등등
    
    %% (a) DRT_estimation (단일 추정)
    [gamma_est, V_est, theta_discrete, tau_discrete, ~] = ...
        DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);

    %% (b) bootstrap (불확실성 추정)
    [gamma_lower, gamma_upper, gamma_resamples] = ...
        bootstrap_uncertainty(t, ik, V_sd, lambda, n, dt, dur, OCV, R0, num_resamples);

    % 부트스트랩 평균
    gamma_avg = mean(gamma_resamples, 1);

    %% 저장
    gamma_est_all{s}      = gamma_est(:);
    theta_discrete_all{s} = theta_discrete(:);
    gamma_lower_all{s}    = gamma_lower(:);
    gamma_upper_all{s}    = gamma_upper(:);
    gamma_resample_all{s} = gamma_resamples;
    gamma_avg_all{s}      = gamma_avg(:);
end

%% (5) Store new fields into type_data
for s = 1:num_scenarios
    type_data(s).theta           = theta_discrete_all{s};
    type_data(s).gamma_est       = gamma_est_all{s};
    type_data(s).gamma_lower     = gamma_lower_all{s};
    type_data(s).gamma_upper     = gamma_upper_all{s};
    type_data(s).gamma_resamples = gamma_resample_all{s};
    type_data(s).gamma_avg       = gamma_avg_all{s};  % ★ 추가
end

%% (6) Reflect back to AS_data
for k = 1:num_scenarios
    AS_data(type_indices(k)).theta           = type_data(k).theta;
    AS_data(type_indices(k)).gamma_est       = type_data(k).gamma_est;
    AS_data(type_indices(k)).gamma_lower     = type_data(k).gamma_lower;
    AS_data(type_indices(k)).gamma_upper     = type_data(k).gamma_upper;
    AS_data(type_indices(k)).gamma_resamples = type_data(k).gamma_resamples;
    AS_data(type_indices(k)).gamma_avg       = type_data(k).gamma_avg;  % ★ 추가
end

%% (7) Plot in Subplot(2 x 5) with Shaded Uncertainty
% (시나리오가 최대 10개일 수 있으므로, 2 x 5 형태로 그리면 최대 10개까지 표시 가능)
num_cols = 5;
num_rows = 2;

figure('Name',[AS_name,' type ', selected_type,' - Subplot(2x5)'],...
       'NumberTitle','off');

for s = 1:num_scenarios
    subplot(num_rows, num_cols, s);

    th_s = theta_discrete_all{s}(:).';
    gl_s = gamma_lower_all{s}(:).';
    gu_s = gamma_upper_all{s}(:).';
    ga_s = gamma_avg_all{s}(:).';  % 중앙선 = 부트스트랩 평균
    plotColor = c_mat(s,:);       % 시나리오별 색상

    % (1) 불확실성 영역 (음영 + 투명도) -> 테두리 X
    fill([th_s, fliplr(th_s)], ...
         [gl_s, fliplr(gu_s)], ...
         plotColor, ...
         'FaceAlpha', 0.3, ...
         'EdgeColor', 'none');  % 테두리 없음
    hold on;

    % (2) 중앙선: 부트스트랩 평균
    plot(th_s, ga_s, 'LineWidth', 1.5, 'Color', plotColor);

    % (3) True gamma (검정 실선)
    plot(theta_true, gamma_discrete_true, 'k-','LineWidth',1.5);

    xlabel('\theta (ln(\tau))','FontSize',labelFontSize);
    ylabel('\gamma','FontSize',labelFontSize);
    title(['SN=', num2str(SN_list(s))], 'FontSize', titleFontSize);
    set(gca,'FontSize',axisFontSize);
    hold off;
end

%% (8) Check gamma_est within [gamma_lower, gamma_upper]
fprintf('\n=== Check gamma_est within [gamma_lower, gamma_upper] ===\n');
for s = 1:num_scenarios
    ga_s = gamma_avg_all{s};  % 부트스트랩 평균
    gl_s = gamma_lower_all{s};
    gu_s = gamma_upper_all{s};

    inBounds = (ga_s >= gl_s) & (ga_s <= gu_s);
    if all(inBounds)
        fprintf('Scenario %d (SN=%d): all gamma_est in bounds.\n', s, SN_list(s));
    else
        nOut = sum(~inBounds);
        fprintf('Scenario %d (SN=%d): WARNING - %d elements out of bounds.\n',...
            s, SN_list(s), nOut);
    end
end

%% (9) Save with original variable name (no switch)
save_folder   = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT';
save_filename = [AS_name, '.mat'];
save_path     = fullfile(save_folder, save_filename);

% eval로 원본 변수명에 대입
eval([AS_name, ' = AS_data;']);
% 변수명을 save
eval(['save(''', save_path,''',''',AS_name,''',''-v7.3'');']);

fprintf('\n[INFO] Saved to %s\n', save_path);






%% DRT_main_estimation_code.m
clc; clear; close all;

%% (1) Description
% - AS1_1per_new(UNIMODAL), AS2_1per_new(BIMODAL) 두 가지 데이터에 대해,
%   type='A' 인 시나리오만 골라서 DRT를 추정하고, 
%   불확실성(bootstrap)도 계산한 뒤, 결과를 구조체 배열로 저장하는 코드

%% (2) Graphic Parameters (필요 시)
axisFontSize   = 14;
titleFontSize  = 12;
legendFontSize = 12;
labelFontSize  = 12;

%% (3) Load .mat Files (측정데이터 + 사전에 정의된 Gamma_true 등)
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\';
mat_files = dir(fullfile(file_path, '*.mat'));

for file = mat_files'
    load(fullfile(file_path, file.name));
end

% 위에서 'AS1_1per_new', 'AS2_1per_new', 'Gamma_unimodal', 'Gamma_bimodal' 등이 로드되었다고 가정

%% (4) 우리는 오직 2개 데이터셋만 처리: {AS1_1per_new, AS2_1per_new}
%    UNIMODAL --> AS1_1per_new / BIMODAL --> AS2_1per_new
AS_data_list   = {AS1_1per_new, AS2_1per_new};
AS_name_list   = {'AS1_1per_new','AS2_1per_new'};
Gamma_list     = {Gamma_unimodal, Gamma_bimodal};

% type = 'A' 만 사용
selected_type  = 'A';  

%% (5) DRT 계산에 필요한 고정 파라미터
OCV = 0;        % 예시
R0  = 0.1;      % 예시
num_resamples = 100;  % 부트스트랩 횟수

%% (6) 결과 저장용 구조체 배열(drt_output)을 초기화
% drt_output(1)은 AS1_1per_new 결과, drt_output(2)는 AS2_1per_new 결과
drt_output = struct();

for k = 1:2
    % --- (a) 데이터/이름/True Gamma 선택 ---
    AS_data    = AS_data_list{k};
    AS_name    = AS_name_list{k};
    Gamma_data = Gamma_list{k};

    % True gamma, theta
    gamma_discrete_true = Gamma_data.gamma(:);  
    theta_true          = Gamma_data.theta(:);  

    % --- (b) type='A'에 해당하는 scenario만 골라옴 ---
    idx_typeA   = strcmp({AS_data.type}, selected_type);
    type_data   = AS_data(idx_typeA);
    num_scenari = length(type_data);

    fprintf('\n--- Processing %s (type=%s), # of scenarios = %d ---\n',...
            AS_name, selected_type, num_scenari);

    % drt_output(k) 최상위 필드 저장
    drt_output(k).AS_name       = AS_name;
    drt_output(k).type          = selected_type;
    drt_output(k).gamma_true    = gamma_discrete_true;
    drt_output(k).theta_true    = theta_true;
    drt_output(k).scenario      = [];  % 아래에서 scenario별로 채움

    % --- (c) 시나리오별로 DRT 추정 ---
    for s = 1:num_scenari
        scenario_data = type_data(s);

        fprintf('  --> Scenario SN=%d\n', scenario_data.SN);

        % 데이터 불러오기
        V_sd   = scenario_data.V(:);
        ik     = scenario_data.I(:);
        t      = scenario_data.t(:);
        dt     = scenario_data.dt;
        dur    = scenario_data.dur;
        n      = scenario_data.n;
        lambda = scenario_data.Lambda_hat;

        % (1) DRT 추정
        [gamma_est, V_est, theta_discrete, tau_discrete, ~] = ...
            DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);

        % (2) 부트스트랩 불확실성
        [gamma_lower, gamma_upper, gamma_resample_all] = ...
            bootstrap_uncertainty(t, ik, V_sd, lambda, n, dt, dur, OCV, R0, num_resamples);

        % (3) 결과 저장
        drt_output(k).scenario(s).SN              = scenario_data.SN;
        drt_output(k).scenario(s).t               = t;
        drt_output(k).scenario(s).I               = ik;
        drt_output(k).scenario(s).V               = V_sd;
        drt_output(k).scenario(s).theta_est       = theta_discrete(:);
        drt_output(k).scenario(s).gamma_est       = gamma_est(:);
        drt_output(k).scenario(s).gamma_lower     = gamma_lower(:);
        drt_output(k).scenario(s).gamma_upper     = gamma_upper(:);
        drt_output(k).scenario(s).gamma_resamples = gamma_resample_all;
        drt_output(k).scenario(s).lambda          = lambda;
        drt_output(k).scenario(s).dur             = dur;
        drt_output(k).scenario(s).n               = n;
        % 필요하다면 V_est, tau_discrete 등 추가
        % drt_output(k).scenario(s).V_est = V_est(:);
        % drt_output(k).scenario(s).tau   = tau_discrete(:);
    end
end

%% (7) 최종 저장
save('DRT_estimation_results.mat','drt_output','-v7.3');
fprintf('\n[INFO] DRT 결과가 "DRT_estimation_results.mat" 파일로 저장되었습니다.\n');


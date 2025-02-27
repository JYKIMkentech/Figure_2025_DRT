clc; clear; close all;

%% =============== 설정 ===============
axisFontSize   = 14;
titleFontSize  = 12;
legendFontSize = 12;
labelFontSize  = 12;

lambda_grids   = logspace(-8, 3, 30);
num_lambdas    = length(lambda_grids);
OCV            = 0;
R0             = 0.1;

%% =============== 데이터 로드 ===============
save_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_DRT\';
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\'; 
%file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_new\'; 
mat_files = dir(fullfile(file_path, '*.mat'));

if isempty(mat_files)
    error('데이터 파일이 존재하지 않습니다. 경로를 확인해주세요.');
end

% 폴더 내 모든 .mat 파일 로드
for file = mat_files'
    load(fullfile(file_path, file.name));
end

%% =============== 데이터셋 선택 ===============
% 1%,2%,3%,4%를 모두 포함한 8개 파일 이름
datasets = { ...
    'AS1_1per_new', 'AS1_2per_new', 'AS1_3per_new', 'AS1_4per_new', ...
    'AS2_1per_new', 'AS2_2per_new', 'AS2_3per_new', 'AS2_4per_new'};

disp('=== 분석할 데이터셋을 선택하세요 ===');
for i = 1:length(datasets)
    fprintf('%d. %s\n', i, datasets{i});
end

dataset_idx = input('데이터셋 번호를 입력하세요: ');
if isempty(dataset_idx) || dataset_idx < 1 || dataset_idx > length(datasets)
    error('유효한 데이터셋 번호를 입력해주세요.');
end
selected_dataset_name = datasets{dataset_idx};

% 해당 이름의 변수(구조체)가 워크스페이스에 존재하는지 확인
if ~exist(selected_dataset_name, 'var')
    error('선택한 데이터셋 [%s]이(가) 로드되지 않았습니다.', selected_dataset_name);
end

% 실제 구조체 데이터 로딩
selected_dataset = eval(selected_dataset_name);  % 예: selected_dataset = AS1_3per_new;

% 보통 1개 데이터셋당 80개 (type 8개 x 시나리오10) 등이 들어있음
fprintf('선택된 데이터셋: %s, 전체 길이: %d\n', selected_dataset_name, length(selected_dataset));

%% =============== 타입 선택 ===============
types = unique({selected_dataset.type}); % 예: A, B, C, ..., H
disp('=== 타입을 선택하세요 ===');
for i = 1:length(types)
    fprintf('%d. %s\n', i, types{i});
end

type_idx = input('타입 번호를 입력하세요: ');
if isempty(type_idx) || type_idx < 1 || type_idx > length(types)
    error('유효한 타입 번호를 입력해주세요.');
end
selected_type = types{type_idx};
type_indices  = strcmp({selected_dataset.type}, selected_type);
type_data     = selected_dataset(type_indices); 
if isempty(type_data)
    error('선택한 타입 [%s]에 해당하는 데이터가 없습니다.', selected_type);
end

% 시나리오 번호 목록
SN_list = [type_data.SN];  % 예: [1 2 3 4 ... 10]

%% =============== (새로운 필드 추가) ===============
% 이후 Lambda_vec, CVE, Lambda_hat 저장을 위해 필요
new_fields = {'Lambda_vec', 'CVE', 'Lambda_hat'};
num_elements = length(selected_dataset);
empty_fields = repmat({[]}, 1, num_elements);

for nf = 1:length(new_fields)
    field_name = new_fields{nf};
    if ~isfield(selected_dataset, field_name)
        [selected_dataset.(field_name)] = empty_fields{:};
    end
end

%% =============== 람다 최적화 및 교차 검증 ===============
scenario_numbers = SN_list; 
validation_combinations = nchoosek(scenario_numbers, 2); % 10C2 = 45
num_folds = size(validation_combinations, 1); 
CVE_total = zeros(num_lambdas, 1);

fprintf('\n[교차 검증 시작] 타입=%s, 시나리오=%s\n', selected_type, mat2str(scenario_numbers));

for m = 1 : num_lambdas
    lambda = lambda_grids(m);
    CVE = 0;

    for f = 1 : num_folds
        % validation set index (2개 시나리오)
        val_trips = validation_combinations(f,:);
        % train set index = 전체 시나리오에서 val_trips 제외
        train_trips = setdiff(1 : length(type_data), val_trips);

        W_total = [];
        y_total = [];

        % === (1) Training ===
        for s = train_trips
            t   = type_data(s).t;
            dt  = [t(1); diff(t)];
            dur = type_data(s).dur;
            n   = type_data(s).n;
            I   = type_data(s).I;
            V   = type_data(s).V;

            [~, ~, ~, ~, W, y] = DRT_estimation(t, I, V, lambda, n, dt, dur, OCV, R0);

            W_total = [W_total; W];
            y_total = [y_total; y];
        end

        % gamma 추정
        [gamma_total] = DRT_estimation_with_Wy(W_total, y_total, lambda);

        % === (2) Validation ===
        for j = val_trips
            t   = type_data(j).t;
            dt  = [t(1); diff(t)];
            dur = type_data(j).dur;
            n   = type_data(j).n;
            I   = type_data(j).I;
            V   = type_data(j).V;

            [~, ~, ~, ~, W_val, ~] = DRT_estimation(t, I, V, lambda, n, dt, dur, OCV, R0);
            V_est = OCV + I*R0 + W_val * gamma_total;

            error = sum((V - V_est).^2);
            CVE = CVE + error;
        end
    end
    
    CVE_total(m) = CVE;
    fprintf('Lambda = %.2e, CVE = %.4f\n', lambda, CVE);
end

[~, optimal_idx] = min(CVE_total);
optimal_lambda = lambda_grids(optimal_idx);
fprintf('\n=== Optimal lambda = %.2e ===\n\n', optimal_lambda);

%% =============== 결과 저장 ===============
% (선택된 type_data 내 모든 element에 Lambda_vec, CVE, Lambda_hat 저장)
for i = 1:length(type_data)
    type_data(i).Lambda_vec = lambda_grids;
    type_data(i).CVE        = CVE_total;
    type_data(i).Lambda_hat = optimal_lambda;
end
% 다시 전체 구조체에 반영
selected_dataset(type_indices) = type_data;
assignin('base', selected_dataset_name, selected_dataset);

% 폴더가 없으면 생성
if ~exist(save_path, 'dir')
    mkdir(save_path);
end

% 선택된 데이터셋을 저장
save_file_name = fullfile(save_path, [selected_dataset_name, '.mat']);
save(save_file_name, selected_dataset_name);
fprintf('Updated dataset saved to:\n%s\n\n', save_file_name);

%% =============== CVE vs lambda Plot ===============
figure;
semilogx(lambda_grids, CVE_total, 'b-', 'LineWidth', 1.5); hold on;
semilogx(optimal_lambda, CVE_total(optimal_idx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
xlabel('\lambda', 'FontSize', labelFontSize);
ylabel('CVE',    'FontSize', labelFontSize);
title(['CVE vs \lambda (Type = ', selected_type, ', ', selected_dataset_name, ')'], 'FontSize', titleFontSize);
grid on;
legend({'CVE', ['Optimal \lambda = ', num2str(optimal_lambda, '%.2e')]}, 'Location', 'best');
hold off;

%% =============== 필요한 함수 정의 ===============
% (W,Y 주어졌을때 gamma 해 구하기)
function [gamma_total] = DRT_estimation_with_Wy(W_total, y_total, lambda)
    W_total_n = size(W_total, 2); % Number of gamma parameters
    
    % 1차차분 연산자 L
    L = zeros(W_total_n-1, W_total_n);
    for i = 1:W_total_n-1
        L(i, i)   = -1;
        L(i, i+1) =  1;
    end

    % quadprog을 위한 구성
    H = 2 * (W_total' * W_total + lambda * (L' * L));
    f = -2 * (W_total' * y_total);

    % gamma >= 0
    A_ineq = -eye(W_total_n);
    b_ineq = zeros(W_total_n, 1);

    % Solve the quadratic programming problem
    options = optimoptions('quadprog', 'Display', 'off');
    gamma_total = quadprog(H, f, A_ineq, b_ineq, [], [], [], [], [], options);  
end





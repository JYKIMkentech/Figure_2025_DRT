clc; clear; close all;

p_colors = [
    0.00000, 0.45098, 0.76078;  % #1 (Blue)
    0.93725, 0.75294, 0.00000;  % #2 (Yellow-ish)
    0.80392, 0.32549, 0.29803;  % #3 (Red)
    0.12549, 0.52157, 0.30588;  % #4 (Green-ish)
    0.57255, 0.36863, 0.62353;  % #5
    0.88235, 0.52941, 0.15294;  % #6
    0.30196, 0.73333, 0.83529;  % #7
    0.93333, 0.29803, 0.59216;  % #8
    0.49412, 0.38039, 0.28235;  % #9
    0.45490, 0.46275, 0.47059   % #10
];

%% (1) Load Data
file_path = 'G:\공유 드라이브\Battery Software Lab\Projects\DRT\SD_lambda\';
mat_files = dir(fullfile(file_path, '*.mat'));

for file = mat_files'
    load(fullfile(file_path, file.name));
end

%% (2) 원하는 데이터/타입을 직접 지정 (예: AS1_1per_new, type='A')
AS_data      = AS2_1per_new;      % 예시
Gamma_data   = Gamma_bimodal;    % True gamma 정보 (예시)
type_indices = find(strcmp({AS_data.type}, 'A'));
type_data    = AS_data(type_indices);

% 시나리오 번호 리스트
SN_list = [type_data.SN];

% 우리가 그리고 싶은 시나리오 (1,2,3,4)
scenarios_to_plot = [1, 2, 3, 4];
selected_indices  = find(ismember(SN_list, scenarios_to_plot)); 

if isempty(selected_indices)
    error('시나리오 1,2,3,4 중에 존재하지 않는 것이 있습니다.');
end

%% (3) 공통 파라미터
OCV = 0;
R0 = 0.1;
num_resamples = 100;  % Bootstrap 개수

% True gamma (bimodal/unimodal 자료에 따라 변경)
gamma_discrete_true = Gamma_data.gamma';
theta_true          = Gamma_data.theta';

%% (4) 결과 저장할 셀/배열 초기화
nSel = length(selected_indices);
c_mat = lines(nSel);

gamma_est_all   = cell(nSel, 1);
gamma_lower_all = cell(nSel, 1);
gamma_upper_all = cell(nSel, 1);
theta_discrete_all = cell(nSel, 1);

%% (5) DRT 추정 + Bootstrap
for i = 1:nSel
    idxScenario = selected_indices(i);   % type_data 내 index
    scenario_data = type_data(idxScenario);
    
    V_sd = scenario_data.V(:);
    ik   = scenario_data.I(:);
    t    = scenario_data.t(:);
    dt   = scenario_data.dt;
    dur  = scenario_data.dur;
    n    = scenario_data.n;
    lambda = scenario_data.Lambda_hat;
    
    % DRT 추정
    [gamma_est, V_est, theta_discrete, tau_discrete, ~] = ...
        DRT_estimation(t, ik, V_sd, lambda, n, dt, dur, OCV, R0);
    
    gamma_est_all{i}     = gamma_est';
    theta_discrete_all{i} = theta_discrete;
    
    % Bootstrap 불확도
    [g_lower, g_upper, ~] = ...
        bootstrap_uncertainty(t, ik, V_sd, lambda, n, dt, dur, OCV, R0, num_resamples);
    gamma_lower_all{i} = g_lower;
    gamma_upper_all{i} = g_upper;
end

%% (6) 시나리오 4개를 shaded area로 표시
% nSel = 시나리오 개수 (예: 4)
% selected_indices = [1,2,3,4] 등
% theta_s, gamma_s, gamma_low, gamma_up => 각각 행벡터로 준비

fig_handle = figure('Name','DRT_1234','NumberTitle','off');
hold on;

for i = 1:nSel
    % 1) 데이터 추출
    theta_s   = theta_discrete_all{i}(:)'; 
    gamma_s   = gamma_est_all{i}(:)';
    gamma_low = gamma_lower_all{i}(:)';
    gamma_up  = gamma_upper_all{i}(:)';

    % 2) fill()용 X, Y
    x_shade = [theta_s, fliplr(theta_s)];
    y_shade = [gamma_low, fliplr(gamma_up)];

    % 3) 음영 부분
    fill(x_shade, y_shade, p_colors(i,:), ...   % <--- 여기!
         'FaceAlpha', 0.2, ...
         'EdgeColor', 'none', ...
         'HandleVisibility', 'off');

    % 4) 중심선
    plot(theta_s, gamma_s, 'LineWidth', 1.5, ...
         'Color', p_colors(i,:), ...           % <--- 여기!
         'DisplayName', ['Scenario ', num2str(SN_list(selected_indices(i)))]);
end

% True gamma
plot(theta_true, gamma_discrete_true, 'k-', 'LineWidth', 2, 'DisplayName','True \gamma');

hold off;
xlabel('\theta','FontSize',12);
ylabel('\gamma','FontSize',12);
legend('Location','Best');
set(gca,'FontSize',12);
ylim([0 1.1]);

% (a) 표시 annotation
annotation('textbox',...
           [0.01 0.92 0.08 0.07], ... 
           'String','(f)', ...
           'FontSize',14, ...
           'FontWeight','bold', ...
           'EdgeColor','none');

saveas(fig_handle,'Figure_Code2_Shadow.svg');
savefig(fig_handle,'Figure_Code2_Shadow.fig');


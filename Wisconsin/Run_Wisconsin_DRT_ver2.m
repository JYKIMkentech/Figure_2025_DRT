%% DRT_uncertainty_main.m
clear; clc; close all;

%% (0) 고정 파라미터 설정
n            = 201;     % RC 소자 개수
dur          = 1370;    % [sec], tau_max
SOC_begin    = 0.9907;  % (필요시 사용)
Q_batt       = 2.8153;  % [Ah] (필요시 사용)
lambda_hat   = 0.385;   % 정칙화 파라미터
num_resamples= 500;     % 부트스트랩 반복 횟수

%% (1) UDDS(or 기타) 데이터 로드
% 예: udds_data_soc_results(1).t, .I, .V ...
load('udds_data_soc_results.mat','udds_data_soc_results');
num_trips = length(udds_data_soc_results);

%% (2) Trip별 부트스트랩 + 평균/5%-95% 구간 계산 + 결과 저장
results = struct();  % 결과 저장용
figure('Position',[100 100 1400 600]);  % 전체 결과 확인용
tiledlayout('flow','TileSpacing','compact','Padding','compact');

for trip_idx = 1:num_trips
    t_data  = udds_data_soc_results(trip_idx).t;
    ik_data = udds_data_soc_results(trip_idx).I;
    V_data  = udds_data_soc_results(trip_idx).V;

    % (2-1) 먼저 원본 데이터에 대해 DRT 한 번 추정해서 tau_discrete 얻기
    %       - 혹시 tau가 log scale이면 tau_discrete가 아닌 theta_discrete일 수도 있음
    [gamma_once, tau_discrete, ~, ~, ~, ~, ~] = SD_DRT_estimation_aug(...
        t_data, ik_data, V_data, lambda_hat, n, diff(t_data), dur);

    % (2-2) 부트스트랩 함수 호출 → (num_resamples x n)의 재추정결과
    gamma_resample_all = bootstrap_uncertainty_aug(...
        t_data, ik_data, V_data, lambda_hat, n, dur, num_resamples);

    % (2-3) 평균 / 5% / 95% 구하기
    avg_gamma   = mean(gamma_resample_all, 1);                 % 1 x n
    gamma_lower = prctile(gamma_resample_all,  5, 1);          % 1 x n
    gamma_upper = prctile(gamma_resample_all, 95, 1);          % 1 x n

    % (2-4) 결과 구조체에 저장
    results(trip_idx).tau_discrete   = tau_discrete;
    results(trip_idx).avg_gamma     = avg_gamma;
    results(trip_idx).gamma_lower   = gamma_lower;
    results(trip_idx).gamma_upper   = gamma_upper;
    results(trip_idx).gamma_all     = gamma_resample_all;  % (옵션) raw data
    results(trip_idx).SOC_begin     = SOC_begin;
    results(trip_idx).Q_batt        = Q_batt;
    results(trip_idx).lambda_hat    = lambda_hat;

    % (2-5) 그림( fill + 평균 )으로 시각화
    nexttile;  % tiledlayout 서브플롯
    hold on; box on;
    xFill = [tau_discrete(:); flipud(tau_discrete(:))];
    yFill = [gamma_lower(:);  flipud(gamma_upper(:))];

    % -- 쉐도우(5%~95%)
    hFill = fill(xFill, yFill, 'b','LineStyle','none');
    set(hFill, 'FaceAlpha', 0.2);

    % -- 평균값 곡선
    plot(tau_discrete, avg_gamma, 'b-', 'LineWidth',2, ...
        'DisplayName','Avg \gamma');

    xlabel('\tau [s]');
    ylabel('\gamma [\Omega]');
    title(sprintf('Trip #%d', trip_idx));
    legend('Location','best');
end

%% (3) 결과 구조체를 .mat 파일로 저장
save('DRT_bootstrap_results.mat','results');
disp('>> DRT_bootstrap_results.mat 파일로 저장 완료!');

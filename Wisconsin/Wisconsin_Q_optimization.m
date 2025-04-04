clear; clc; close all;

%% 0. 폰트 크기 및 색상 매트릭스 설정
% Font size settings
axisFontSize = 14;      % 축의 숫자 크기
titleFontSize = 16;     % 제목의 폰트 크기
legendFontSize = 12;    % 범례의 폰트 크기
labelFontSize = 14;     % xlabel 및 ylabel의 폰트 크기

% Color matrix 설정
c_mat = lines(9);  % 9개의 고유한 색상 정의

%% 1. 데이터 로드
% UDDS 주행 데이터를 로드합니다.
load('udds_data.mat');  % 'udds_data' 구조체를 로드합니다.

% SOC-OCV 데이터를 로드합니다.
load('soc_ocv.mat', 'soc_ocv');
soc_values = soc_ocv(:, 1);  % SOC 값
ocv_values = soc_ocv(:, 2);  % OCV 값

%% 2. Parameter 설정
n = 201;
dur = 1370;  % [sec]
SOC_begin_initial = 0.9907;  % 초기 SOC

% lambda_hat 고정
lambda_hat = 0.385;

% Q_batt 범위 설정 (2.5 ~ 3.1 사이 20포인트)
Q_batt_grids = linspace(2.5, 3.1, 20);

%% 3. RMSE 계산
num_trips = length(udds_data);   % 전체 트립 수 (17로 가정)
num_used_trips = 11;            % 실제 사용할 트립 수 (1~13)

RMSE = zeros(1, length(Q_batt_grids));

for Q_index = 1:length(Q_batt_grids)
    Q_batt = Q_batt_grids(Q_index);
    total_RMSE = 0;
    
    % 각 Q_batt 마다 초기 SOC 리셋
    SOC_begin = SOC_begin_initial;
    
    % 1~13번 트립만 사용
    for s = 1:num_used_trips
        % 해당 트립의 시간, 전류, 전압
        t = udds_data(s).t;    % 시간 벡터 [s]
        I = udds_data(s).I;    % 전류 벡터 [A]
        V = udds_data(s).V;    % 실제 전압 벡터 [V]
        
        % 시간 간격
        dt = [t(1); diff(t)];  % 첫 번째 dt는 t(1)으로 설정
        
        % SOC 계산
        SOC = SOC_begin + cumtrapz(t, I) / (Q_batt * 3600);
        
        % DRT_estimation_aug 함수 호출
        [gamma_est, R0_est, V_est, theta_discrete, W, ~, ~] = ...
            DRT_estimation_aug(t, I, V, lambda_hat, n, dt, dur, SOC, soc_values, ocv_values);
        
        % RMSE 계산
        RMSE_trip = sqrt(mean((V_est - V).^2));
        total_RMSE = total_RMSE + RMSE_trip;
        
        % SOC 업데이트
        SOC_begin = SOC(end);
    end
    
    % 1~13번 트립의 RMSE 합
    RMSE(Q_index) = total_RMSE;
end

%% 4. 최적 Q_batt 및 결과 시각화
[min_RMSE, min_idx] = min(RMSE);
opt_Q_batt = Q_batt_grids(min_idx);

figure;
plot(Q_batt_grids, RMSE, 'o-');
hold on;
plot(opt_Q_batt, min_RMSE, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

xlabel('Q_{batt} [Ah]', 'FontSize', labelFontSize);
ylabel('Total RMSE Voltage [V]', 'FontSize', labelFontSize);
title('RMSE vs. Q_{batt} (Trip 1~11, \lambda = 0.385)', 'FontSize', titleFontSize);
legend(sprintf('Q_{batt} grid'), sprintf('Min RMSE at Q=%.4f Ah', opt_Q_batt), ...
       'Location', 'best');
grid on;

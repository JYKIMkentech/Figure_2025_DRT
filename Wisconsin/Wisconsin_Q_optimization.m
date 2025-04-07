clear; clc; close all;

%% 0. 폰트 크기 및 색상 매트릭스 설정
axisFontSize = 14;      % 축의 숫자 크기
titleFontSize = 16;     % 제목의 폰트 크기
legendFontSize = 12;    % 범례의 폰트 크기
labelFontSize = 14;     % xlabel 및 ylabel의 폰트 크기

%% 1. 데이터 로드
% UDDS 주행 데이터를 로드합니다.
load('udds_data.mat');  % 'udds_data' 구조체를 로드합니다.

% SOC-OCV 데이터를 로드합니다.
load('soc_ocv.mat', 'soc_ocv');
soc_values = soc_ocv(:, 1);  % SOC 값
ocv_values = soc_ocv(:, 2);  % OCV 값

%% 2. Parameter 설정
n = 201;
dur = 1370;                 % [sec]
SOC_begin_initial = 0.9907; % 초기 SOC

% 트립 개수 및 사용할 트립 범위
num_trips = length(udds_data);
num_used_trips = 11;        % 1~11번 트립만 사용

% 람다 범위 (10^-3 ~ 10^1, 총 10개 포인트)
lambda_vec = logspace(0, 1, 20);

% Q_batt 범위 설정 (2.5 ~ 3.1 사이 10개 포인트)
Q_batt_grids = linspace(2.5, 3.1, 10);

%% 3. RMSE 계산 (2중 for문)
% RMSE를 저장할 2차원 행렬 (행: lambda 인덱스, 열: Q_batt 인덱스)
RMSE_matrix = zeros(length(lambda_vec), length(Q_batt_grids));

for i = 1:length(lambda_vec)
    lambda_hat = lambda_vec(i);
    
    for j = 1:length(Q_batt_grids)
        Q_batt = Q_batt_grids(j);
        
        total_RMSE = 0;
        SOC_begin = SOC_begin_initial;  % 각 Q_batt 마다 SOC 리셋

        % 1~11번 트립에 대해 모델 예측 및 RMSE 누적
        for s = 1:num_used_trips
            % 트립 데이터
            t = udds_data(s).t;  % 시간 [s]
            I = udds_data(s).I;  % 전류 [A]
            V = udds_data(s).V;  % 측정 전압 [V]
            
            % 시간 간격
            dt = [t(1); diff(t)];
            
            % SOC 계산
            SOC = SOC_begin + cumtrapz(t, I) / (Q_batt * 3600);
            
            % DRT_estimation_aug 함수 호출
            [~, ~, V_est, ~, ~, ~, ~] = ...
                DRT_estimation_aug(t, I, V, lambda_hat, n, dt, dur, SOC, soc_values, ocv_values);
            
            % RMSE 계산
            RMSE_trip = sqrt(mean((V_est - V).^2));
            total_RMSE = total_RMSE + RMSE_trip;
            
            % SOC 업데이트 (다음 트립 시작점으로)
            SOC_begin = SOC(end);
        end
        
        % 이번 (lambda, Q_batt) 조합의 RMSE 저장
        RMSE_matrix(i, j) = total_RMSE;
    end
end

%% 4. 전체 최소 RMSE 지점 찾기
[global_min_val, global_min_idx] = min(RMSE_matrix(:));
[best_lambda_idx, best_Qbatt_idx] = ind2sub(size(RMSE_matrix), global_min_idx);

best_lambda = lambda_vec(best_lambda_idx);
best_Qbatt  = Q_batt_grids(best_Qbatt_idx);

%% 5. 3D Surface Plot (최적 조합에 빨간 동그라미 + Legend)
figure;

% 서피스 플롯
hSurf = surf(Q_batt_grids, lambda_vec, RMSE_matrix, 'EdgeColor', 'none');
hold on;

% 최적 지점 표시 (plot3)
hOpt = plot3(best_Qbatt, best_lambda, global_min_val, ...
             'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');

% 축 설정
set(gca, 'YScale', 'log');   % 람다 축을 로그 스케일로
xlabel('Q_{batt} [Ah]', 'FontSize', labelFontSize);
ylabel('\lambda', 'FontSize', labelFontSize);
zlabel('Total RMSE [V]', 'FontSize', labelFontSize);
title('RMSE vs. Q_{batt} vs. \lambda (Trip 1~11)', 'FontSize', titleFontSize);
colorbar; 
grid on;

% 보기 각도
view([-40 30]); 
shading interp;

% 범례 추가 (박스에 최적값 정보 포함)
legend([hSurf, hOpt], ...
       'RMSE surface', ...
       sprintf('Optimal (λ=%.2e, Q=%.3f)\nRMSE=%.4f', best_lambda, best_Qbatt, global_min_val), ...
       'Location','best', 'Box','on', 'FontSize', legendFontSize);


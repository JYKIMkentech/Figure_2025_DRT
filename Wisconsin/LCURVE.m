%% L-Curve Method Script (No Function Form)
clear; clc; close all;

% (1) 앞서 Cross-Validation 후 저장했던 lambda, CVE 데이터 불러오기
%     예: 'lambda_cve_results.mat' 내부에 'results'라는 struct가 있다고 가정
load('lambda_cve_results.mat');  
lambda_list = results.lambda;   % [n x 1] or [1 x n] 형태 가정
CVE_list    = results.CVE;     % [n x 1] or [1 x n] 형태 가정
% (만약 table 형태로 저장했다면, 다음처럼 수정)
% load('lambda_cve_results.mat','resultsTable');
% lambda_list = resultsTable.Lambda; 
% CVE_list    = resultsTable.CVE;

%  - W_total: 전체 학습데이터 행렬 (크기 예: [M x (nGamma+1)], R0 포함했다면 열+1)
%  - y_total: 측정 전압 벡터 (크기: [M x 1])
%  - L_aug  : 정칙화 연산자 (예: 1차차분이거나 적절히 구성)

% (3) 각 lambda마다 gamma (및 R0) 추정을 통해 잔차 노름 / 정칙화 노름 계산
nLambda = length(lambda_list);
residualNorm = zeros(nLambda,1);  % ||W*[gamma;R0] - y||
regNorm      = zeros(nLambda,1);  % ||L_aug*gamma||

for i = 1 : nLambda
    thisLambda = lambda_list(i);

    % ---------------------------------------------------------------------
    %  (3-1) gamma, R0 추정 (예시) : 기존의 DRT_estimation_aug_with_Wy() 같은 QP풀이
    % ---------------------------------------------------------------------
    %  아래처럼 직접 inline으로 적거나, 이미 만들어둔 함수를 호출할 수도 있습니다.
    %
    %  H = 2*(W_total'*W_total + thisLambda*(L_aug'*L_aug));  % gamma만 정칙화
    %  f = -2*(W_total'*y_total);
    %  A_ineq = -eye(size(W_total,2));  % gamma >= 0, R0 >= 0
    %  b_ineq = zeros(size(W_total,2),1);
    %  options = optimoptions('quadprog','Display','off');
    %  params  = quadprog(H,f,A_ineq,b_ineq,[],[],[],[],[],options);
    %  gamma_est = params(1:end-1);
    %  R0_est    = params(end);

    % 여기서는 함수를 부른다고 가정 (이미 구현되어있다고 치고)
    [gamma_est, R0_est] = DRT_estimation_aug_with_Wy(W_total, y_total, thisLambda);

    % (3-2) 잔차 노름 계산
    model_fit = W_total * [gamma_est; R0_est];       % 예: (M x (nGamma+1)) * ((nGamma+1) x 1)
    residualNorm(i) = norm(model_fit - y_total, 2);  % 2-노름

    % (3-3) 정칙화 노름 계산 (R0에는 정칙화 x)
    regNorm(i) = norm(L_aug * gamma_est, 2); 
end

% (4) L-curve 그리기 (log-log 스케일)
figure('Color','w');
loglog(residualNorm, regNorm, 'b-o','LineWidth',1.2); hold on; grid on;
xlabel('||Residual||_2','FontSize',12);
ylabel('||Regularization||_2','FontSize',12);
title('L-Curve','FontSize',14);

% (5) L-curve "모서리(corner)" 찾기
%     간단히 log(residualNorm), log(regNorm)에 대한 2D 곡률 최대값 위치
nPt = nLambda;
curvVals = zeros(nPt,1);

% log 좌표로 변환
lr = log(residualNorm);
lz = log(regNorm);

% 이산적 2D곡률 계산
for i = 2 : nPt-1
    % 세 점 (i-1, i, i+1)을 이용
    p1 = [lr(i-1), lz(i-1)];
    p2 = [lr(i),   lz(i)];
    p3 = [lr(i+1), lz(i+1)];

    % 세 점으로 만든 삼각형 외접원의 곡률 근사: k = 4A / (a*b*c)
    a = norm(p2 - p1);
    b = norm(p3 - p2);
    c = norm(p3 - p1);
    A = abs( 0.5 * ( p1(1)*(p2(2)-p3(2)) + p2(1)*(p3(2)-p1(2)) + p3(1)*(p1(2)-p2(2)) ) );
    curvVals(i) = 4*A / (a*b*c + eps);
end

[~, corner_idx] = max(curvVals); 
corner_lambda = lambda_list(corner_idx);

% (6) 그래프에 corner 표시
loglog(residualNorm(corner_idx), regNorm(corner_idx), 'rs','MarkerFaceColor','r','MarkerSize',8);
legend({'L-Curve', sprintf('Corner: \\lambda = %.2e', corner_lambda)},'Location','best');

fprintf('--- L-curve corner lambda = %.3e (index = %d) ---\n', corner_lambda, corner_idx);

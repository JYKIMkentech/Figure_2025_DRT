function [gamma_est, R0_est, V_est, theta_discrete, W, y, OCV, b_est] = ...
    DRT_estimation_aug2(t, ik, V_sd, lambda_hat, n, dt, dur, SOC, soc_values, ocv_values)
% DRT_estimation_aug2  (상수항 b 추가, OCV(1)=V(1) 강제 제거 버전)
%   y = V - OCV 를 대상으로
%   [1, W, ik] * [b; gamma; R0] 최소제곱 + λ||L*gamma||^2  (b, R0에는 정규화 X)
%   제약: gamma >= 0, R0 >= 0, b는 자유
%
% Inputs:
%   t, ik, V_sd, lambda_hat, n, dt, dur, SOC : 길이 N 벡터(또는 스칼라)들
%   soc_values, ocv_values : SOC–OCV 테이블 (SOC→OCV 보간용)
%
% Outputs:
%   gamma_est [n x 1], R0_est (scalar), V_est [N x 1],
%   theta_discrete [n x 1], W [N x n], y [N x 1], OCV [N x 1], b_est (scalar)

    % ---------- 0) 벡터 형식 정리 ----------
    t    = t(:);
    ik   = ik(:);
    V_sd = V_sd(:);
    dt   = dt(:);
    SOC  = SOC(:);
    N = numel(t);
    assert(all([numel(ik), numel(V_sd), numel(dt), numel(SOC)] == N), 'Input lengths must match');

    % ---------- 1) OCV 보간 (강제 정렬/단조 가정 없음) ----------
    OCV = interp1(soc_values(:), ocv_values(:), SOC, 'linear', 'extrap');
    % ※ 2번 수정: 더 이상 OCV(1)=V_sd(1)로 강제하지 않음

    % ---------- 2) tau/theta 격자 ----------
    tau_min = 0.1;            % 필요시 조정
    tau_max = dur;            % 입력 dur = tau_max
    theta_discrete = linspace(log(tau_min), log(tau_max), n).';
    delta_theta    = theta_discrete(2) - theta_discrete(1);
    tau_discrete   = exp(theta_discrete);

    % ---------- 3) W 행렬 (Forward Euler, i(k-1) 사용) ----------
    W = zeros(N, n);
    for k_idx = 2:N
        dtk = dt(k_idx);
        for i = 1:n
            a = exp(-dtk / tau_discrete(i));
            W(k_idx,i) = W(k_idx-1,i)*a + ik(k_idx-1)*(1 - a)*delta_theta;
        end
    end

    % ---------- 4) 설계행렬: 상수항 b 포함 ----------
    % params = [b ; gamma(1..n) ; R0]
    W_aug = [ones(N,1), W, ik];        % [N x (n+2)]

    % ---------- 5) 타겟 y = V - OCV ----------
    y = (V_sd - OCV);
    y = y(:);

    % ---------- 6) 정규화(γ에만 1차 차분) ----------
    L = zeros(n-1, n);
    for i = 1:n-1
        L(i,i)   = -1;
        L(i,i+1) =  1;
    end
    % L_aug: b와 R0에는 정규화 적용하지 않음
    L_aug = [zeros(n-1,1), L, zeros(n-1,1)];   % [(n-1) x (n+2)]

    % ---------- 7) QP 목적식 ----------
    % minimize ||y - W_aug*params||^2 + λ||L_aug*params||^2
    H = 2*(W_aug.'*W_aug + lambda_hat*(L_aug.'*L_aug));
    f = -2*(W_aug.'*y);

    % ---------- 8) 부등식 제약: gamma >= 0, R0 >= 0, b는 자유 ----------
    % 매개변수 인덱스
    %   b:        1
    %   gamma:    2 .. (n+1)
    %   R0:       n+2
    A_ineq = zeros(n+1, n+2);
    b_ineq = zeros(n+1, 1);

    % -gamma <= 0
    A_ineq(1:n, 2:n+1) = -eye(n);

    % -R0 <= 0
    A_ineq(n+1, n+2) = -1;

    % ---------- 9) QP 풀기 ----------
    % b와 R0에는 정규화 X, gamma만 L2-차분 정규화
    % b, R0는 비음수 제약 없음(단 R0는 >=0)
    options = optimoptions('quadprog','Display','off');
    params = quadprog(H, f, A_ineq, b_ineq, [], [], [], [], [], options);

    % ---------- 10) 파라미터 추정치 ----------
    b_est      = params(1);
    gamma_est  = params(2:n+1);
    R0_est     = params(n+2);

    % ---------- 11) 전압 재구성 ----------
    V_est = OCV + b_est + W*gamma_est + ik*R0_est;
end
